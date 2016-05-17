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

-- statistics
include("sh_statistics.lua")
AddCSLuaFile("sh_statistics.lua")

util.AddNetworkString("DeathrunChatMessage")
util.AddNetworkString("DeathrunSyncMutelist")
util.AddNetworkString("DeathrunNotification")
util.AddNetworkString("DeathrunSpectatorNotification")
util.AddNetworkString("DeathrunForceSpectator")

-- required configz
RunConsoleCommand("sv_friction", 8)
RunConsoleCommand("sv_sticktoground", 0)
RunConsoleCommand("sv_airaccelerate", 0)
RunConsoleCommand("sv_gravity", 800)

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

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE


hook.Add("PlayerInitialSpawn", "DeathrunPlayerInitialSpawn", function( ply )

	ply.FirstSpawn = true
	ply:SetTeam( TEAM_SPECTATOR )
	--ply:Spawn()
	DR:ChatBroadcast(ply:Nick().." has joined the server.")

end)

hook.Add("PlayerDisconnected", "DeathrunPlayerDisconnectMessage", function( ply )
	DR:ChatBroadcast( ply:Nick().." has left the server." )
end)

CreateConVar("deathrun_death_model", "models/player/monk.mdl", defaultFlags, "The default model for the Deaths." )
local deathModel = GetConVar( "deathrun_death_model" )

local dropWeaponsOnDeath = CreateConVar("deathrun_drop_weapons_on_death", 1, defaultFlags, "Should players drop weapons on death?")

hook.Add("PlayerSpawn", "DeathrunSetPlayerModels", function( ply )

	--if dropWeaponsOnDeath

	if ply:Team() == TEAM_DEATH then
		local mdl = deathModel:GetString()
		if string.sub( mdl, -4, -1 ) == ".mdl" then
			ply:SetModel( mdl )
		else
			print("The default death model is not a valid .mdl file ('"..mdl.."'). Please change the deathrun_death_model ConVar.")
		end
	elseif ply:Team() == TEAM_RUNNER then
	    ply:SetModel( table.Random( playermodels ) )
	end

	local mdl = hook.Call("ChangePlayerModel", nil, ply)
	if mdl then
		ply:SetModel( mdl )
	else
		if (not ply:GetModel()) or ply:GetModel() == "models/player.mdl" then -- don't override the current set model if there is one
			print("Player "..tostring(ply:Nick()).." did not have a model - setting them a new one.")
			ply:SetModel( table.Random( playermodels ) )
			
		end
	end
	
end)

local function SpawnSpectator( ply )
	ply:KillSilent()
	ply:SetTeam( TEAM_SPECTATOR )
	ply:BeginSpectate()

	return GAMEMODE:PlayerSpawnAsSpectator( ply )
end

DR.SpecBuffer = {}

hook.Add("PlayerSpawn", "DeathrunPlayerSpawn", function( ply )
	--print( ply:Nick(), "spectator only: "..tostring( ply:ShouldStaySpectating() ) )

	if GhostMode then -- GhostMode compatibility
		if ply:Team() == TEAM_GHOST then
			ply:StopSpectate()
			return
		end
	end

	if ply:ShouldStaySpectating() then
		return SpawnSpectator( ply )
	end

	ply:SetRenderMode( RENDERMODE_TRANSALPHA )

	ply:AllowFlashlight( true )

	ply:SetMoveType(MOVETYPE_WALK)

	ply:SetNoCollideWithTeammates( true ) -- so we don't block eachother's bhopes
	ply:SetLagCompensated( true )
	if ply.FirstSpawn == true then
		ply.FirstSpawn = false
		if ROUND:GetCurrent() == ROUND_ACTIVE or ROUND:GetCurrent() == ROUND_OVER then
			--print("firstspawn, spawning as spectator.")
			table.insert(DR.SpecBuffer, ply)
			timer.Simple(0, function() -- SUDDENTLY SPECTATOR IS MAGICALLY FIXED
				for k, ply in pairs( DR.SpecBuffer ) do
					if IsValid( ply ) then
						SpawnSpectator( ply )
						table.remove(DR.SpecBuffer, k)
					end
				end
			end)
			return SpawnSpectator( ply )
		else
			ply:SetTeam( TEAM_RUNNER )
		end
		hook.Call("PlayerLoadout", self, ply)
	elseif ply.JustDied == true then
		ply:BeginSpectate()
	elseif ply:ShouldStaySpectating() then
		return SpawnSpectator( ply )
	else
		ply:StopSpectate()
		hook.Call("PlayerLoadout", self, ply)
	end

	if ply:Team() ~= TEAM_RUNNER and ply:Team() ~= TEAM_DEATH and ply:Team() ~= TEAM_SPECTATOR then ply:SetTeam( TEAM_RUNNER ) end

	local spawns = team.GetSpawnPoints( ply:Team() ) or {}
	if #spawns > 0 then
		ply:SetPos( table.Random(spawns):GetPos() )
	end

	-- if ply:GetSpectate() or ply:Team() == TEAM_SPECTATOR or ply:GetObserverMode() ~= OBS_MODE_NONE then
	-- 	return SpawnSpectator( ply )
	-- end
end)

