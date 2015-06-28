if (SERVER) then
        SWEP.Weight                     = 5
        SWEP.AutoSwitchTo               = false
        SWEP.AutoSwitchFrom             = false
end

if (CLIENT) then

        SWEP.PrintName                  = "Flashbang"
        SWEP.Slot                               = 3
        SWEP.SlotPos                    = 1
        SWEP.DrawAmmo                   = false
        SWEP.DrawCrosshair              = false
        SWEP.ViewModelFOV                       = 65
        SWEP.ViewModelFlip              = true
        SWEP.CSMuzzleFlashes            = false

        SWEP.IconLetter                         = "P"
        killicon.AddFont("weapon_flashbang", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ))
end

SWEP.Base                                       = "weapon_grenade_base"

SWEP.Author                             = "kna_rus"
SWEP.Contact                            = ""
SWEP.Purpose                            = ""

SWEP.Spawnable                          = true
SWEP.AdminSpawnable                     = true

SWEP.ViewModel                          = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel                                 = "models/weapons/w_eq_flashbang.mdl"

SWEP.Primary.ClipSize                   = -1
SWEP.Primary.DefaultClip                = -1
SWEP.Primary.Automatic                  = true
SWEP.Primary.Ammo                       = "none"

SWEP.Secondary.ClipSize                 = -1
SWEP.Secondary.DefaultClip              = -1
SWEP.Secondary.Automatic                = true
SWEP.Secondary.Ammo                     = "none"

SWEP.NadeClass = "ent_flashgrenade"