---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

include('shared.lua')

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_eq_fraggrenade.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	self.Entity:SetGravity( 0.4 )
	self.Entity:SetElasticity( 0.45 )
	self.Entity:SetFriction(0.2)
	
	// Don't collide with the player
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.timer = CurTime() + 3
end

function ENT:Think()
	if self.timer < CurTime() then
		local damage = 0
		local pos = self.Entity:GetPos()
		local owner = self.GrenadeOwner
		local ref = self
		
		//self.Entity:EmitSound(Sound("weapons/hegrenade/explode"..math.random(3,5)..".wav"))
		self.Entity:Remove()
		
		--[[for i,pl in pairs(player.GetAll()) do
			local plp = pl:GetShootPos()
			
			if (plp - pos):Length() <= range then
				local trace = {}
					trace.start = plp
					trace.endpos = pos
					trace.filter = pl
					trace.mask = COLLISION_GROUP_PLAYER
				trace = util.TraceLine(trace)
				
				if trace.Fraction == 1 then
					pl:TakeDamage(trace.Fraction * damage)
				end
			end
		end]]
		for _,ent in pairs(ents.FindInSphere(pos,128)) do
			if(ent:GetClass() == "func_button") then
				local tr = util.TraceLine({start=pos, endpos=ent:GetPos(), filter={ent}, mask=MASK_SOLID})
				if(tr.Fraction == 1) then
					ent:TakeDamage(dmg,owner,nil)
					ent:TakeDamage(dmg,owner,nil)
				end
			end
		end
		local exp = ents.Create("env_explosion")
			exp:SetKeyValue("spawnflags",128)
			exp:SetPos(pos)
		exp:Spawn()
		exp:Fire("explode","",0)
		local exp = ents.Create("env_physexplosion")
			exp:SetKeyValue("magnitude",150)
			exp:SetPos(pos)
		exp:Spawn()
		exp:Fire("explode","",0)
	end
end