function GM:PlayerSpawn( ply )

	return self.BaseClass:PlayerSpawn( ply )
end

CreateConVar("deathrun_death_sprint", "650", defaultFlags, "Sprint speed for Death team.")
CreateConVar("deathrun_starting_weapon", "weapon_crowbar", defaultFlags, "Starting weapon for both teams.")

function GM:PlayerLoadout( ply )

	ply:StripWeapons()
	ply:StripAmmo()

	ply:Give( GetConVarString("deathrun_starting_weapon") or "weapon_crowbar" )

	local teamcol = team.GetColor( ply:Team() )
	--print(teamcol)
	local playercol = Vector( teamcol.r/255, teamcol.g/255, teamcol.b/255 )

	ply:SetPlayerColor( playercol )

	-- run speeds and jump powah
	ply:SetRunSpeed( 250 )
	ply:SetWalkSpeed( 250 )
	ply:SetJumpPower( 290 )

	if ply:Team() == TEAM_DEATH then
		ply:SetRunSpeed( GetConVar("deathrun_death_sprint"):GetFloat() )	
	end

	ply:DrawViewModel( true )

	ply:SetupHands( ply )

	hook.Call("DeathrunPlayerLoadout", self, ply)

	return self.BaseClass:PlayerLoadout( ply )
	
end

hook.Add("AcceptInput", "DeathrunKillers", function( ent, input, activator, caller )
	ent.LastCaller = caller
end)

function GM:PlayerDeath( ply, inflictor, attacker )

	ply:Extinguish()
	-- some death sounds
	local deathsounds = {
		"vo/npc/male01/myarm01.wav",
		"vo/npc/male01/myarm02.wav",
		"vo/npc/male01/mygut02.wav",
		"vo/npc/male01/myleg01.wav",
		"vo/npc/male01/myleg02.wav",
		"vo/npc/male01/no01.wav",
		"vo/npc/male01/no02.wav",
		"vo/npc/male01/ohno.wav",
		"vo/npc/male01/ow01.wav",
		"vo/npc/male01/ow02.wav",
		"vo/npc/male01/pain04.wav",
		"vo/npc/male01/pain07.wav",
		"vo/npc/male01/pain08.wav",
		"vo/npc/male01/pain08.wav",
		"vo/npc/male01/hacks02.wav",
	}

	ply:EmitSound( table.Random(deathsounds), 400, 100, 1 )

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
				ply:SetupHands( randplay )
				ply:SetObserverMode( OBS_MODE_IN_EYE )
				ply:SetPos( randplay:GetPos() )
			end

			ply.JustDied = false

			hook.Call("DeathrunDeadToSpectator", GAMEMODE, ply)

		end
	end)

	if inflictor.LastCaller then
		if inflictor.LastCaller.User then
			attacker = inflictor.LastCaller.User
		end
	end

	hook.Call("DeathrunPlayerDeath", self, ply, inflictor, attacker) -- support for when traps kill players

	table.insert( DR.KillList, {ply, attacker} )
	
end

DR.KillList = {}

