GM.Name 	= "Deathrun"
GM.Author 	= "Arizard"
GM.Email 	= ""
GM.Website 	= "arizard.github.io"

function GM:Initialize()

	self.BaseClass.Initialize( self )
	
end

TEAM_RUNNER = 2
TEAM_DEATH = 3

function GM:CreateTeams()
	team.SetUp(TEAM_RUNNER, "Runners", DR.Colors.RunnerTeam, false)
	team.SetUp(TEAM_DEATH, "Deaths", DR.Colors.DeathTeam, false)

	team.SetSpawnPoint( TEAM_DEATH, "info_player_terrorist" )
	team.SetSpawnPoint( TEAM_RUNNER, "info_player_counterterrorist" )

	team.SetColor( TEAM_SPECTATOR, DR.Colors.Silver )
end

function player.GetAllPlaying()
	local pool = {}
	for k,ply in ipairs(player.GetAll()) do
		if ply then
			if not ply:ShouldStaySpectating() then
				table.insert(pool, ply)
			end
		end
	end
	return pool
end

hook.Add("SetupMove", "DeathrunDisableSpectatorSpacebar", function( ply, mv, cmd )
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )
	end

	if ply:Alive() then
		if ROUND:GetCurrent() == ROUND_PREP then
			--mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )
			mv:SetSideSpeed( 0 )
			mv:SetUpSpeed( 0 )
			mv:SetForwardSpeed( 0 )
		end
	end
end)