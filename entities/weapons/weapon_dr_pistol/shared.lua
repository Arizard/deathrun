
AddCSLuaFile( "shared.lua" )

SWEP.PrintName = "Deagle"

SWEP.Author			= "Arizard"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 40
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel		= "models/weapons/w_pist_deagle.mdl"
SWEP.AnimPrefix		= "python"
SWEP.UseHands = true

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= 7					// Size of a clip
SWEP.Primary.DefaultClip	= 999999999				// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "Pistol"

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:Initialize()

end


/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD );
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	

	if CLIENT then return false end

	if self.Owner:KeyDown( IN_ATTACK ) then
		local tr = self.Owner:GetEyeTrace()
		if tr.Entity then
			if IsValid( tr.Entity ) then
				if tr.Entity:GetKeyValues().classname == "func_button" then
					tr.Entity:TakeDamage( 1337, self.Owner, self)
				end
			end
		end
	end

end

local zmod = 0

function SWEP:CalcViewModelView( vm, opos, oang, pos, ang )

	if ScoreboardVisible == false then
		zmod = zmod + 0.07
	else
		zmod = zmod - 0.09
	end

	if zmod > 0 then zmod = 0 end
	if zmod < -10 then zmod = -10 end

	return pos + ang:Right()*-2 + Vector(0,0,zmod), ang + Angle(0,0,0) 

end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	// Play shoot sound
	self:EmitSound(Sound( "Weapon_Deagle.Single" ), 50)
	
	// Shoot 9 bullets, 150 damage, 0.01 aimcone
	self:ShootBullet( 150, 1, 0.01 )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( -0.5, 0, 0 ) )
	
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	
end