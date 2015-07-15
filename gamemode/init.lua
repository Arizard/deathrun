if not file.Exists("deathrun", "DATA") then -- creates a folder in data for the gamemode
	file.CreateDir("deathrun")
end

--hexcolor
AddCSLuaFile( "hexcolor.lua" )

include( "hexcolor.lua" )

--derma
AddCSLuaFile( "cl_derma.lua" )


-- base
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_menus.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "config.lua" )


include("config.lua")

include( "shared.lua" )

-- scoreboard
AddCSLuaFile("cl_scoreboard.lua")

-- commands
include("sv_commands.lua")

-- Round System
AddCSLuaFile( "roundsystem/sh_round.lua" )
AddCSLuaFile( "roundsystem/cl_round.lua" )
AddCSLuaFile( "sh_definerounds.lua" )

include( "roundsystem/sh_round.lua" )
include( "roundsystem/sv_round.lua" )
include( "sh_definerounds.lua" )

-- zones
AddCSLuaFile( "zones/sh_zone.lua" )
AddCSLuaFile( "zones/cl_zone.lua" )

include( "zones/sh_zone.lua" )
include( "zones/sv_zone.lua" )


-- map votes
AddCSLuaFile( "mapvote/sh_mapvote.lua" )
AddCSLuaFile( "mapvote/cl_mapvote.lua" )

include( "mapvote/sh_mapvote.lua" )
include( "mapvote/sv_mapvote.lua" )

--player
include( "sv_player.lua" )

--button claiming
include( "sh_buttonclaiming.lua" )
AddCSLuaFile( "sh_buttonclaiming.lua" )

-- announcements
AddCSLuaFile( "cl_announcer.lua" )

-- pointshop support
include("sh_pointshopsupport.lua")
AddCSLuaFile( "sh_pointshopsupport.lua" )

util.AddNetworkString("DeathrunChatMessage")
util.AddNetworkString("DeathrunSyncMutelist")
util.AddNetworkString("DeathrunNotification")

-- required configz
RunConsoleCommand("sv_friction", 8)
RunConsoleCommand("sv_sticktoground", 0)

local playermodels = {
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_05.mdl",
	"models/player/group01/female_06.mdl",
}

hook.Add("PlayerInitialSpawn", "DeathrunPlayerInitialSpawn", function( ply )

	ply.FirstSpawn = true

	DR:ChatBroadcast(ply:Nick().." has joined the server.")

end)

hook.Add("PlayerDisconnected", "DeathrunPlayerDisconnectMessage", function( ply )
	DR:ChatBroadcast( ply:Nick().." has left the server." )
end)


function GM:PlayerSpawn( ply )
	ply:AllowFlashlight( true )

	local mdl = hook.Call("ChangePlayerModel", nil, ply)
	if mdl then
		ply:SetModel( mdl )
	else
		ply:SetModel( table.Random( playermodels ) )
	end
	ply:SetNoCollideWithTeammates( true ) -- so we don't block eachother's bhopes
	ply:SetLagCompensated( true )
	if ply.FirstSpawn == true then
		if ROUND:GetCurrent() == ROUND_ACTIVE or ROUND:GetCurrent() == ROUND_OVER then
			--ply:KillSilent()
			GAMEMODE:PlayerSpawnAsSpectator( ply )
		else
			ply:SetTeam( TEAM_RUNNER )
		end
		ply:SetupHands()
		hook.Call("PlayerLoadout", self, ply)
		ply.FirstSpawn = false
	elseif ply.JustDied == true then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	elseif ply:ShouldStaySpectating() then
		--ply:KillSilent()
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	else
		ply:StopSpectate()

		ply:SetupHands( ply )

		hook.Call("PlayerLoadout", self, ply)
	end

	if ply:Team() ~= TEAM_RUNNER and ply:Team() ~= TEAM_DEATH and ply:Team() ~= TEAM_SPECTATOR then ply:SetTeam( TEAM_RUNNER ) end

	local spawns = team.GetSpawnPoints( ply:Team() ) or {}
	if #spawns > 0 then
		ply:SetPos( table.Random(spawns):GetPos() )
	end

	if ply:GetSpectate() or ply:Team() == TEAM_SPECTATOR or ply:GetObserverMode() ~= OBS_MODE_NONE then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	end

end

function GM:PlayerLoadout( ply )

	ply:StripWeapons()
	ply:StripAmmo()

	ply:Give("weapon_knife")

	local teamcol = team.GetColor( ply:Team() )
	--print(teamcol)
	local playercol = Vector( teamcol.r/255, teamcol.g/255, teamcol.b/255 )

	ply:SetPlayerColor( playercol )

	-- run speeds and jump powah
	ply:SetRunSpeed( 250 )
	ply:SetWalkSpeed( 250 )
	ply:SetJumpPower( 200 )

	ply:DrawViewModel( true )

	hook.Call("DeathrunPlayerLoadout", self, ply)
	
end

