ROUND_WAITING = 3
ROUND_PREP = 4
ROUND_ACTIVE = 5
ROUND_OVER = 6

ROUND:AddState( ROUND_WAITING,
	function()
		print("Round State: WAITING")
	end,
	function()
	--thinking
	end,
	function()
		print("Exiting: WAITING")
	end
)
ROUND:AddState( ROUND_PREP,
	function()
		print("Round State: PREP")
	end,
	function()
	--thinking
	end,
	function()
		print("Exiting: PREP")
	end
)
ROUND:AddState( ROUND_ACTIVE,
	function()
		print("Round State: ACTIVE")
	end,
	function()
	--thinking
	end,
	function()
		print("Exiting: ACTIVE")
	end
)
ROUND:AddState( ROUND_OVER,
	function()
		print("Round State: OVER")
	end,
	function()
	--thinking
	end,
	function()
		print("Exiting: OVER")
	end
)