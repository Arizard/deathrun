ROUND_WAITING = 3
ROUND_PREP = 4
ROUND_ACTIVE = 5
ROUND_OVER = 6

if SERVER then
	RoundDuration = CreateConVar("deathrun_round_duration", 60*5, FCVAR_REPLICATED, "How many seconds each round should last, not including preptime.")
	PrepDuration = CreateConVar("deathrun_preptime_duration", 5, FCVAR_REPLICATED, "How many seconds preptime should go for.")
	DeathRatio = CreateConVar("deathrun_death_ratio", 0.15, FCVAR_REPLICATED, "What fraction of players are Deaths.")
end


ROUND:AddState( ROUND_WAITING,
	function()
		print("Round State: WAITING")

		if SERVER then
			for k,ply in ipairs(player.GetAllPlaying()) do
				ply:StripWeapons()
				ply:StripAmmo()

				ply:SetTeam( TEAM_RUNNER )
				ply:Spawn()
			end

		
			timer.Create("DeathrunWaitingStateCheck", 5, 0, function()
				print("Waiting for players...", #player.GetAllPlaying() )
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
		if SERVER then
			game.CleanUpMap()

			timer.Simple( PrepDuration:GetInt(), function()
				ROUND:RoundSwitch( ROUND_ACTIVE )
			end)

			for k,ply in ipairs(player.GetAll()) do
				if not ply:ShouldStaySpectating() then -- for some reason we need to do this otherwise people spawn as spec when they shouldnt!
					ply:SetTeam( TEAM_RUNNER )
				end
			end

			-- let's pick deaths at random, but ignore if they have been death the 2 previous rounds
			local deaths = {}
			local deathsNeeded = math.ceil(DeathRatio:GetFloat() * #player.GetAllPlaying())
			local runners = {}
			local pool = table.Copy( player.GetAllPlaying() )

			

			for k,v in ipairs(pool) do -- here we remove all the players who were ever death twice in a row
				v:KillSilent()

				v.DeathTeamStreak = v.DeathTeamStreak or 0

				if v.DeathTeamStreak > 1 then
					table.remove( pool, k )
					table.insert( runners, v )
				end
			end



			local timesLooped = 0

			while #deaths < deathsNeeded and timesLooped < 100 do
				local randnum = math.random(#pool)
				if pool[randnum] then
					table.insert( deaths, pool[randnum] )
					table.remove( pool, randnum )
				end
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

				local spawns = team.GetSpawnPoints( TEAM_DEATH )
				death:SetPos( table.Random(spawns):GetPos() )
			end

			--now, spawn all runners
			for k,runner in ipairs( runners ) do
				runner:StripWeapons()
				runner:StripAmmo()

				runner:SetTeam( TEAM_RUNNER )
				runner:Spawn()

				local spawns = team.GetSpawnPoints( TEAM_RUNNER )
				runner:SetPos( table.Random(spawns):GetPos() )
			end

			for k,ply in ipairs(player.GetAll()) do
				print( ply:Nick(), team.GetName(ply:Team()) )
			end

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
	end,
	function()
		if SERVER then
			if #player.GetAllPlaying() < 2 then
				ROUND:RoundSwitch( ROUND_WAITING )
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
	end,
	function()
	--thinking
	end,
	function()
		print("Exiting: OVER")
	end
)

if SERVER then
	function ROUND:FinishRound( winteam )
		ROUND:RoundSwitch( ROUND_OVER )
	end

	--initial round

	hook.Add("InitPostEntity", "DeathrunInitialRoundState", function()
		ROUND:RoundSwitch( ROUND_WAITING )
	end)
end