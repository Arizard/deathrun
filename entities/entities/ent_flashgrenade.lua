AddCSLuaFile( )
ENT.Type 		= "anim"
ENT.Base 		= "base_entity"

ENT.PrintName	= "Flash Grenade"
ENT.Author		= "Arizard"
ENT.Contact		= "Don't"

ENT.Category = "Deathrun"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true

ENT.WorldModel = "models/weapons/w_eq_flashbang_thrown.mdl"

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
	self.lifespan = 2.4-- second trigger

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
			self.Entity:EmitSound(Sound("weapons/flashbang/grenade_hit1.wav"))
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

	hook.Add("HUDPaint", "FlashbangEffect", function()
		local ply = LocalPlayer()

		if ply:GetObserverMode() ~= OBS_MODE_NONE then
			if IsValid( ply:GetObserverTarget() ) then
				ply = ply:GetObserverTarget()
			end
		end

		ply.FlashTime = ply.FlashTime or 0

		ply.FlashTime = ply.FlashTime - FrameTime()

		ply.FlashTime = math.Clamp( ply.FlashTime, 0, 10 )

		local alpha = InverseLerp( ply.FlashTime, 0, 1 )
		alpha = math.Clamp( alpha, 0, 1 )

		if alpha > 0 then
			surface.SetDrawColor(Color(255,255,255,alpha*255))
			surface.DrawRect(0,0,ScrW(), ScrH())
		end

	end)

	function ENT:DoExplosion( pos )
		if self.popped then return end
		self.popped = true

		local ply = LocalPlayer()

		if ply:GetObserverMode() ~= OBS_MODE_NONE then
			if IsValid( ply:GetObserverTarget() ) then
				ply = ply:GetObserverTarget()
			end
		end

		local dist = ply:EyePos():Distance( self:GetPos() )

		-- falloff is 1024 units
		--if dist < 1024 then
		local flashmul = InverseLerp( dist, 1024, 0 )
		flashmul = math.Clamp( flashmul, 0.1, 1 )

		local td = {
			start = ply:GetShootPos(),
			endpos = self:GetPos(),
			filter = {ply, self}
		}

		local tr = util.TraceLine( td )
		if (not tr.Hit) or (tr.MatType == MAT_GLASS) then
			local bonus = 1
			
			local sx, sy, svis = self:GetPos():ToScreen().x, self:GetPos():ToScreen().y, self:GetPos():ToScreen().visible
			if not svis then bonus = 0.2 end

			ply.FlashTime = ply.FlashTime + 4*flashmul*bonus
		end
		--end
		
		sound.Play("weapons/flashbang/flashbang_explode2.wav", self:GetPos(), 120, 100, 1)
	end
end
