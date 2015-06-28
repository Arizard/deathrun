
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_round.lua" )
AddCSLuaFile( "cl_round.lua" )

include( "shared.lua" )
include( "sh_round.lua" )
include( "sv_round.lua" )


function GM:PlayerLoadout( ply )

	ply:Give("weapon_crowbar")
	
end