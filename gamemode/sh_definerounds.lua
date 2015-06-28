ROUND_WAITING = 3
ROUND_PREP = 4
ROUND_ACTIVE = 5
ROUND_OVER = 6

if SERVER then
	RoundDuration = CreateConVar("deathrun_round_duration", 60*5, FCVAR_REPLICATED, "How many seconds each round should last, not including preptime.")
	PrepDuration = CreateConVar("deathrun_preptime_duration", 5, FCVAR_REPLICATED, "How many seconds preptime should go for.")
end


ROUND:AddState( ROUND_WAITING,
	function()
		print("Round State: WAITING")

		if SERVER then
			for k,ply in ipairs(player.GetAllPlaying()) do
				ply:StripWeapons()
				ply:StripAmmo()

				ply:SetTeam( TEAM_RUNNER )
				ply:Spawn()
				print("Spawning...",ply:Nick(),"on team", ply:Team() )
			end

		
			timer.Create("DeathrunWaitingStateCheck", 5, 0, function()
				print("Waiting for players...", #player.GetAllPlaying() )
				if #player.GetAllPlaying() >= 2 then
					ROUND:RoundSwitch( ROUND_PREP )
					timer.Destroy( "DeathrunWaitingStateCheck" )
				end
			end)
		end

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
		if SERVER then
			timer.Simple( PrepDuration:GetInt(), function()
				ROUND:RoundSwitch( ROUND_ACTIVE )
			end)
		end
	end,
	function()

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
		if SERVER then
			if #player.GetAllPlaying() < 2 then
				ROUND:RoundSwitch( ROUND_WAITING )
			end
		end
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

function ROUND:FinishRound( winteam )
	ROUND:RoundSwitch( ROUND_OVER )
end