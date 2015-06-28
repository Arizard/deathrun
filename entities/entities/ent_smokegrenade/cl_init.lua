---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

include('shared.lua')
language.Add("ent_smokegrenade", "Grenade")

function ENT:Initialize()
	self.Bang = false
end
function ENT:Draw()
	self.Entity:DrawModel()
end
function ENT:Think()
	if (self.Entity:GetNWBool("Bang", false) == true and self.Bang == false) then
		self:Smoke()
		self.Bang = true
	end
end

local smokeparticles = {
    Model("particle/particle_smokegrenade"),
    Model("particle/particle_noisesphere")
};

function ENT:Smoke()
      local em = ParticleEmitter(self:GetPos())

      local r = 20
      for i=1, 20 do
         local prpos = VectorRand() * r
         prpos.z = prpos.z + 32
         local p = em:Add(table.Random(smokeparticles), self:GetPos() + prpos)
         if p then
            local gray = math.random(75, 200)
            p:SetColor(gray, gray, gray)
            p:SetStartAlpha(255)
            p:SetEndAlpha(200)
            p:SetVelocity(VectorRand() * math.Rand(900, 1300))
            p:SetLifeTime(0)
            
            p:SetDieTime(math.Rand(50, 70))

            p:SetStartSize(math.random(140, 150))
            p:SetEndSize(math.random(1, 40))
            p:SetRoll(math.random(-180, 180))
            p:SetRollDelta(math.Rand(-0.1, 0.1))
            p:SetAirResistance(600)

            p:SetCollide(true)
            p:SetBounce(0.4)

            p:SetLighting(false)
         end
      end

      em:Finish()
end

function ENT:IsTranslucent()
	return true
end

