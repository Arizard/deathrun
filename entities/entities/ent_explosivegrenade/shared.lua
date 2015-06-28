---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

ENT.Type = "anim"
ENT.PrintName		= "Nade D:"
ENT.Author			= "kna_rus"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

/*---------------------------------------------------------
OnRemove
---------------------------------------------------------*/
function ENT:OnRemove()
end

/*---------------------------------------------------------
PhysicsUpdate
---------------------------------------------------------*/
function ENT:PhysicsUpdate()
end

/*---------------------------------------------------------
PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
end
