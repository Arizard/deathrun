---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

include('shared.lua')

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
