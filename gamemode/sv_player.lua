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
	if bool == true then 
		self:SetTeam( TEAM_SPECTATOR ) 
		self:Spawn()
	end
end

function PLAYER:ShouldStaySpectating() -- check if he should respawn
	self.StaySpectating = self.StaySpectating or false
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
	


	if self.ObsMode2 == 0 then 
		self:SetObserverMode( OBS_MODE_ROAMING )
		--because it's nicer
		if self:GetObserverTarget() then
			self:SetPos( self:GetObserverTarget():EyePos() or self:GetObserverTarget():OBBCenter() + self:GetObserverTarget():GetPos() )
		end 
	end
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


	self:SpecModify( 0 )
	
end

function PLAYER:SpecModify( n )

	self.SpecEntIdx = self.SpecEntIdx or 1

	local pool = {}
	for k,ply in ipairs(player.GetAll()) do
		if ply:Alive() and not ply:GetSpectate() then
			table.insert(pool, ply)
		end
	end

	self.SpecEntIdx = self.SpecEntIdx + n

	if self.SpecEntIdx > #pool then
		self.SpecEntIdx = 1
	end
	if self.SpecEntIdx < 1 then
		self.SpecEntIdx = #pool
	end

	if #pool > 0 then
		if pool[self.SpecEntIdx] then
			self:SpectateEntity( pool[self.SpecEntIdx] )
			self:SetupHands( pool[self.SpecEntIdx] )

		end
	end

end

function PLAYER:SpecNext()
	self:SpecModify( 1 )
end
function PLAYER:SpecPrev()
	self:SpecModify( -1 )
end

hook.Add("KeyPress", "DeathrunSpectateChangeObserverMode", function(ply, key)
	if ply:GetSpectate() then
		if key == IN_JUMP then
			ply:ChangeSpectate()
		end
		if key == IN_ATTACK then
			-- cycle players forward
			ply:SpecNext()
		end
		if key == IN_ATTACK2 then
			-- cycle players bacwards
			ply:SpecPrev()
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

function PLAYER:DeathrunChatPrint( msg )
	net.Start("DeathrunChatMessage")
	net.WriteString( msg )
	net.Send( self )

	MsgC(DR.Colors.Turq, "Server to "..self:Nick()..": "..msg.."\n")
end

function DR:ChatBroadcast( msg )
	--for k,v in ipairs(player.GetAll()) do
		net.Start("DeathrunChatMessage")
		net.WriteString( msg )
		net.Broadcast()
		MsgC(DR.Colors.Turq, "Server Broadcast: "..msg.."\n")
	--end
end