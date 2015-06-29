--hexcolor
AddCSLuaFile( "hexcolor.lua" )

include( "hexcolor.lua" )

--derma
AddCSLuaFile( "cl_derma.lua" )


-- base
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "config.lua" )

include("config.lua")

include( "shared.lua" )

-- scoreboard
AddCSLuaFile("cl_scoreboard.lua")


-- Round System
AddCSLuaFile( "roundsystem/sh_round.lua" )
AddCSLuaFile( "roundsystem/cl_round.lua" )
AddCSLuaFile( "sh_definerounds.lua" )

include( "roundsystem/sh_round.lua" )
include( "roundsystem/sv_round.lua" )
include( "sh_definerounds.lua" )

--player
include( "sv_player.lua" )


function GM:PlayerInitialSpawn( ply )

	ply.FirstSpawn = true

end

function GM:PlayerSpawn( ply, spec )
	ply:SetNoCollideWithTeammates( true ) -- so we don't block eachother's bhopes

	if ply.FirstSpawn == true then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
		ply.FirstSpawn = false
	elseif ply.JustDied == true then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	else
		ply:StopSpectate()

		ply:SetupHands()

		GAMEMODE:PlayerLoadout( ply )
	end
end

function GM:PlayerLoadout( ply )

	ply:StripWeapons()
	ply:StripAmmo()

	ply:SetModel("models/player/group01/male_07.mdl")
	ply:Give("weapon_crowbar")

	local teamcol = team.GetColor( ply:Team() )
	--print(teamcol)
	local playercol = Vector( teamcol.r/255, teamcol.g/255, teamcol.b/255 )

	ply:SetPlayerColor( playercol )
	
end

function GM:PlayerDeath( ply )
	timer.Simple(5, function()
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
	if target:IsPlayer() and attacker:IsPlayer() then
		if target:Team() == attacker:Team() then
			dmginfo:SetDamage(0)
		end
	end
end