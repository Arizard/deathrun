ROUND_WAITING = 3
ROUND_PREP = 4
ROUND_PREPARING = ROUND_PREP
ROUND_ACTIVE = 5
ROUND_OVER = 6
ROUND_ENDING = ROUND_OVER

-- win constants
WIN_STALEMATE = 1
WIN_RUNNER = TEAM_RUNNER
WIN_DEATH = TEAM_DEATH

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE

RoundDuration = CreateConVar("deathrun_round_duration", 60*5, defaultFlags, "How many seconds each round should last, not including preptime.")
PrepDuration = CreateConVar("deathrun_preptime_duration", 5, defaultFlags, "How many seconds preptime should go for.")
FinishDuration = CreateConVar("deathrun_finishtime_duration", 10, defaultFlags, "How many seconds to wait before starting a new round.")
DeathRatio = CreateConVar("deathrun_death_ratio", 0.15, defaultFlags, "What fraction of players are Deaths.")
RoundLimit = CreateConVar("deathrun_round_limit", 6, defaultFlags, "How many rounds to play before changing the map.")
DeathAvoidPunishment = CreateConVar("deathrun_death_avoid_punishment", 1, defaultFlags, "How many round should a player sit out after they attempt to death avoid?")
DeathMax = CreateConVar("deathrun_max_deaths", 64, defaultFlags, "Maximum amount of players on the Death team at any given time.")

CreateConVar("deathrun_autoslay_delay", 90, defaultFlags, "How long to wait after a start of a round before slaying all the AFKs.")

DR.DeathAvoidPunishment = DeathAvoidPunishment

-- for the round timer
-- have a shared ROUND_TIMER variable which continuously counts down each 0.2 second
-- timer going every 0.2s updating ROUND_TIMER so we have a precision of 1/5th of a second ?????
-- network each time the timer is set, but calculate the timer on server and client individually

ROUND_TIMER = ROUND_TIMER or 0

function ROUND:GetTimer() 
	return ROUND_TIMER or 0
end

timer.Create("DeathrunRoundTimerCalculate", 0.2, 0, function()
	ROUND_TIMER = ROUND_TIMER - 0.2
	if ROUND_TIMER < 0 then ROUND_TIMER = 0 end
end)

if SERVER then
	util.AddNetworkString("DeathrunSyncRoundTimer")
	util.AddNetworkString("DeathrunSendMVPs")
	function ROUND:SyncTimer()
		net.Start("DeathrunSyncRoundTimer")
		net.WriteInt( ROUND:GetTimer(), 16 )
		net.Broadcast()
	end
	function ROUND:SyncTimerPlayer( ply )
		net.Start("DeathrunSyncRoundTimer")
		net.WriteInt( ROUND:GetTimer(), 16 )
		net.Send( ply )
	end
	function ROUND:SetTimer( s )
		ROUND_TIMER = s
		ROUND:SyncTimer()
	end
else
	net.Receive("DeathrunSyncRoundTimer", function( len, ply )
		ROUND_TIMER = net.ReadInt( 16 )
	end)
end

local rounds_played = 0

function ROUND:GetRoundsPlayed()
	return rounds_played
end

local DeathTeamStreaks = {}
local DeathTimes = {}

-- handle death avoidance here, using the functions defined in init.lua

local function checkdeathavoid( ply )
	print("Checking for death avoid... "..ply:Nick())
	local avoided = (ply:Team() == TEAM_DEATH and ply:Alive()) and true or false
	if avoided == true and (ROUND:GetCurrent() == ROUND_PREP or ROUND:GetCurrent() == ROUND_ACTIVE) and #player.GetAllPlaying() > 2 then
		DR:PunishDeathAvoid( ply, GetConVarNumber("deathrun_death_avoid_punishment") )
		DR:ChatBroadcast("Player "..ply:Nick().." will be punished for attempting to avoid being on the Death team!")
	end
end
hook.Add("PlayerDisconnected", "DeathrunWatchDeathAvoid", checkdeathavoid)


