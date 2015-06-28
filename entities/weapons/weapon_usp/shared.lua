if CLIENT then

	SWEP.PrintName			= "USP .45"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "a"
	
	killicon.AddFont( "weapon_usp", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel 			= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_usp.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound 		= Sound("Weapon_USP.Single")
SWEP.Primary.Damage 		= 20
SWEP.Primary.Recoil 		= 1
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.0155
SWEP.Primary.ClipSize 		= 12
SWEP.Primary.Delay 		= 0.16
SWEP.Primary.DefaultClip 	= 12
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 		= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector (4.4777, 0, 2.752)
SWEP.IronSightsAng 		= Vector (-0.2267, -0.0534, 0)

SWEP.SilencedSound = Sound( "Weapon_USP.Silencedshot" )

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	
	-- Play the correct shooting sound
	if self:GetDTInt(0) == 1 then
		self.Weapon:EmitSound( self.SilencedSound )
	else
		self.Weapon:EmitSound( self.Primary.Sound )
	end
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )

	-- Make sure the correct animation type is triggered
	if self:GetDTInt(0) == 1 then
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
	else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
end

-- When you press the right mouse the type toggles and an animation is called
function SWEP:SecondaryAttack()
	if self:GetDTInt(0) == 1 then
		self:SetDTInt( 0, 0 )
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	else
		self:SetDTInt( 0, 1 )
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW_SILENCED ) 
	end
end

-- If you don't have this the model will change when reloading
function SWEP:Reload()
	if self:GetDTInt(0) == 1 then
		self.Weapon:DefaultReload( ACT_VM_RELOAD_SILENCED )
	else
		self.Weapon:DefaultReload( ACT_VM_RELOAD )
	end
end