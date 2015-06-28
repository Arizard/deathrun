include("shared.lua")

ROUND = {}

-- Create round state constants

ROUND_WAITING = 10 -- start from 10 -- waiting for players to join -> prepare
ROUND_PREPARE = 11 -- Players have spawned, cannot move yet -> active
ROUND_ACTIVE = 12 -- Players are currently playing -> over
ROUND_OVER = 13 -- either team has won, or the time has run out, and we are waiting for the round to restart -> prepare

ROUND_CURRENT = -1 -- default to -1

ROUND_TABLE = {} -- heheh

ROUND_TABLE[ROUND_WAITING] = {
	OnEnter = function()
		print("Entered ROUND_WAITING")
	end,
	OnThink = function()
		-- this runs every think
	end,
	OnExit = function()
		print("Exited ROUND_WAITING")
	end
}

ROUND_TABLE[ROUND_PREPARE] = {
	OnEnter = function()
		print("Entered ROUND_PREPARE")
	end,
	OnThink = function()
		-- this runs every think
	end,
	OnExit = function()
		print("Exited ROUND_PREPARE")
	end
}

ROUND_TABLE[ROUND_ACTIVE] = {
	OnEnter = function()
		print("Entered ROUND_ACTIVE")
	end,
	OnThink = function()
		-- this runs every think
	end,
	OnExit = function()
		print("Exited ROUND_ACTIVE")
	end
}

ROUND_TABLE[ROUND_OVER] = {
	OnEnter = function()
		print("Entered ROUND_OVER")
	end,
	OnThink = function()
		-- this runs every think
	end,
	OnExit = function()
		print("Exited ROUND_OVER")
	end
}

function ROUND:RoundSwitch( r )
	local old = ROUND_CURRENT
	local new = r

	ROUND_TABLE[old].OnExit()
	ROUND_TABLE[new].OnEnter()

	ROUND_CURRENT = new

	if SERVER then
		net.Start("ROUND_STATE")
		net.WriteInt( new, 16 )
		net.Broadcast()
	end
end

function ROUND:RoundThink( r )
	ROUND_TABLE[r].OnThink()
end

function ROUND:GetCurrent()
	return ROUND_CURRENT
end

hook.Add("Think", "ROUND_THINK", function() -- keep thinking for the current round, i.e. to check for living players
	ROUND:RoundThink( ROUND_CURRENT )
end