function GM:PlayerDeath( ply )

	ply:SetupHands( nil )
	ply:DrawViewModel( false )

	if ply:Team() == TEAM_SPECTATOR then 
		ply:Spawn()
		ply:BeginSpectate()
		return
	end

	timer.Simple(5, function()
		if not IsValid( ply ) then return end -- incase they die and disconnect, prevents console errors.
		if not ply:Alive() then

			ply.JustDied = true
			--ply:SetTeam( TEAM_SPECTATOR )
			--ply:Spawn() -- spawn then so we can put them in spectator while keeping their team
			ply:BeginSpectate()
		
			local pool = {}
			for k,ply in ipairs(player.GetAll()) do
				if ply:Alive() and not ply:GetSpectate() then
					table.insert(pool, ply)
				end
			end

			
			if #pool > 0 then
				local randplay = table.Random(pool)
				ply:SpectateEntity( randplay )
				ply:SetObserverMode( OBS_MODE_IN_EYE )
				ply:SetPos( randplay:GetPos() )
			end

			ply.JustDied = false

			hook.Call("DeathrunDeadToSpectator", GAMEMODE, ply)

		end
	end)

	table.insert( DR.KillList, ply )
end

DR.KillList = {}

timer.Create("DeathrunSendKillList", 1.5,0,function()
	if #DR.KillList > 0 then
		local message = ""
		
		-- remove the invalid players
		for k,v in ipairs(DR.KillList) do
			if not IsValid(v) then
				table.remove( DR.KillList, k )
			end
		end

		for i = 1, #DR.KillList do
			local ply = DR.KillList[i]
			if IsValid(ply) then
				if i < #DR.KillList-1 then
					message = message..(i == 1 and "" or " ")..ply:Nick()..","
					if i%4 == 0 then
						message = message.."%newline%"
					end
				elseif i == #DR.KillList - 1 then
					message = message.." "..ply:Nick().." and"
				else
					message = message.." "..ply:Nick()
				end
			end
		end
		message = message .. (#DR.KillList == 1 and " was" or " were").." killed!"
		DR:DeathNotification( message )
		DR.KillList = {}
	end
end)

function DR:DeathNotification( msg )
	net.Start("DeathrunNotification")
	net.WriteString( msg )
	net.Broadcast( )
end

function GM:PlayerDeathThink( ply )
	return false
end

function GM:CanPlayerSuicide( ply )

	-- merge from Jerpy
	if (not ply:Alive()) or (ply:GetSpectate()) then return false end -- don't let dead players or spectators suicide
	if ply:Team() == TEAM_DEATH then return false end -- never allow suicide on death team
	if ROUND:GetCurrent() == ROUND_PREP then return false end -- players cannot suicide during round prep time

	return self.BaseClass:CanPlayerSuicide( ply )
end

-- damage hooks
function GM:EntityTakeDamage( target, dmginfo )
	local attacker = dmginfo:GetAttacker()

	if target:IsPlayer() then
		if ROUND:GetCurrent() == ROUND_WAITING or ROUND:GetCurrent() == ROUND_PREP then
			target:DeathrunChatPrint("You took "..tostring(dmginfo:GetDamage()).." damage.")
			dmginfo:SetDamage(0)
		end
	end
	if target:IsPlayer() and attacker:IsPlayer() then
		if target:Team() == attacker:Team() then
			--print("Attacked teammate")
			local od = dmginfo:GetDamage()
			dmginfo:SetDamage(0)

			hook.Call( "DeathrunTeamDamage", self, attacker, target, dmginfo, od)
			
		end
	end
end

-- player muting
function GM:PlayerCanHearPlayersVoice( listener, talker )

	listener.mutelist = listener.mutelist or {}

	if table.HasValue( listener.mutelist, talker:SteamID() ) then
		return false -- dont transmit voices which are on the mutelist
	else
		return true
	end

end

concommand.Add("deathrun_toggle_mute", function(ply, cmd, args)
	local id = args[1]
	if not id then return end

	ply.mutelist = ply.mutelist or {}

	if table.HasValue( ply.mutelist, id ) then
		for k,v in ipairs(ply.mutelist) do
			if v == id then 
				table.remove( ply.mutelist, k )
				ply:DeathrunChatPrint( "Player was unmuted." ) 
			end
		end
	else
		table.insert( ply.mutelist, id )
		ply:DeathrunChatPrint( "Player was muted." )
	end

	net.Start("DeathrunSyncMutelist")
	net.WriteTable( ply.mutelist )
	net.Send( ply )

end)

concommand.Add("strip", function(ply)
	ply:StripWeapons()
end)

function GM:GetFallDamage( ply, speed )
	local dmg = hook.Call("DeathrunFallDamage", self, ply, speed)
	if dmg ~= nil then
		return dmg
	end
	return speed/8
end

-- Function Key Binds
hook.Add("ShowTeam", "DeathrunSettingsBind", function( ply ) ply:ConCommand("deathrun_open_settings") end)
hook.Add("ShowHelp", "DeathrunHelpBind", function( ply ) ply:ConCommand("deathrun_open_help") end)

-- stop people whoring the weapons
hook.Add("PlayerCanPickupWeapon", "StopWeaponAbuseAustraliaSaysNo", function( ply, wep )
	local class = wep:GetClass()
	local weps = ply:GetWeapons()
	local wepsclasses = {}
	local filledslots = {}
	for k,v in ipairs(weps) do
		table.insert( wepsclasses, v:GetClass() )
	end
	if table.HasValue(wepsclasses, class) then return false end
end)

-- Something to check how long it's been since the player last did something
hook.Add("FinishMove", "DeathrunIdleCheck", function( ply, mv )

	ply.LastActiveTime = ply.LastActiveTime or CurTime()

	ply.LastAngles = ply.LastAngles or ply:EyeAngles()
	local dang = ply.LastAngles - ply:EyeAngles() -- use dang:IsZero() to check if it's changed


	-- when the player stands still, mv:GetButtons() == 0, at least in binary
	-- so we can check when no keys are being pressed, or when they keys haven't changed for a while
	ply.LastButtons = ply.LastButtons or mv:GetButtons()

	if (mv:GetButtons() ~= ply.LastButtons) or (not dang:IsZero()) then
		-- if there's a change in angle or a change in buttons, then they must not be afk.
		-- sometimes they can type +forward, but we know they are afk because it's constant +forward and no other keys
		ply.LastActiveTime = CurTime()
	end

	ply.LastAngles = ply:EyeAngles()
	ply.LastButtons = mv:GetButtons()

end)

function DR:CheckIdleTime( ply ) -- return how long the player has been idle for
	ply.LastActiveTime = ply.LastActiveTime or CurTime()
	return CurTime() - ply.LastActiveTime
end
local IdleTimer = CreateConVar("deathrun_idle_kick_time", 60*4.5, FCVAR_REPLICATED, "How many seconds each to wait before kicking idle players.")
timer.Create("CheckIdlePlayers", 0.95, 0, function()
	for k, ply in ipairs(player.GetAllPlaying()) do -- don't kick afk spectators or bots
		if math.floor(DR:CheckIdleTime( ply )) == math.floor(IdleTimer:GetInt() -25) then
			ply:DeathrunChatPrint("If you do not move in 25 seconds, you will be kicked from the server due to being idle.")
		end
		if DR:CheckIdleTime( ply ) > IdleTimer:GetInt() and ply:SteamID() ~= "BOT" and (not ply:IsAdmin()) then
			ply:Kick("Kicked for being idle")
			DR:ChatBroadcast( ply:Nick().." was kicked for being idle too long." )
		end
	end
end)

-- timer.Create("TestIdleCheck", 1, 0, function()
-- 	for k, ply in ipairs(player.GetAll()) do
-- 		ply:DeathrunChatPrint( tostring(DR:CheckIdleTime( ply )).." seconds idle." )
-- 	end
-- end)

-- Punish death avoiders
-- Bar the player for the next 3 rounds if they disconnect or idle while death.

-- this stuff gets handled in sh_definerounds.lua and shared.lua
-- Barred players are not included in player.GetAllPlaying()

if not file.Exists("deathrun/deathbarred.txt", "DATA") then
	file.Write("deathrun/deathbarred.txt","")
end

DR.BarredPlayers = util.JSONToTable( file.Read("deathrun/deathbarred.txt", "DATA") ) or { ["STEAMID_EXAMPLE"] = 3 }
PrintTable( DR.BarredPlayers )

function DR:SaveDeathAvoid()
	file.Write("deathrun/deathbarred.txt",util.TableToJSON( DR.BarredPlayers ) )
	PrintTable( DR.BarredPlayers )
end

DR:SaveDeathAvoid()

function DR:PunishDeathAvoid( ply, amt )
	local id = "id"..tostring( ply:SteamID64() )
	DR.BarredPlayers[id] = DR.BarredPlayers[id] or 0 -- create the entry if it doesn't exist
	DR.BarredPlayers[id] = DR.BarredPlayers[id] + (amt or 1) -- add 3 rounds

	DR:SaveDeathAvoid()
end

function DR:GetDeathAvoid( ply ) -- returns how many rounds they still need to serve as punishment
	local id = "id"..tostring( ply:SteamID64() )
	return DR.BarredPlayers[id] or 0
end

function DR:GetOnlineBarredPlayers()
	local plys = {}
	for k,v in ipairs(player.GetAll()) do
		if DR:GetDeathAvoid( v ) > 0 then
			table.insert( plys, v )
		end
	end
	return plys
end

function DR:PardonDeathAvoid( ply, amt )
	local id = "id"..tostring( ply:SteamID64() )
	DR.BarredPlayers[id] = DR.BarredPlayers[id] or 0
	DR.BarredPlayers[id] = DR.BarredPlayers[id] - (amt or 1)

	DR:SaveDeathAvoid()
end

concommand.Add("test_avoid", function( ply )
	DR:PunishDeathAvoid( ply, 10 )
end)