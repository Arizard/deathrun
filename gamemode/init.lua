--hexcolor
AddCSLuaFile( "hexcolor.lua" )

include( "hexcolor.lua" )

--derma
AddCSLuaFile( "cl_derma.lua" )


-- base
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
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

-- map votes
AddCSLuaFile( "mapvote/sh_mapvote.lua" )
AddCSLuaFile( "mapvote/cl_mapvote.lua" )

include( "mapvote/sh_mapvote.lua" )
include( "mapvote/sv_mapvote.lua" )

--player
include( "sv_player.lua" )

util.AddNetworkString("DeathrunChatMessage")
util.AddNetworkString("DeathrunSyncMutelist")

function GM:PlayerInitialSpawn( ply )

	ply.FirstSpawn = true

end

function GM:PlayerSpawn( ply, spec )
	ply:SetNoCollideWithTeammates( true ) -- so we don't block eachother's bhopes
	ply:SetLagCompensated( true )
	if ply.FirstSpawn == true then
		if ROUND:GetCurrent() == ROUND_ACTIVE or ROUND:GetCurrent() == ROUND_OVER then
			GAMEMODE:PlayerSpawnAsSpectator( ply )
		else
			ply:SetTeam( TEAM_RUNNER )
		end
		ply:SetupHands()
		GAMEMODE:PlayerLoadout( ply )
		ply.FirstSpawn = false
	elseif ply.JustDied == true then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	else
		ply:StopSpectate()

		ply:SetupHands()

		GAMEMODE:PlayerLoadout( ply )
	end

	if ply:Team() ~= TEAM_RUNNER and ply:Team() ~= TEAM_DEATH and ply:Team() ~= TEAM_SPECTATOR then ply:SetTeam( TEAM_RUNNER ) end

	local spawns = team.GetSpawnPoints( ply:Team() )
	if #spawns > 0 then
		ply:SetPos( table.Random(spawns):GetPos() )
	end
end

function GM:PlayerLoadout( ply )

	ply:StripWeapons()
	ply:StripAmmo()

	ply:SetModel("models/player/group01/male_07.mdl")
	ply:Give("weapon_knife")

	local teamcol = team.GetColor( ply:Team() )
	--print(teamcol)
	local playercol = Vector( teamcol.r/255, teamcol.g/255, teamcol.b/255 )

	ply:SetPlayerColor( playercol )

	-- run speeds and jump powah
	ply:SetRunSpeed( 250 )
	ply:SetWalkSpeed( 250 )
	ply:SetJumpPower( 200 )
	
end

function GM:PlayerDeath( ply )
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

		end
	end)
end

function GM:PlayerDeathThink( ply )
	return false
end

function GM:CanPlayerSuicide( ply )
	if not ply:GetSpectate() then
		return true
	end
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
			print("Attacked teammate")
			--dmginfo:SetDamage(0)
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
