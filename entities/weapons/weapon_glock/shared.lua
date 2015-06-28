if CLIENT then

	SWEP.PrintName			= "Glock"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "c"
	
	killicon.AddFont( "weapon_glock", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.PrintName = "Glock"
SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_glock18.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Primary.Recoil			= 1.8
SWEP.Primary.Damage			= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ClipSize		= 16
SWEP.Primary.Delay			= 0.05
SWEP.Primary.DefaultClip	= 21
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( 4.3, -2, 2.7 )

-- This gets called when the player is holding the weapon - Only then, it'll try to fire the extra bullets
local function PlayerPostThink( ply )
	if not IsValid( ply ) or not ply.GetActiveWeapon then return end
	local weapon = ply:GetActiveWeapon()
	if IsValid( weapon ) and weapon.IsGlock then
		weapon:FireExtraBullets()
	end
end
hook.Add( "PlayerPostThink", "ProcessFire", PlayerPostThink )

-- For faster identification of the weapon
function SWEP:Initialize()
	self.IsGlock = true
end

-- Custom bullet code to make stuff easier
function SWEP:CSSGlockShoot( dmg, recoil, numbul, cone, anim )
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( cone, cone, 0 )
	bullet.Tracer	= 4
	bullet.Force	= 5
	bullet.Damage	= dmg
	
	local owner = self.Owner
	local slf = self
	bullet.Callback = function(a, b, c)
		if SERVER && b.HitPos then
			local tracedata = {}
			tracedata.start = b.StartPos
			tracedata.endpos = b.HitPos + (b.Normal * 2)
			tracedata.filter = a
			tracedata.mask = MASK_PLAYERSOLID
			local trace = util.TraceLine( tracedata )
					
			if IsValid( trace.Entity ) then
				if trace.Entity:GetClass() == "func_button" then
					trace.Entity:TakeDamage( dmg, a, c:GetInflictor() )
					trace.Entity:TakeDamage( dmg, a, c:GetInflictor() )
				elseif trace.Entity:GetClass() == "func_physbox_multiplayer" then
					trace.Entity:TakeDamage( dmg, a, c:GetInflictor() )
				end
			end
		end
	end

	self.Owner:FireBullets( bullet )
	
	if anim then
		-- Make sure the glock model animates when required
		if self:GetDTInt(0) == 1 then
			self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		else	
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		end
	end
	
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	
	end

end

-- Called from the hook - Only fires extra bullets when it can
function SWEP:FireExtraBullets()
	if self:GetDTInt(0) == 1 and self.ShootNext and self.NextShoot < CurTime() and self.ShotsLeft > 0 then
		self:GlockShoot( false )
	end
end

-- Actually bullet firing code
function SWEP:GlockShoot( showanim )
	if self:GetDTInt(0) == 1 then self.ShootNext = false end
	if not self:CanPrimaryAttack() then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	
	// Shoot the bullet
	self:CSSGlockShoot( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone, showanim )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
	if self:GetDTInt(0) == 1 and self.ShotsLeft > 0 and not self.ShootNext then
		self.ShootNext = true
		self.ShotsLeft = self.ShotsLeft - 1
	end
	
	self.NextShoot = CurTime() + 0.04
end

-- Called when left mouse is clicked - Fires
function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	
	if self:GetDTInt(0) == 1 then
		-- After it's fired 3 shots, it'll have a .5 second delay
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		self.ShotsLeft = 3
		self.NextShoot = CurTime() + 0.04
	else
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end
	
	self:GlockShoot( true ) -- Yey animation
end

-- Called when right mouse is clicked - Toggles the firing type (Same as CS:S)
function SWEP:SecondaryAttack()
	if CLIENT or self.NextSecondaryAttack > CurTime() then return end
	
	if self:GetDTInt(0) == 1 then
		self:SetDTInt( 0, 0 )
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to semi-automatic" )
	else
		self:SetDTInt( 0, 1 )
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to burst-fire mode" )
	end
	
	self.NextSecondaryAttack = CurTime() + 0.3
end
