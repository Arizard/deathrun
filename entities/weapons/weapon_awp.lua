if ( CLIENT ) then

	SWEP.PrintName			= "A.W.P"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "r"
	
	killicon.AddFont( "weapon_awp", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.Slot				= 3

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_awp.mdl"

SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_AWP.Single" )
SWEP.Primary.Recoil			= 4
SWEP.Primary.Damage			= 700
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0005
SWEP.Primary.ClipSize		= 10
SWEP.Primary.Delay			= 1.87
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( 6.1, -7, 2.5 )
SWEP.IronSightsAng 		= Vector( 2.8, 0, 0 )

SWEP.Scope = true
SWEP.ScopedFOV = 20

function SWEP:PrimaryAttack2() -- secondary primary attack so we don't override the default base one

	if self:GetIronsights() then
		timer.Simple(self.Primary.Delay/1.5, function()
			if IsValid(self) then
				self:SetIronsights( true, true )
			end
		end)
	end
	self:SetIronsights( false, true )
end
function SWEP:SecondaryAttack2()
	if self then
		self:SetIronsights( not self:GetIronsights() )
	end
end
