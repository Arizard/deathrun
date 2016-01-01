if SERVER then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
elseif CLIENT then

	SWEP.PrintName			= "Tactical Knife"	
	SWEP.Author				= "cheesylard" -- Works fine - I lost my own one because of update, since then I use this one with a minor edit -- traces modified by arizard
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "j"

	SWEP.ViewModelFOV = 57

	SWEP.NameOfSWEP			= "weapon_knife" --always make this the name of the folder the SWEP is in.
	killicon.AddFont( SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.Slot				= 0

SWEP.IronSightsPos = Vector ( -15.6937, -10.1535, -1.0596 )
SWEP.IronSightsAng = Vector ( 46.9034, 9.0593, -90.2522 )

SWEP.Category				= "Counter-Strike"
SWEP.Base					= "weapon_cs_base"
SWEP.HoldType			= "knife"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl" 

SWEP.UseHands = true

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false
SWEP.CrossHairIronsight		= true --does crosshairs when ironsights are on

SWEP.Primary.Delay = 0.6
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Damage			= 30
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Damage		= 60
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.MissSound 				= Sound("weapons/knife/knife_slash1.wav")
SWEP.WallSound 				= Sound("weapons/knife/knife_hitwall1.wav")
SWEP.FleshHit1 				= ("weapons/knife/knife_hit1.wav")
SWEP.FleshHit2 				= ("weapons/knife/knife_hit2.wav")
SWEP.FleshHit3 				= ("weapons/knife/knife_hit3.wav")
SWEP.FleshHit4 				= ("weapons/knife/knife_hit4.wav")
SWEP.SuperFleshHitSound		= Sound("weapons/knife/knife_stab.wav")
SWEP.ShootafterTakeout = 0
SWEP.IdleTimer = CurTime()

function SWEP:SecondaryAttack()
	if true then return end
	if ( self.ShootafterTakeout > CurTime() ) then return end		
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )

	self.Weapon:EmitSound(self.MissSound,100,math.random(90,120))
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_2)

	self.Owner:SetAnimation( PLAYER_ATTACK1 ) --3rd Person Animation
end
SWEP.LastPrimaryShot = CurTime()
function SWEP:PrimaryAttack()

	--if CurTime() < self.LastPrimaryShot + self.Primary.Delay then return end
	self.LastPrimaryShot = CurTime()

	local bullet = {}
	bullet.Distance = 75
	bullet.Force = 5
	bullet.HullSize = 7
	bullet.Num = 1
	bullet.Tracer = 0
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Src = self.Owner:GetShootPos()
	bullet.Attacker = self.Owner
	bullet.Damage = self.Primary.Damage

	function bullet.Callback( ply, trace, dmginfo )
		if SERVER then
			if trace.Entity then
				if trace.Entity:IsPlayer() then
					sound.Play( self[ "FleshHit"..tostring( math.random(1,4) ) ], trace.HitPos, 75, 100, 1 )
				else
					sound.Play( self.WallSound, trace.HitPos, 75, 100, 1)
				end
			end
		end
	end

	self.Weapon:FireBullets( bullet )

	-- break shit???
	local tr = self.Owner:GetEyeTrace()
	if tr.HitPos:Distance( self.Owner:GetShootPos() ) < 75 then
		if tr.Entity then
			if SERVER then
				local keyvalues = tr.Entity:GetKeyValues()
				if keyvalues.classname == "func_breakable" then
					--tr.Entity:Input("RemoveHealth", self.Owner, self.Weapon, self.Primary.Damage)
				end
			end
		end
	else
		if SERVER then
			self.Owner:EmitSound(self.MissSound, 100, 100, 1)
		end
	end

	if ( self.ShootafterTakeout > CurTime() ) then return end		
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) --3rd Person Animation
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:Reload()
	return false
end

function SWEP:CalcViewModelView( ply, opos, oang, pos, ang, fov )

	pos = pos + ang:Up()*-2

	return pos, ang
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self.Owner:EmitSound( Sound("weapons/knife/knife_deploy1.wav") )
	
	return true
end