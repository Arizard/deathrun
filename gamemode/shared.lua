
DR = {}

include("config.lua")

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