
ROUND = {}

-- Create round state constants

ROUND_CURRENT = -1 -- default to -1

ROUND_TABLE = {} -- heheh

function ROUND:AddState( r, fOnEnter, fOnThink, fOnExit ) -- constant int, and 3 functions
	ROUND_TABLE[r] = {
		OnEnter = fOnEnter,
		OnThink = fOnThink,
		OnExit = fOnExit
	}
end

function ROUND:RoundThink( r )
	if not ROUND_TABLE[r] then return end

	ROUND_TABLE[r].OnThink()
end

function ROUND:GetCurrent()
	return ROUND_CURRENT
end

hook.Add("Think", "ROUND_THINK", function() -- keep thinking for the current round, i.e. to check for living players
	ROUND:RoundThink( ROUND_CURRENT )
end)

