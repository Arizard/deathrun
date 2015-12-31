AddCSLuaFile( )
ENT.Type 		= "anim"
ENT.Base 		= "base_entity"

ENT.PrintName	= "Balloon"
ENT.Author		= "Arizard"
ENT.Contact		= "Don't"

ENT.Category = "Deathrun"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

ENT.WorldModel = "models/balloons/balloon_classicheart.mdl"
ENT.Models = {
	"models/balloons/balloon_classicheart.mdl",
	"models/balloons/balloon_dog.mdl",
	"models/balloons/balloon_star.mdl"
}


for k,v in ipairs( ENT.Models ) do
	util.PrecacheModel( v )
end

function ENT:Initialize()
	
	local models = self.Models

	self.WorldModel = table.Random( models )

	self:SetModel( self.WorldModel )
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )         
 	
	if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.phys = phys

	

	self.born = CurTime()
	self.lifespan = 10 + math.random(-2, 2)

	if SERVER then
		phys:EnableGravity( false )

		phys:ApplyForceCenter( Vector(0,0,self.lifespan) )

		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER)

	end

	self:SetColor( HSVToColor( math.random(0,359), 1, 1 ) )


	--self:SetVelocity( Vector(0,0,1) )
end

if SERVER then
	function ENT:Think()
		
		if self.born + self.lifespan < CurTime() then
			self:DoExplosion( self:GetPos() )
		end
	end

	function ENT:OnTakeDamage( dmginfo )
		self:DoExplosion( self:GetPos() )
	end
	function ENT:Touch( e )

	end
	function ENT:DoExplosion( pos )
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		local c = self:GetColor()
		effectdata:SetStart( Vector( c.r, c.g, c.b ) )
		util.Effect( "balloon_pop", effectdata )

		self:Remove()
	end
	concommand.Add("celebrate", function( ply, cmd, args )
		if not ply:SteamID() == "STEAM_0:1:30288855" then return end
		for i = 1, 8 do

			local dir = Vector( math.random(-100,100),math.random(-100,100),math.random(-100,100) )
			dir:Normalize()

			local balloon = ents.Create("ent_deathrun_balloon")
			balloon:Spawn()
			balloon:SetAngles( Angle(0, math.random(-180,180), 0 ) )

			local td = {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + dir * 92,
				filter = ply,
				mins = balloon:OBBMins(),
				maxs = balloon:OBBMaxs(),
			}

			local tr = util.TraceHull( td )

			if tr.HitPos:Distance( td.start ) > 30 then
				balloon:SetPos( tr.HitPos )
				balloon:GetPhysicsObject():ApplyForceCenter( dir * 2.5 )
			else
				balloon:Remove()
			end

		end

	end)
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
