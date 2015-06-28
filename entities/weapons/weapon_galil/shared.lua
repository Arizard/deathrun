if ( CLIENT ) then

	SWEP.PrintName			= "Galil"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 0
	SWEP.IconLetter			= "v"
	
	killicon.AddFont( "weapon_galil", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.ViewModelFlip = false

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.ViewModel 			= "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_galil.mdl"

SWEP.Primary.Sound 		= Sound("Weapon_Galil.Single")
SWEP.Primary.Recoil 		= 0.65
SWEP.Primary.Damage 		= 25
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 		= 0.017
SWEP.Primary.ClipSize 		= 35
SWEP.Primary.Delay 		= 0.09
SWEP.Primary.DefaultClip 	= 35
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 		= "smg1"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.IronSightsPos 		= Vector(-5.15,-3,2.37)
SWEP.IronSightsAng 		= Vector(-.4,0,0)