hook.Add("PlayerInitialSpawn", "DeathrunCleanupSinglePlayer", function( ply )
	ROUND:SyncTimerPlayer( ply )
	if #player.GetAll() <= 1 then
		game.CleanUpMap()
		DR:ChatBroadcast("Cleaned up the map.")
	end
end)
ROUND:AddState( ROUND_WAITING,
	function()
		print("Round State: WAITING")

		hook.Call("DeathrunBeginWaiting", nil )

		if SERVER then
			for k,ply in ipairs(player.GetAllPlaying()) do
				ply:StripWeapons()
				ply:StripAmmo()
				ply:SetTeam( TEAM_RUNNER )
				ply:Spawn()
			end

			timer.Create("DeathrunWaitingStateCheck", 5, 0, function()
				if #player.GetAllPlaying() >= 2 then
					ROUND:RoundSwitch( ROUND_PREP )
					timer.Destroy( "DeathrunWaitingStateCheck" )
				end
			end)
		end

	end,
	function()
	--thinking
	end,
	function()
		print("Exiting: WAITING")
	end
)
ROUND:AddState( ROUND_PREP,
	function()
		print("Round State: PREP")
		hook.Call("DeathrunBeginPrep", nil )
		if CLIENT then
			if GetConVar("deathrun_round_cues"):GetBool() == true then
				surface.PlaySound("ui/achievement_earned.wav") -- round start cue
			end
		end

		if SERVER then

			game.CleanUpMap()

			timer.Simple( PrepDuration:GetInt(), function()
				ROUND:RoundSwitch( ROUND_ACTIVE )
			end)

			ROUND:SetTimer( PrepDuration:GetInt() )

			for k,ply in ipairs(player.GetAll()) do

				if not ply:ShouldStaySpectating() then -- for some reason we need to do this otherwise people spawn as spec when they shouldnt!
					ply:KillSilent()
					ply:SetTeam( TEAM_RUNNER )
				end
				DeathTeamStreaks[ply] = DeathTeamStreaks[ply] or 0
				DeathTimes[ply] = DeathTimes[ply] or 0
			end


			-- let's pick deaths at random, but ignore if they have been death the 2 previous rounds
			local deaths = {}
			local deathsNeeded = math.ceil(DeathRatio:GetFloat() * #player.GetAllPlaying())
			local runners = {}
			local pool = table.Copy( player.GetAllPlaying() )
			
			if deathsNeeded > DeathMax:GetInt() then
				deathsNeeded = DeathMax:GetInt()
			end

			-- get a list of players, ordered by how many death rounds they have had, lowest to highest
			local orderedlist = {}
			local unorderedlist = table.Copy(player.GetAllPlaying())

			for i = 1, #unorderedlist do

				local lowest = 9999999
				local lowestply = nil
				local lowestidx = 0

				for k,ply in pairs( unorderedlist ) do
					if DeathTimes[ply] < lowest then
						lowest = DeathTimes[ply]
						lowestply = ply
						lowestidx = k
					end
				end

				table.remove(unorderedlist, lowestidx)
				table.insert(orderedlist, lowestply)

			end

			print("\nList of Death counters:")
			PrintTable(orderedlist)

			local timesLooped = 0

			local punishmentpool = table.Copy( DR:GetOnlineBarredPlayers() )
			local orderedpool = table.Copy( orderedlist )

			-- remove players from orderedpool and pool if they have been death 2 rounds in a row
			for k, ply in ipairs(player.GetAllPlaying()) do
				local streak = DeathTeamStreaks[ ply ] or 0
				if streak > 0 then
					print(ply:Nick().." has a streak greater than 0, removing from pool(s).")
					table.RemoveByValue(orderedpool, ply)
					table.RemoveByValue(pool, ply)
				end
			end

			PrintTable( orderedpool )
			PrintTable( pool )

			while #deaths < deathsNeeded and timesLooped < 100 do

				if #punishmentpool > 0 then
					local ply = punishmentpool[#punishmentpool]
					
					DR:PardonDeathAvoid( ply, 1 )

					DR:ChatBroadcast( "Player "..ply:Nick().." is being punished for death avoidance! They have "..tostring(DR:GetDeathAvoid( ply )).." Death rounds remaining." )

					table.insert( deaths, punishmentpool[#punishmentpool] ) -- add players to the deaths if they are being punishd for death avoid
					table.RemoveByValue( pool, punishmentpool[#punishmentpool] )
					table.remove( punishmentpool, #punishmentpool )

				elseif #orderedpool > 0 then
					local ply = orderedpool[1]
					print("A death has been chosen through orderedpool: "..tostring(ply))
					table.insert( deaths, ply )
					table.remove( orderedpool, 1 )
					table.RemoveByValue( pool, ply )
				else
					local randnum = math.random(#pool)
					if pool[randnum] then
						print("A death has been chosen: "..tostring(pool[randnum]))
						table.insert( deaths, pool[randnum] )
						table.remove( pool, randnum )
					end
				end

				timesLooped = timesLooped + 1
			end

			if timesLooped >= 100 then
				print("---WARNING!!!!! WHILE LOOP EXCEEDED ALLOWED LOOP TIME!!!!-----")
			end

			runners = table.Copy( pool )
			pool = {}
			
			--now, spawn all deaths
			for k,death in ipairs( deaths ) do
				death:StripWeapons()
				death:StripAmmo()

				death:SetTeam( TEAM_DEATH )
				death:Spawn()
			end

			--now, spawn all runners
			for k,runner in ipairs( runners ) do
				runner:StripWeapons()
				runner:StripAmmo()

				runner:SetTeam( TEAM_RUNNER )
				runner:Spawn()
			end

			-- make sure nobody is dead??????
			for k,v in ipairs(player.GetAllPlaying()) do
				if not v:Alive() then
					v:Spawn()
				end
			end

			for k,ply in ipairs(player.GetAll()) do
				DeathTimes[ply] = DeathTimes[ply] or 0
				if ply:Team() == TEAM_DEATH then
					DeathTimes[ply] = DeathTimes[ply] + 1
					DeathTeamStreaks[ply] = DeathTeamStreaks[ply] + 1
				else
					DeathTeamStreaks[ply] = 0
				end
				print( ply:Nick(), team.GetName(ply:Team()) )
			end

			print("\nDeathTimes table:")
			for k,v in pairs(DeathTimes) do
				if not IsValid( k ) then
					DeathTimes[k] = nil
				else
					print( k:Nick(), v )
				end
			end
			print("\nDeathTeamStreaks:")
			PrintTable( DeathTeamStreaks )

		end
	end,
	function()

	end,
	function()
		print("Exiting: PREP")
	end
)
ROUND:AddState( ROUND_ACTIVE,
	function()
		print("Round State: ACTIVE")
		hook.Call("DeathrunBeginActive", nil )
		if SERVER then
			ROUND:SetTimer( GetConVarNumber("deathrun_round_duration") )

			timer.Create("DeathrunAutoslay", GetConVarNumber("deathrun_autoslay_delay") + 5, 1, function()
				for k,v in ipairs(player.GetAllPlaying()) do
					local idletime = DR:CheckIdleTime( v )
					print( v, idletime )
					if idletime > GetConVarNumber("deathrun_autoslay_delay") then
						net.Start("DeathrunSpectatorNotification")
						net.Send( v )
						if v:Team() == TEAM_DEATH then
							DR:ChatBroadcast("Player "..v:Nick().." went AFK during a Death round! They will be punished.")
							DR:PunishDeathAvoid( v, GetConVarNumber("deathrun_death_avoid_punishment") )
						end
						v:ConCommand("deathrun_spectate_only 1")
					end
				end
			end)
		end
	end,
	function()
		if SERVER then
			local playing = player.GetAllPlaying()

			if #playing < 2 then
				ROUND:RoundSwitch( ROUND_WAITING )
				return
			end
			local deaths = {}
			local runners = {}

			for k,v in ipairs( playing ) do
				if v:Alive() then
					if v:Team() == TEAM_RUNNER then
						table.insert(runners, v)
					elseif v:Team() == TEAM_DEATH then
						table.insert( deaths, v )
					end
				end
			end

			if (#deaths == 0 and #runners == 0) or ROUND:GetTimer() == 0 then
				ROUND:FinishRound( WIN_STALEMATE )
			elseif #deaths == 0 then
				ROUND:FinishRound( WIN_RUNNER )
			elseif #runners == 0 then
				ROUND:FinishRound( WIN_DEATH )
			end

		end
	end,
	function()
		print("Exiting: ACTIVE")
	end
)
ROUND:AddState( ROUND_OVER,
	function()
		print("Round State: OVER")
		hook.Call("DeathrunBeginOver", nil )
		rounds_played = rounds_played + 1
		if SERVER then
			if not hook.Call("DeathrunShouldMapSwitch", nil, rounds_played) and ( rounds_played < GetConVarNumber("deathrun_round_limit") ) then
				DR:ChatBroadcast("Round "..tostring(rounds_played).." over. "..tostring(GetConVarNumber("deathrun_round_limit") - rounds_played).." rounds to go!")
				ROUND:SetTimer(GetConVarNumber("deathrun_finishtime_duration") )
				timer.Simple(GetConVarNumber("deathrun_finishtime_duration") , function()
					ROUND:RoundSwitch( ROUND_PREP )
				end)
			else
				--DR:ChatBroadcast("Round limit reached. Initiating RTV...")
				timer.Simple(3, function()
					if not hook.Call("DeathrunStartMapvote", nil, rounds_played) then
						MV:BeginMapVote()
					end
				end)
			end
		end
	end,
	function()
	--thinking
	end,
	function()
		print("Exiting: OVER")
	end
)

if SERVER then

	hook.Add("PlayerDeath", "DeathrunMVPs", function(ply, inflictor, attacker)
		if attacker:IsPlayer() then
			attacker.KillsThisRound = attacker.KillsThisRound or 0
			if ply ~= attacker then
				attacker.KillsThisRound = attacker.KillsThisRound + 1
			end
		end
	end)

	hook.Add("DeathrunBeginActive", "DeathrunMVPs", function()
		for k,v in ipairs( player.GetAll() ) do
			v.KillsThisRound = 0
		end
	end)

	function ROUND:FinishRound( winteam )
		ROUND:RoundSwitch( ROUND_OVER )
		DR:ChatBroadcast("Round over! "..( winteam == WIN_RUNNER and team.GetName( TEAM_RUNNER ).." win!" or winteam == WIN_DEATH and team.GetName( TEAM_DEATH ).." win!" or "Stalemate! Unbelievable!" ) )
		--calculate MVPs
		net.Start("DeathrunSendMVPs")

		local mvps = {}

		local mostkills = 0
		local mostkillsmvp = nil

		local players = player.GetAll()

		for k,v in ipairs( players ) do
			if v:Team() == winteam then
				if v:Alive() then
					table.insert(mvps,v:Nick().." survived the round!")
				end
				if v.KillsThisRound > mostkills then
					mostkills = v.KillsThisRound
					mostkillsmvp = v
				end
			end
		end

		if mostkillsmvp and winteam == TEAM_RUNNER then
			table.insert(mvps, mostkillsmvp:Nick().." got ".. (mostkills) ..(mostkills > 1 and " kills!" or " kill!") )
		end

		local data = {}
		data.mvps = table.Copy(mvps)
		data.duration = GetConVarNumber("deathrun_finishtime_duration")  -- how long we want to show this screen for, in seconds (temporary?)
		data.winteam = winteam

		net.WriteTable( data )
		net.Broadcast()

		hook.Call("DeathrunRoundWin", nil, winteam)

		-- compatibility
		hook.Call("OnRoundSet", nil, ROUND_OVER, winteam ~= WIN_STALEMATE and winteam or 123)
	end

	--initial round

	hook.Add("InitPostEntity", "DeathrunInitialRoundState", function()
		ROUND:RoundSwitch( ROUND_WAITING )
	end)
end

CreateConVar("deathrun_finish_balloons", "12", defaultFlags, "How many balloons to spawn when the player finishes the map?")

hook.Add("DeathrunPlayerFinishMap", "Balloons", function( ply )
	if GetConVarNumber("deathrun_finish_balloons") > 0 then
		for i = 1, GetConVarNumber("deathrun_finish_balloons") do

			local dir = Vector( math.random(-100,100),math.random(-100,100),math.random(-100,100) )
			dir:Normalize()

			local balloon = ents.Create("ent_deathrun_balloon")
			balloon:Spawn()
			balloon:SetAngles( Angle(0, math.random(-180,180), 0 ) )

			local td = {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + dir * 92,
				filter = ply,
				mins = balloon:OBBMins(),
				maxs = balloon:OBBMaxs(),
			}

			local tr = util.TraceHull( td )

			if tr.HitPos:Distance( td.start ) > 30 then
				balloon:SetPos( tr.HitPos )
				balloon:GetPhysicsObject():ApplyForceCenter( dir * 2.5 )
			else
				balloon:Remove()
			end

		end
	end

end)