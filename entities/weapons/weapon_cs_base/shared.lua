-- Note from Arizard:
-- This is a heavily modified version of the weapon_cs_base in Gravious' release of Flow Network Gamemodes.
-- It features additions such as recoil predictability (almost a spray pattern) and headshot damage buffs.
-- Also allows for scoped weapons, it draws a scope (however with no crosshair because it's not needed for this deathrun gamemode)
-- Despite this being a modified version of another base i'd appreciate it if you credited the following people if you use this in your own project:
-- * Arizard - Custom weapon recoil, scopes, and headshot damage buffs
-- * Gravious - Original weapon base

if (SERVER) then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 55
	SWEP.ViewModelFlip = false
	SWEP.CSMuzzleFlashes	= true
	SWEP.UseHands = true
	surface.CreateFont("CSKillIcons", { font="csd", weight="500", size=ScreenScale(30),antialiasing=true,additive=true })
	surface.CreateFont("CSSelectIcons", { font="csd", weight="500", size=ScreenScale(60),antialiasing=true,additive=true })

end

SWEP.Author			= "Counter-Strike"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

-- Note: This is how it should have worked. The base weapon would set the category
-- then all of the children would have inherited that.
-- But a lot of SWEPS have based themselves on this base (probably not on purpose)
-- So the category name is now defined in all of the child SWEPS.
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay = 0

SWEP.KickBack = 0

SWEP.Scope = false
SWEP.ScopedFOV = 25

SWEP.Reloading = false

-----------------------------------------------------------
-- Initialize
-----------------------------------------------------------
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
	
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SetNetworkedBool( "Ironsights", false )
	
end



function SWEP:Holster()
	if self then
		self:SetIronsights( false, true )
	end
	return true
end

-----------------------------------------------------------
--	Reload does nothing
-----------------------------------------------------------
function SWEP:Reload()
	
	if (self:Clip1() == self.Primary.ClipSize) or self.Reloading == true then return end

	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	
	self:SetIronsights( false, true )

	self.Reloading = true
end

function SWEP:CalculateFalloff( drunkhigh, dt ) -- stole the code from my drug addon lol - arizard
	drunkhigh = (drunkhigh > 0) and (drunkhigh + 1) or drunkhigh -1

	local halflife = 0.5 * math.sqrt(self.Primary.Recoil/1.5) -- is half-life of recoil in seconds
	local rate =  ( math.log(1/2)*1000 / (halflife) )/1000 
	local initial = math.abs(drunkhigh)
	local sign = ((drunkhigh < 0) and -1) or 1
	local final = 0

	final = (initial * math.exp( rate * dt )) - 1

	if final < 0 then final = 0 else final = final * sign end

	return final 

end

if SERVER then
	SWEP.LastThink = RealTime()
	function SWEP:Think()

		local dt = RealTime() - self.LastThink
		self.LastThink = RealTime()

		self.KickBack = self:CalculateFalloff( self.KickBack, dt )
		
		--if self.KickBack < 0 then self.KickBack = 0 end	-- do this serverside
		self.Reloading = false
	end
else
	function SWEP:Think() -- clientside think
		self.Reloading = false
	end
end


-----------------------------------------------------------
--	PrimaryAttack
-----------------------------------------------------------
function SWEP:PrimaryAttack2() end

SWEP.LastPrimaryShotTime = 0
function SWEP:PrimaryAttack()

	timer.Simple( self.Primary.Delay*0.9, function() 
		if self.Weapon and not self.Reloading then
			self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		end
	end )

	if CurTime() < self.LastPrimaryShotTime + self.Primary.Delay then return end

	self.Weapon:SendWeaponAnim( ACT_VM_IDLE )

	self.LastPrimaryShotTime = CurTime()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	-- Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	
	-- Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	-- simulate recoil????
	self.KickBack = self.KickBack + 1
	
	-- Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	-- Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	-- In singleplayer this function doesn't get called on the client, so we use a networked float
	-- to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	-- send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end

	self:PrimaryAttack2()
	
end

function QuadLerp( frac, p1, p2 )

    local y = (p1-p2) * (frac -1)^2 + p2
    return y

end

function InverseLerp( pos, p1, p2 )

	local range = 0
	range = p2-p1

	if range == 0 then return 1 end

	return ((pos - p1)/range)

end

function SWEP:GetRecoilShiftAmount()
	local maxshift = 30
	local minshift = 0

	local shiftamt = ( QuadLerp( InverseLerp( self.KickBack, minshift, maxshift ), 0, 160000 ) )*(self.Primary.Recoil/1.5)/10000
	return shiftamt
end
-----------------------------------------------------------
--   Name: SWEP:CSShootBullet( )
-----------------------------------------------------------
function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			-- Source
	bullet.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet

	bullet.Spread 	= Vector( 0, 0, 0 )			-- Aim Cone
	bullet.Tracer	= 4									-- Show a tracer on every x bullets 
	bullet.Force	= 5									-- Amount of force to give to phys objects
	bullet.Damage	= dmg

	local shootAng = bullet.Dir:Angle()
	local right = shootAng:Right()


	local up = shootAng:Up()
	local shiftamt = self:GetRecoilShiftAmount()
	shootAng:RotateAroundAxis( right, shiftamt )
	shootAng:RotateAroundAxis( up, math.random(-shiftamt*100/4, shiftamt*100/8)/100 )

	-- add spread cone
	shootAng:RotateAroundAxis( up, math.random( -cone*1000, cone*1000 )/40 )
	shootAng:RotateAroundAxis( right, math.random( -cone*1000, cone*1000 )/40 )

	bullet.Dir = shootAng:Forward()

	-- test for hitboxes
	--if SERVER then
		local tr = util.TraceLine({
			start = bullet.Src,
			endpos = bullet.Src + bullet.Dir * 5120,
			filter = {self, self.Owner, self.Weapon},
		})

		if tr.Entity:IsPlayer() then
			if tr.HitGroup == HITGROUP_HEAD then
				if SERVER then
					tr.Entity:EmitSound("player/bhit_helmet-1.wav", 400, 100, 1 )
				end
				local ed = EffectData()
				ed:SetOrigin( tr.HitPos )
				ed:SetMagnitude( 0.5 )
				util.Effect("StunstickImpact", ed)
				bullet.Damage = dmg*1.4 -- headshot buff
			end
		end
	--end
	
	local owner = self.Owner
	local slf = self

	bullet.Callback = function(ply, tr, dmginfo)
		--if SERVER and tr.HitPos then
			--print(tr.Entity:GetClass())
		--end
	end

	self.Owner:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		-- View model animation
	self.Owner:MuzzleFlash()								-- Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				-- 3rd Person Animation

	

	--print(tr.Entity:IsPlayer() and tr.HitGroup or "no hitgroup")
	
	if ( self.Owner:IsNPC() ) then return end

end


-----------------------------------------------------------
--	Checks the objects before any action is taken
--	This is to make sure that the entities haven't been removed
-----------------------------------------------------------
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

local IRONSIGHT_TIME = 0.25

-----------------------------------------------------------
--   Name: GetViewModelPosition
--   Desc: Allows you to re-position the view model
-----------------------------------------------------------
function SWEP:GetViewModelPosition( pos, ang )

	if ( !self.IronSightsPos ) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool( "Ironsights" )
	
	if ( bIron != self.bLastIron ) then
	
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
		
		if ( bIron ) then 
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else 
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	
	end
	

	local right = ang:Right();
	local forward = ang:Forward()
	local shiftamt = self:GetRecoilShiftAmount()
	ang:RotateAroundAxis(right, shiftamt/1.7)
	pos = pos + forward*math.Clamp( (-shiftamt/30)*4, 0, 16 )

	local fIronTime = self.fIronTime or 0

	if self:GetIronsights() == true then
		pos = pos + ang:Forward()*-100
	end

	if ( !bIron && fIronTime < CurTime() - IRONSIGHT_TIME ) then 
		return pos, ang 
	end
	
	local Mul = 1.0
	
	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then
	
		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )
		
		if (!bIron) then Mul = 1 - Mul end
	
	end

	local Offset	= self.IronSightsPos
	
	if ( self.IronSightsAng ) then
	
		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )
	
	
	end
	
	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul



	return pos, ang
	
