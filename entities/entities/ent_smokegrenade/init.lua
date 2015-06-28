---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

include('shared.lua')

function ENT:Initialize()

        self.Entity:SetModel("models/weapons/w_eq_smokegrenade.mdl")
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
        if (self.timer < CurTime()) then
                self:Remove()
        end
end