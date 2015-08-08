AddCSLuaFile( )
ENT.Type 		= "anim"
ENT.Base 		= "base_entity"

ENT.PrintName	= "HE Grenade"
ENT.Author		= "Arizard"
ENT.Contact		= "Don't"

ENT.Category = "Deathrun"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

ENT.WorldModel = "models/weapons/w_eq_fraggrenade_thrown.mdl"

function ENT:Initialize()

	self:SetModel( self.WorldModel )
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )	 
 	
	if ( SERVER ) then self:PhysicsInitSphere( 1, "grenade" ) end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 1 )
	end

	self.phys = phys
	self.popped = false

	self.born = CurTime()
	self.lifespan = 2.4-- second trigger


end

function ENT:ReflectVector( dir, norm )
	local normal = norm:GetNormalized()
	local dot = dir:DotProduct( normal )
	return dir - 2*dot*normal
end

function ENT:PhysicsCollide(data,phys)
	local reflectionDir = self:ReflectVector( data.OurOldVelocity, data.HitNormal )
	local efficiency = 0.55
	phys:SetVelocityInstantaneous( reflectionDir*efficiency )
	if data.Speed > 50 then
	   	self.Entity:EmitSound(Sound("weapons/hegrenade/he_bounce-1.wav"))
	end 
end

if SERVER then
	ENT.dt = 0
	ENT.LastTime = CurTime()
	function ENT:Think()

		self.dt = CurTime() - self.LastTime
		self.LastTime = CurTime()

		-- create a cubic hull around this sucker

		if self.born + self.lifespan < CurTime() then
			self:DoExplosion( self:GetPos() )
		end

		self:NextThink( CurTime() )
		return true
	end
	function ENT:DoExplosion( pos )
		if self.popped == true then return end
		self.popped = true


		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "Explosion", effectdata )

		local entities = ents.FindInSphere( self:GetPos(), 300 )
		for k, e in ipairs( entities ) do
			local td = {
				start = e:IsPlayer() and e:EyePos() or e:GetPos() + e:OBBCenter(),
				endpos = self:GetPos(),
				filter = {self, e}
			}
			local tr = util.TraceLine( td )
			--PrintTable( tr )
			if not tr.HitWorld then
				local dist = td.start:Distance( self:GetPos() )
				local frac = InverseLerp( dist, 300, 0 )

				local di = DamageInfo()
				di:SetDamage( 100 * frac )
				di:SetDamageType( DMG_BLAST )
				di:SetInflictor( self )
				di:SetAttacker( self.GrenadeOwner )

				e:TakeDamageInfo( di )
			end
		end

		self:Remove()
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
