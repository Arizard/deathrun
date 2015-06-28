
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

-- Round System
AddCSLuaFile( "roundsystem/sh_round.lua" )
AddCSLuaFile( "roundsystem/cl_round.lua" )
AddCSLuaFile( "sh_definerounds.lua" )

include( "roundsystem/sh_round.lua" )
include( "roundsystem/sv_round.lua" )
include( "sh_definerounds.lua" )


function GM:PlayerLoadout( ply )

	ply:Give("weapon_crowbar")
	
end

