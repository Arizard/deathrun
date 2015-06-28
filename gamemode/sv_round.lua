include("shared.lua")
include("sh_round.lua")

-- create network strings for round state changes
util.AddNetworkString("ROUND_STATE")
-- send this each time round state changes so that the player can update themselves