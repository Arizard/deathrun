if SERVER then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
elseif CLIENT then

	SWEP.PrintName			= "Tactical Knife"	
	SWEP.Author				= "cheesylard" -- Works fine - I lost my own one because of update, since then I use this one with a minor edit
	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "j"

	SWEP.ViewModelFOV = 57

	SWEP.NameOfSWEP			= "weapon_knife" --always make this the name of the folder the SWEP is in.
	killicon.AddFont( SWEP.NameOfSWEP, "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

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



	if ( self.ShootafterTakeout > CurTime() ) then return end		
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )
	local ang = self.Owner:EyeAngles()
	local spos = self.Owner:EyePos()
	local tracedata = {
            start = spos, 
            endpos = spos + ang:Forward()*75,
            mins = Vector(-5,-5,-5),
            maxs = Vector(5,5,5),
            filter = self.Owner,
            mask = MASK_SHOT_HULL
         }
 	local tr = util.TraceHull( tracedata )
 	local dir = ((tr.HitPos or Vector(0,0,0)) - self.Owner:EyePos())
 	dir:Normalize()
 	dir = dir:Angle()
 	dir:Normalize()
 	

		if IsValid( tr.Entity ) then
			if not tr.Entity:IsWorld() then
			
				
				self.Owner:SetAnimation( PLAYER_ATTACK1 );
				self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

				
				--find the direction
				local newHitPos = tr.Entity:NearestPoint( tr.HitPos )

				local customDirection = (newHitPos - self.Owner:GetShootPos())
				customDirection:Normalize()

				--print( customDirection:Dot( self.Owner:GetAimVector() ) )
				if SERVER then

					local bullet = {} -- from weapon_base
			
					bullet.Num 	= 1
					bullet.Src 	= self.Owner:GetShootPos() -- Source
					bullet.Dir 	= customDirection -- Dir of bullet
					bullet.Spread 	= Vector( 0,0, 0 )	-- Aim Cone
					bullet.Tracer	= 0 -- Show a tracer on every x bullets
					bullet.Force	= 5 -- Amount of force to give to phys objects
					bullet.Damage	= 0
					bullet.AmmoType = ""

					self.Owner:FireBullets( bullet )

				
					local dmginfo = DamageInfo()
					dmginfo:SetDamage( self.Primary.Damage )
					dmginfo:SetDamageType( DMG_SLASH )

					if tr.Entity:IsPlayer() then
						if self.Owner:Team() == tr.Entity:Team() then
							dmginfo:SetDamage( 0 )
						end
					end
					tr.Entity:TakeDamageInfo( dmginfo )

					if tr.Entity:IsPlayer() then
						if self.hit == 1 then
							self.Owner:EmitSound( self.FleshHit1 )
							self.hit = 2
							
						elseif self.hit == 2 then
							self.Owner:EmitSound( self.FleshHit2 )
							self.hit = 3
							
						elseif self.hit == 3 then
							self.Owner:EmitSound( self.FleshHit3 )
							self.hit = 4
							
						else
							self.Owner:EmitSound( self.FleshHit4 )
							self.hit = 1
						end
					else
						self.Owner:EmitSound(self.WallSound,100,math.random(95,110))
					end

				end
			end
				
		else
			
			local tr = self.Owner:GetEyeTrace()
			if tr.HitPos:Distance( self.Owner:GetShootPos() ) < 75 then
				util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
				if SERVER then
					self.Owner:EmitSound(self.WallSound,100,math.random(95,110))
				end
			else
				if SERVER then
					self.Owner:EmitSound(self.MissSound,100,math.random(90,120))
				end
			end
			
		end
	
	
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