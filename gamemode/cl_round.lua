include("shared.lua")
include("sh_round.lua")

net.Receive("ROUND_STATE", function(len, ply)
	ROUND_CURRENT = net.ReadInt( 16 )
end)