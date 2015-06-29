include("sh_round.lua")

net.Receive("ROUND_STATE", function(len, ply)
	local old = ROUND_CURRENT
	local new = net.ReadInt( 16 )

	if (not ROUND_TABLE[new]) then return end

	if (ROUND_TABLE[old]) then
		ROUND_TABLE[old].OnExit()
	end
	ROUND_TABLE[new].OnEnter()

	ROUND_CURRENT = new
end)