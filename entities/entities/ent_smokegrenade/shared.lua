---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

ENT.Type                        = "anim"
ENT.PrintName           = ""
ENT.Author                      = ""
ENT.Contact                     = ""
ENT.Purpose                     = ""
ENT.Instructions        = ""

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
                self.Entity:EmitSound(Sound("SmokeGrenade.Bounce"))
        end
end