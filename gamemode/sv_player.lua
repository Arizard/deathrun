local PLAYER = FindMetaTable("Player")

function PLAYER:BeginSpectate()
	self:StripWeapons()
	self:StripAmmo()

	self.Spectating = true
	self.StaySpectating = false
	self.ObsMode = 0

	self:Spectate( OBS_MODE_ROAMING )
	self:SetObserverMode( OBS_MODE_ROAMING )

end
function PLAYER:EndSpectate() -- when you want to end spectating when he respawns
	self.StaySpectating = false

end
function PLAYER:StopSpectate() -- when you want to end spectating immediately

	self.Spectating = false
	self.StaySpectating = false

	--self:SetTeam( TEAM_UNASSIGNED )

	self:UnSpectate()
	self:SetObserverMode( OBS_MODE_NONE )

end

function PLAYER:SetShouldStaySpectating( bool ) -- set whether they should stay in spectator even when the round starts
	self.StaySpectating = bool
	if bool == true then self:SetTeam( TEAM_SPECTATOR ) end
end

function PLAYER:ShouldStaySpectating() -- check if he should respawn
	return self.StaySpectating
end

function PLAYER:GetSpectate()
	return self.Spectating
end

function PLAYER:ChangeSpectate()
	if not self:GetSpectate() then return end

	if not self.ObsMode2 then self.ObsMode2 = 0 end

	self.ObsMode2 = self.ObsMode2 + 1
	if self.ObsMode2 > 2 then
		self.ObsMode2 = 0
	end
	


	if self.ObsMode2 == 0 then self:SetObserverMode( OBS_MODE_ROAMING ) end
	if self.ObsMode2 == 1 then self:SetObserverMode( OBS_MODE_CHASE ) end
	if self.ObsMode2 == 2 then self:SetObserverMode( OBS_MODE_IN_EYE ) end

	if self.ObsMode2 > 0 then
		--this means we are spectating a player

		local pool = {}
		for k,ply in ipairs(player.GetAll()) do
			if ply:Alive() and not ply:GetSpectate() then
				table.insert(pool, ply)
			end
		end

		--check if they don't already have a spectator target
		local target = self:GetObserverTarget()

		if not target then
			local tidx = math.random(#pool)
			self:SpectateEntity( pool[tidx] ) -- iff they don't then give em one
		end

	end

	
end

hook.Add("Tick", "DeathrunSpectateTick", function()
	for k,ply in ipairs( player.GetAll()) do
		if ply:KeyPressed( IN_JUMP ) then
			ply:ChangeSpectate()
		end
	end
end)

concommand.Add("deathrun_toggle_spectate", function(ply)
	if ply:GetSpectate() == false then
		ply:BeginSpectate()
		ply:SetShouldStaySpectating( true )
	else
		ply:EndSpectate()
		ply:SetShouldStaySpectating( false )
	end
end)