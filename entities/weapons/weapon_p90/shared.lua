if ( CLIENT ) then

        SWEP.PrintName                  = "P90"                 
        SWEP.Author                             = "Counter-Strike"
        SWEP.Slot                               = 0
        SWEP.SlotPos                    = 0
        SWEP.IconLetter                 = "m"
        
        killicon.AddFont( "weapon_p90", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
        
end
SWEP.HoldType                   = "smg"


SWEP.Base                               = "weapon_cs_base"
SWEP.Category                   = "Counter-Strike"

SWEP.Spawnable                  = true
SWEP.AdminSpawnable             = true

SWEP.ViewModel                  = "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel                 = "models/weapons/w_smg_p90.mdl"

SWEP.Weight                             = 5
SWEP.AutoSwitchTo               = false
SWEP.AutoSwitchFrom             = false

SWEP.Primary.Sound                      = Sound( "Weapon_P90.Single" )
SWEP.Primary.Recoil                     = 0.2
SWEP.Primary.Damage                     = 20
SWEP.Primary.NumShots           = 1
SWEP.Primary.Cone                       = 0.025
SWEP.Primary.ClipSize           = 50
SWEP.Primary.Delay                      = 0.066
SWEP.Primary.DefaultClip        = 32
SWEP.Primary.Automatic          = true
SWEP.Primary.Ammo                       = "smg1"

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = false
SWEP.Secondary.Ammo                     = "none"

SWEP.IronSightsPos              = Vector( 4.7, -4, 2 )