end


if CLIENT then
	local scopedirt = surface.GetTextureID( "sprites/scope_arc.vtf" )
	local scoperadius = ScrH()/2 - 50

	SWEP.LastCalcView = RealTime()

	function SWEP:GetDesiredFOVForThirdperson()
		return self.ScopedFOV
	end

	function SWEP:DrawHUD()
		local dt = RealTime() - self.LastCalcView
		--print(dt, engine.TickInterval())
		if dt > engine.TickInterval() then
			self.KickBack = self:CalculateFalloff( self.KickBack, engine.TickInterval() )
			self.LastCalcView = RealTime()
		end

		if self:GetIronsights() and self.Scope then
			local x,y = 0,0
			if GetConVar("deathrun_thirdperson_enabled"):GetBool() == true then
				local tr = LocalPlayer():GetEyeTrace()
				x = tr.HitPos:ToScreen().x - ScrW()/2
				y = tr.HitPos:ToScreen().y - ScrH()/2
			end

			surface.SetDrawColor(0,0,0)
			surface.DrawRect(0+x-200,y+0-800,ScrW()+200, ScrH()/2-scoperadius + 5 +800)
			surface.DrawRect(0+x-500,y+0-700,500+ScrW()/2-scoperadius + 5, ScrH()+1200)
			surface.DrawRect(x+ScrW()/2 + scoperadius - 5,y+0-750,ScrW()/2-scoperadius + 5+500, ScrH()+1200)
			surface.DrawRect(x+0-100,y+ScrH()/2 + scoperadius - 5, ScrW()+200, ScrH()/2 - scoperadius+700)

			surface.SetTexture( scopedirt )
			surface.DrawTexturedRectUV(x+(ScrW()/2) - scoperadius, y+(ScrH()/2) - scoperadius, scoperadius, scoperadius, 1,1,0,0)
			surface.DrawTexturedRectUV(x+(ScrW()/2), y+(ScrH()/2) - scoperadius, scoperadius, scoperadius, 0,1,1,0)
			surface.DrawTexturedRectUV(x+(ScrW()/2) - scoperadius, y+(ScrH()/2) , scoperadius, scoperadius, 1,0,0,1)
			surface.DrawTexturedRectUV(x+(ScrW()/2) , y+(ScrH()/2) , scoperadius, scoperadius, 0,0,1,1)
		end
	end

	-- we need two of these because the above doesnt run when in thirdperson, and below doesnt run in firstperson

	function SWEP:DrawWorldModel() -- incase we are in tp
		self:DrawModel()
		local dt = RealTime() - self.LastCalcView
		--print(dt, engine.TickInterval())
		if dt > engine.TickInterval() then
			self.KickBack = self:CalculateFalloff( self.KickBack, engine.TickInterval() )
			self.LastCalcView = RealTime()
		end
	end

	
	
	function SWEP:CalcView( ply, pos, ang, fov )
		-- local dt = RealTime() - self.LastCalcView
		-- --print(dt, engine.TickInterval())
		-- if dt > engine.TickInterval() then
		-- 	self.KickBack = self:CalculateFalloff( self.KickBack, engine.TickInterval() )
		-- 	self.LastCalcView = RealTime()
		-- end

		local right = ang:Right();
		local shiftamt = self:GetRecoilShiftAmount()
		ang:RotateAroundAxis(right, shiftamt/2)

		if self:GetIronsights() then
			if self.Scope == true then
				fov = self.ScopedFOV
			end
		end

		return pos, ang, fov
	end

	-- function SWEP:CalcViewModelView( ply, opos, oang, pos, ang )
		
	-- 	return pos, ang
	-- end

	function SWEP:AdjustMouseSensitivity()
		if self:GetIronsights() then
			if self.Scope == true then
				return self.ScopedFOV/70
			end
		end
	end
end

-----------------------------------------------------------
--	SetIronsights
-----------------------------------------------------------
function SWEP:SetIronsights( b, mute )

	self.Weapon:SetNWBool( "Ironsights", b )

	if self.Scope and not mute then
		self.Weapon:EmitSound( "weapons/zoom.wav" )
	end

end

function SWEP:GetIronsights( )

	return self.Weapon:GetNWBool( "Ironsights", false )

end


SWEP.LastSecondaryShotTime = 0
-----------------------------------------------------------
--	SecondaryAttack
-----------------------------------------------------------
function SWEP:SecondaryAttack2()
end
function SWEP:SecondaryAttack()

	if CurTime() < self.LastSecondaryShotTime + self.Secondary.Delay then return end
	self.LastSecondaryShotTime = CurTime()
	
	self:SecondaryAttack2()

end

-----------------------------------------------------------
--	onRestore
--	Loaded a saved game (or changelevel)
-----------------------------------------------------------
function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
	
end
