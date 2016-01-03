AddCSLuaFile( )
ENT.Type 		= "anim"
ENT.Base 		= "base_entity"

ENT.PrintName	= "Smoke Grenade"
ENT.Author		= "Arizard"
ENT.Contact		= "Don't"

ENT.Category = "Deathrun"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

ENT.WorldModel = "models/weapons/w_eq_smokegrenade_thrown.mdl"

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

	self.born = CurTime()
	self.lifespan = 4.4-- second trigger

	self.popped = false

end

function ENT:ReflectVector( dir, norm )
	local normal = norm:GetNormalized()
	local dot = dir:DotProduct( normal )
	return dir - 2*dot*normal
end

function ENT:PhysicsCollide(data,phys)
	local reflectionDir = self:ReflectVector( data.OurOldVelocity, data.HitNormal )
	local efficiency = 0.65
	phys:SetVelocityInstantaneous( reflectionDir*efficiency )
	if data.Speed > 50 then
			self.Entity:EmitSound(Sound("weapons/smokegrenade/grenade_hit1.wav"))
	end 
end

if SERVER then
	function ENT:DoExplosion( pos )

		self:Remove()
	end
end
function ENT:Think()
	if self.born + self.lifespan < CurTime() then
		self:DoExplosion( self:GetPos() )
	end
end
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
	-- borrowed from TTT
	local smokeparticles = {
		Model("particle/particle_smokegrenade"),
		Model("particle/particle_noisesphere")
	};

	function ENT:CreateSmoke(center)
		local em = ParticleEmitter(center)

		local r = 64
		for i=1, 20 do
		local prpos = VectorRand() * r
		prpos.z = prpos.z + 32
		local p = em:Add(table.Random(smokeparticles), center + prpos)
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

	function ENT:DoExplosion( pos )
		if self.popped then return end
		self.popped = true

		sound.Play("weapons/smokegrenade/sg_explode.wav", pos, 75, 100, 1)
		self:CreateSmoke( self:GetPos() )
	end
end
