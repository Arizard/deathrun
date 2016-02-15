local PLAYER = FindMetaTable("Player")

hook.Add("PlayerSpawn", "test", function( ply )
	--print(ply, ply.Spectating)
end)

function PLAYER:BeginSpectate()
	--print(self:Nick(),"deathteam",self:Team(), TEAM_DEATH, "voluntary:", self.VoluntarySpec)
	local avoided = (self:Team() == TEAM_DEATH and self.VoluntarySpec == true) and true or false
	print( "Checking death avoid...", self:Nick(), avoided)
	if avoided == true and (ROUND:GetCurrent() == ROUND_PREP or ROUND:GetCurrent() == ROUND_ACTIVE) and (#player.GetAllPlaying()) > 1 then
		print("Punish death avoider..")
		DR:PunishDeathAvoid( self, DR.DeathAvoidPunishment:GetInt() )
		DR:ChatBroadcast("Player "..self:Nick().." will be punished for attempting to avoid being on the Death team!")
	end

	--self:StripWeapons()
	--self:StripAmmo()

	self.Spectating = true
	--self.StaySpectating = false
	self.ObsMode = 0

	self:Spectate( OBS_MODE_IN_EYE )

	--self:SetupHands( nil )

	self.VoluntarySpec = false

	-- pointshop - unequip all the trails and shit when they go into spectator
	if PS then
		self:PS_PlayerDeath()
	end

end
function PLAYER:EndSpectate() -- when you want to end spectating when he respawns
	--self.StaySpectating = false
end

function PLAYER:StopSpectate() -- when you want to end spectating immediately

	self.Spectating = false
	--self.StaySpectating = false

	self:UnSpectate()
	--self:Spectate( OBS_MODE_NONE )

end

function PLAYER:SetShouldStaySpectating( bool, noswitch ) -- set whether they should stay in spectator even when the round starts
	print( bool == true and (self:Nick().." will stay as spectator.") or (self:Nick().." will not stay as spectator."))
	self.StaySpectating = bool
	--print( self.StaySpectating )
	if bool == true and noswitch ~= true then 
		self:SetTeam( TEAM_SPECTATOR ) 
	end
end

function PLAYER:ShouldStaySpectating() -- check if he should respawn
	--self.StaySpectating = self.StaySpectating ~= nil and self.StaySpectating or false
	if self.StaySpectating == nil then
		self.StaySpectating = false
	end
	--print( self:Nick() == "Arizard" and "arizard "..tostring( self.StaySpectating ) )
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
		self:Spectate( OBS_MODE_ROAMING )
		--because it's nicer
		if self:GetObserverTarget() then
			self:SetPos( self:GetObserverTarget():EyePos() or self:GetObserverTarget():OBBCenter() + self:GetObserverTarget():GetPos() )
		end 
	end
	if self.ObsMode2 == 1 then self:Spectate( OBS_MODE_CHASE ) end
	if self.ObsMode2 == 2 then self:Spectate( OBS_MODE_IN_EYE ) end

	if self.ObsMode2 > 0 then
		--this means we are spectating a player

		local pool = {}
		for k,self in ipairs(player.GetAll()) do
			if self:Alive() and not self:GetSpectate() then
				table.insert(pool, self)
			end
		end

		--check if they don't already have a spectator target
		local target = self:GetObserverTarget()

		if not target then
			local tidx = math.random(#pool)
			self:SpectateEntity( pool[tidx] ) -- iff they don't then give em one
			self:SetupHands( pool[tidx] )
		end

	end


	self:SpecModify( 0 )
	self:SetupHands( self:GetObserverTarget() )
	
end

function PLAYER:SpecModify( n )

	self.SpecEntIdx = self.SpecEntIdx or 1

	local pool = {}
	for k,self in ipairs(player.GetAll()) do
		if self:Alive() and not self:GetSpectate() then
			table.insert(pool, self)
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

			if self:GetObserverMode() == OBS_MODE_IN_EYE then
				self:SetupHands( pool[self.SpecEntIdx] )
			else
				self:SetupHands( nil )
			end

		end
	end

	if self:GetObserverMode() ~= OBS_MODE_IN_EYE then
		self:SetupHands( nil )
	end

end

function PLAYER:SpecNext()
	self:SpecModify( 1 )
end
function PLAYER:SpecPrev()
	self:SpecModify( -1 )
end

hook.Add("KeyPress", "DeathrunSpectateChangeObserverMode", function(self, key)
	if self:GetSpectate() then
		if key == IN_JUMP then
			self:ChangeSpectate()
		end
		if key == IN_ATTACK then
			-- cycle players forward
			self:SpecNext()
		end
		if key == IN_ATTACK2 then
			-- cycle players bacwards
			self:SpecPrev()
		end
	end
end)

concommand.Add("deathrun_toggle_spectate", function(self)
	if self:GetSpectate() == false then
		self:BeginSpectate()
		self:SetShouldStaySpectating( true )
	else
		self:EndSpectate()
		self:SetShouldStaySpectating( false )
	end
end)

concommand.Add("deathrun_set_spectate", function(self, cmd, args)
	if tonumber(args[1]) == 1 then
		self:KillSilent()
		self:SetShouldStaySpectating( true, self:Team() == TEAM_DEATH and true or false )
		self.VoluntarySpec = true
		self:BeginSpectate()
	else
		self:SetShouldStaySpectating( false )
		self:EndSpectate()

		if ROUND:GetCurrent() == ROUND_WAITING then
			self:KillSilent()
			self:SetTeam( TEAM_RUNNER )
			self:Spawn()
		end
	end
end)

local lastmsg = ""
function PLAYER:DeathrunChatPrint( msg )
	net.Start("DeathrunChatMessage")
	net.WriteString( msg )
	net.Send( self )

	local printmsg = "Server to "..self:Nick()..": "..msg.."\n"

	if printmsg ~= lastmsg then
		MsgC(DR.Colors.Turq, printmsg)
		lastmsg = printmsg
	end
end

function DR:ChatBroadcast( msg )
	--for k,v in ipairs(player.GetAll()) do
		net.Start("DeathrunChatMessage")
		net.WriteString( msg )
		net.Broadcast()
		MsgC(DR.Colors.Turq, "Server Broadcast: "..msg.."\n")
	--end
end

timer.Create("MoveSpectatorsToCorrectTeam", 5, 0, function()
	for k,ply in ipairs(player.GetAll()) do
		if ply:Team() ~= TEAM_SPECTATOR then
			if ply:ShouldStaySpectating() == true then
				ply:SetTeam( TEAM_SPECTATOR )
			end
		end
	end
end)