timer.Create("DeathrunSendKillList", 0.5,0,function()
	if #DR.KillList > 0 then
		local message = ""
		
		-- remove the invalid players
		for k,v in ipairs(DR.KillList) do
			if not IsValid(v[1]) then
				table.remove( DR.KillList, k )
			end
		end

		PrintTable( DR.KillList )

		if type(DR.KillList[1]) == "table" then

			local ply = DR.KillList[1][1]
			local att = DR.KillList[1][2]

			if not IsValid( ply ) then return end

			message = ply:Nick().." was killed"

			if IsValid(att) then
				if att:IsPlayer() then
					message = message.." by "..att:Nick().."!"
				else
					message = message.." by a mysterious cause!"
				end
			else
				message = message.."!"
			end

			DR:DeathNotification( message )

			table.remove( DR.KillList, 1 )
		end

		-- for i = 1, #DR.KillList do
		-- 	local ply = DR.KillList[i]
		-- 	if IsValid(ply) then
		-- 		if i < #DR.KillList-1 then
		-- 			message = message..(i == 1 and "" or " ")..ply:Nick()..","
		-- 			if i%4 == 0 then
		-- 				message = message.."%newline%"
		-- 			end
		-- 		elseif i == #DR.KillList - 1 then
		-- 			message = message.." "..ply:Nick().." and"
		-- 		else
		-- 			message = message.." "..ply:Nick()
		-- 		end
		-- 	end
		-- end
		-- message = message .. (#DR.KillList == 1 and " was" or " were").." killed!"
		-- DR:DeathNotification( message )
		-- DR.KillList = {}
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
	local ply = target
	local attacker = dmginfo:GetAttacker()

	if target:IsPlayer() then
		if ROUND:GetCurrent() == ROUND_WAITING or ROUND:GetCurrent() == ROUND_PREP then
			target:DeathrunChatPrint("You took "..tostring(dmginfo:GetDamage()).." damage.")
			dmginfo:SetDamage(0)
		end
	end
	if target:IsPlayer() and attacker:IsPlayer() then
		if target:Team() == attacker:Team() and target ~= attacker then
			--print("Attacked teammate")
			local od = dmginfo:GetDamage()
			dmginfo:SetDamage(0)

			hook.Call( "DeathrunTeamDamage", self, attacker, target, dmginfo, od)
			
		end
	end

	--damage sounds
	local dmg = dmginfo:GetDamage()
	if dmg > 0 then
		if dmginfo:GetDamageType() == DMG_DROWN then -- drowning noisess
			local drownsounds = {
				"player/pl_drown1.wav",
				"player/pl_drown2.wav",
				"player/pl_drown3.wav",
			}
			ply:EmitSound( table.Random( drownsounds ), 400, 100, 1 )
		else
			local painsounds = {

			}
		end
	end
end

-- player muting
CreateConVar("deathrun_alltalk", 1, defaultFlags, "Enable alltalk - 1 for enabled, 0 to stop living players from hearing dead players.")
local alltalk = GetConVar("deathrun_alltalk")
function GM:PlayerCanHearPlayersVoice( listener, talker )

	listener.mutelist = listener.mutelist or {}

	if table.HasValue( listener.mutelist, talker:SteamID() ) then
		return false -- dont transmit voices which are on the mutelist
	else
		if alltalk:GetBool() == false then
			if talker:GetSpectate() == true and listener:GetSpectate() == false then return false end
			if talker:Alive() == false and listener:Alive() == true then return false end
			if talker:GetObserverMode() ~= OBS_MODE_NONE and listener:GetObserverMode() == OBS_MODE_NONE then return false end
		end
		return true
	end

end
-- end player muting

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
	if ply:Team() == TEAM_DEATH then
		return 0 -- deaths keep killing themselves on deathrun_ramesses_revenge
	end

	local damage = math.max( 0, math.ceil( 0.2418*speed - 141.75 ) )
	return damage
end

-- Function Key Binds
hook.Add("ShowTeam", "DeathrunSettingsBind", function( ply ) ply:ConCommand("deathrun_open_settings") end)
hook.Add("ShowHelp", "DeathrunHelpBind", function( ply ) ply:ConCommand("deathrun_open_help") end)

local function IsCSSPrimary( wep )

	local prims = {
		"_rif_",
		"_shot_",
		"_mach_",
		"_smg_",
		"_snip_",
	}

	for i = 1,#prims do
		v = prims[i]
		if weapons.Get( wep:GetClass() ) ~= nil then
			if string.find( weapons.Get( wep:GetClass() ).WorldModel, v ) ~= nil then
				return true
			end
		end
	end

	return false

end

local function IsCSSSecondary( wep )

	if weapons.Get( wep:GetClass() ) ~= nil then
		if string.find( weapons.Get( wep:GetClass() ).WorldModel, "_pist_" ) ~= nil then
			return true 
		end
	else
		return false
	end

end

local stop_the_drop = {
	"weapon_fuckmeintheass",
	"weapon_fuckmesilly2_fuckmybigblackass",
	--"weapon_crowbar",
}

function DR:CanPlayerDropWeapon( ply, class )
	return ( not table.HasValue( stop_the_drop, class) )
end

concommand.Add("deathrun_dropweapon", function( ply, cmd, args)
	if ply:Alive() and ply:GetActiveWeapon() ~= nil and IsValid( ply:GetActiveWeapon() ) then
		if DR:CanPlayerDropWeapon( ply, ply:GetActiveWeapon():GetClass() ) then
			ply:DropWeapon( ply:GetActiveWeapon() )
		end
	end
end)

-- stop people whoring the weapons
hook.Add("PlayerCanPickupWeapon", "StopWeaponAbuseAustraliaSaysNo", function( ply, wep )

	if ply:Team() == TEAM_GHOST then return false end

	local class = wep:GetClass()
	local weps = ply:GetWeapons()
	local wepsclasses = {}
	local filledslots = {}

	local slot1, slot3 = 0,0

	local secondaries = 0
	local primaries = 0

	for k,v in ipairs(weps) do
		table.insert( wepsclasses, v:GetClass() )
		if v.Slot ~= nil then
			if v.Slot == 1 then
				slot1 = slot1 + 1
			end
			if v.Slot == 3 then
				slot3 = slot3 + 1
			end
		end
	end

	if wep.Slot == 1 and slot1 > 0 then return false end
	if wep.Slot == 3 and slot3 > 0 then return false end
	if table.HasValue(wepsclasses, class) then return false end


	

end)

-- Something to check how long it's been since the player last did something
hook.Add("FinishMove", "DeathrunIdleCheck", function( ply, mv )

	ply.LastActiveTime = ply.LastActiveTime or CurTime()

	-- when the player stands still, mv:GetButtons() == 0, at least in binary
	-- so we can check when no keys are being pressed, or when they keys haven't changed for a while
	ply.LastButtons = ply.LastButtons or mv:GetButtons()

	if (mv:GetButtons() ~= ply.LastButtons) then
		-- if there's a change in buttons, then they must not be afk.
		-- sometimes they can type +forward, but we know they are afk because it's constant +forward and no other keys
		ply.LastActiveTime = CurTime()
	end
	ply.LastButtons = mv:GetButtons()

end)

function DR:CheckIdleTime( ply ) -- return how long the player has been idle for
	return 0 -- hotfix to prevent autokick after 22-02-2016 update
	-- ply.LastActiveTime = ply.LastActiveTime or CurTime()
	-- return CurTime() - ply.LastActiveTime
end
local IdleTimer = CreateConVar("deathrun_idle_kick_time", 60*5, defaultFlags, "How many seconds each to wait before kicking idle players.")
timer.Create("CheckIdlePlayers", 0.95, 0, function()
	for k, ply in ipairs(player.GetAllPlaying()) do -- don't kick afk spectators or bots
		--print( ply:Nick(), DR:CheckIdleTime( ply ) )
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

local deathbarred_path = "deathrun/deathbarred2.txt"

if not file.Exists(deathbarred_path, "DATA") then
	file.Write(deathbarred_path,"")
end

DR.BarredPlayers = util.JSONToTable( file.Read(deathbarred_path, "DATA") ) or { ["STEAMID_EXAMPLE"] = { rounds = 3, lastpunish = os.time() } }
--PrintTable( DR.BarredPlayers )
--print("There are "..tostring(#DR.BarredPlayers).." players being punished for death avoidance.")

function DR:SaveDeathAvoid()
	for k,v in pairs( DR.BarredPlayers ) do -- remove all players with 0 rounds left
		if v.rounds == 0 or v.lastpunish < os.time() - 1*24*60*60 then -- remove all players punished 24 hours ago
			DR.BarredPlayers[k] = nil
		end
	end
	file.Write(deathbarred_path,util.TableToJSON( DR.BarredPlayers ) )
	--PrintTable( DR.BarredPlayers )
end

DR:SaveDeathAvoid()

hook.Add("PostCleanupMap", "SaveDeathAvoid", function()
	DR:SaveDeathAvoid()
end)

function DR:PunishDeathAvoid( ply, amt )
	local id = "id"..tostring( ply:SteamID64() )
	DR.BarredPlayers[id] = DR.BarredPlayers[id] or { rounds = 0, lastpunish = os.time() } -- create the entry if it doesn't exist
	DR.BarredPlayers[id].rounds = math.Clamp( DR.BarredPlayers[id].rounds + (amt or 1), 0, 99 ) -- add 1 rounds
end

function DR:GetDeathAvoid( ply ) -- returns how many rounds they still need to serve as punishment
	local id = "id"..tostring( ply:SteamID64() )
	return (DR.BarredPlayers[id] ~= nil) and (DR.BarredPlayers[id].rounds or 0) or 0
end

function DR:GetOnlineBarredPlayers()
	local plys = {}
	for k,v in ipairs(player.GetAll()) do
		if DR:GetDeathAvoid( v ) > 0 and v:ShouldStaySpectating() == false then
			table.insert( plys, v )
		end
	end
	return plys
end

function DR:PardonDeathAvoid( ply, amt )
	local id = "id"..tostring( ply:SteamID64() )
	DR.BarredPlayers[id] = DR.BarredPlayers[id] or { rounds = 0, lastpunish = os.time() }
	DR.BarredPlayers[id].rounds = math.Clamp( DR.BarredPlayers[id].rounds - (amt or 1), 0, 99 )

	
end

concommand.Add("test_avoid", function( ply )
	DR:PunishDeathAvoid( ply, 10 )
end)

-- drowning compatibility
-- needs a timer to check for last time not submerged
-- if it exceeds <drowntime> then start taking 10 damage per second

CreateConVar("deathrun_drown_time","20", defaultFlags, "How long can a player stay submerged before drowning?")
timer.Create("DeathrunDrowningStuff", 0.5,0,function()
	for k,ply in ipairs( player.GetAll() ) do
		ply.LastOxygenTime = ply.LastOxygenTime or CurTime()

		if ply:WaterLevel() == 3 then --they are submerged completely
			local timeUnder = CurTime() - ply.LastOxygenTime
			if timeUnder > GetConVarNumber("deathrun_drown_time") then
				local di = DamageInfo()
				di:SetDamage( 5 )
				di:SetDamageType( DMG_DROWN )
				ply:TakeDamageInfo( di )
				ply:ViewPunch( Angle( 0,0,math.random(-1,1) ) )
			end
		else
			ply.LastOxygenTime = CurTime()
		end

		if not ply:Alive() or ply:GetSpectate() then
			ply.LastOxygenTime = CurTime()
		end
	end
end)

concommand.Add("deathrun_not_amused", function(ply)
	if not ply:Alive() or ply:GetSpectate() then return end

	ply.LastNotAmused = ply.LastNotAmused or CurTime()

	if CurTime() - ply.LastNotAmused > 3 then
		local not_amused = {}
		for i = 1, 40 do
			local path = "vo/npc/male01/answer"
			if i < 10 then
				if i == 6 then i = 5 end -- there is no answer06
				path = path .. "0" .. tostring(i) .. ".wav"
			else
				path = path .. tostring(i) .. ".wav"
			end
			table.insert( not_amused, path )
		end
		ply:EmitSound( table.Random(not_amused), 300, 100, 1 )
		ply.LastNotAmused = CurTime()
	end
end)

net.Receive("DeathrunForceSpectator", function(len, ply)
	if DR:CanAccessCommand( ply, "deathrun_force_spectate" ) then
		local targID = net.ReadString()
		local targ = nil

		for _, v in ipairs(player.GetAll()) do
			if targID == v:SteamID() then
				targ = v
			end
		end

		if targ ~= nil then
			targ:ConCommand("deathrun_spectate_only 1")
			ply:DeathrunChatPrint( "Forced "..targ:Nick().." to the spectator team!" )
		end
	else
		ply:DeathrunChatPrint( "You don't have access to this." )
	end
end)

local removeSpeed = CreateConVar("deathrun_disable_default_deathspeed", 0, defaultFlags, "Removes the player_speedmod entities from maps to disable the default deathspeed.")

function DR:RemoveSpeedMods()
	if removeSpeed:GetBool() == true then
		for k,v in ipairs( ents.FindByClass("player_speedmod") ) do
			SafeRemoveEntity( v )
		end
	end
end




hook.Add("PostCleanupMap", "RemoveSpeedMods", function()
	DR:RemoveSpeedMods()
end)

hook.Add("InitPostEntity", "RemoveSpeedMods", function()
	DR:RemoveSpeedMods()
end)
