
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
	
end

function player.GetAllPlaying()
	local pool = {}
	for k,ply in ipairs(player.GetAll()) do
		if not ply:ShouldStaySpectating() then
			table.insert(pool, ply)
		end
	end
	return pool
end