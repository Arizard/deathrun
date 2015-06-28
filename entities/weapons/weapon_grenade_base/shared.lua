if (SERVER) then
        SWEP.Weight                     = 5
        SWEP.AutoSwitchTo               = false
        SWEP.AutoSwitchFrom             = false
end

if (CLIENT) then

        SWEP.PrintName                  = "NADE BASE"
        SWEP.Slot                               = 4
        SWEP.SlotPos                    = 1
        SWEP.DrawAmmo                   = false
        SWEP.DrawCrosshair              = false
        SWEP.ViewModelFOV                       = 65
        SWEP.ViewModelFlip              = true
        SWEP.CSMuzzleFlashes            = false
        SWEP.IconLetter                         = "P"
end


SWEP.Author                             = "kna_rus"
SWEP.Contact                            = ""
SWEP.Purpose                            = ""

SWEP.Spawnable                          = true
SWEP.AdminSpawnable                     = true

SWEP.ViewModel                          = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel                                 = "models/weapons/w_eq_flashbang.mdl"

SWEP.Primary.ClipSize                   = -1
SWEP.Primary.DefaultClip                = 1
SWEP.Primary.Automatic                  = true
SWEP.Primary.Ammo                       = "none"

SWEP.Secondary.ClipSize                 = -1
SWEP.Secondary.DefaultClip              = -1
SWEP.Secondary.Automatic                = true
SWEP.Secondary.Ammo                     = "none"

SWEP.NadeClass = "base_entity"

SWEP.Primed                             = 0
SWEP.Throw                                      = CurTime()
SWEP.PrimaryThrow                               = true
/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
        self:SetWeaponHoldType("grenade")
		if(SERVER) then
			if(self.GetPhysicsObject) then
				local phys = self:GetPhysicsObject()
				if(phys:IsValid()) then
					phys:EnableMotion(false)
				end
			end
		end
end

/*---------------------------------------------------------
Holster
---------------------------------------------------------*/
function SWEP:Holster()
        self.Primed = 0
        self.Throw = CurTime()
        return true
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function SWEP:Think()

        if self.Primed == 1 and not self.Owner:KeyDown(IN_ATTACK) and self.PrimaryThrow then
                if self.Throw < CurTime() then
                        self.Primed = 2
                        self.Throw = CurTime() + 1.5

                        self.Weapon:SendWeaponAnim(ACT_VM_THROW)
                        self.Owner:SetAnimation(PLAYER_ATTACK1)
						if(SERVER) then
							self.Owner:EmitSound("radio/ct_fireinhole.wav")
						end
                        BroadcastLua("chat.AddText(Player("..self.Owner:UserID().."),Color(220,220,220,255),\": fire in the hole!\")")

						if self.ThrowFar then
							self:ThrowFar()
						end
                end

        elseif self.Primed == 1 and not self.Owner:KeyDown(IN_ATTACK2) and not self.PrimaryThrow then
                if self.Throw < CurTime() then
                        self.Primed = 2
                        self.Throw = CurTime() + 1.5

                        self.Weapon:SendWeaponAnim(ACT_VM_THROW)
                        self.Owner:SetAnimation(PLAYER_ATTACK1)
                        self.Owner:EmitSound("radio/ct_fireinhole.wav")
                        BroadcastLua("chat.AddText(Player("..self.Owner:UserID().."),Color(220,220,220,255),\": fire in the hole!\")")

						if self.ThrowShort then
							self:ThrowShort()
						end
                end
        end
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

        if self.Throw < CurTime() and self.Primed == 0 then
                self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
                self.Primed = 1
                self.Throw = CurTime() + 1
                self.PrimaryThrow = true
        end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

        if self.Throw < CurTime() and self.Primed == 0 then
                self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
                self.Primed = 1
                self.Throw = CurTime() + 1
                self.PrimaryThrow = false
        end
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
        self.Throw = CurTime() + 0.75
        self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
        return true
end

/*---------------------------------------------------------
DrawWeaponSelection
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
        draw.SimpleText(self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER)
end

/*---------------------------------------------------------
ThrowFar
---------------------------------------------------------*/
function SWEP:ThrowFar()

        if self.Primed != 2 then return end

        local tr = self.Owner:GetEyeTrace()

        if (!SERVER) then return end

        local ent = ents.Create (self.NadeClass)

                        local v = self.Owner:GetShootPos()
                                v = v + self.Owner:GetForward() * 1
                                v = v + self.Owner:GetRight() * 3
                                v = v + self.Owner:GetUp() * 1
                        ent:SetPos( v )

        ent:SetAngles ((Vector(math.random(1,100),math.random(1,100),math.random(1,100))):Angle())
        ent.GrenadeOwner = self.Owner
        ent:Spawn()

        local phys = ent:GetPhysicsObject()

        ent:SetVelocity(self.Owner:GetVelocity())
        phys:ApplyForceCenter(self.Owner:GetAimVector() *2000 *1.2 + Vector(0,0,400) )
        phys:AddAngleVelocity(Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200)))

        self.Owner:StripWeapon(self.Owner:GetActiveWeapon():GetClass())

end

/*---------------------------------------------------------
ThrowShort
---------------------------------------------------------*/
function SWEP:ThrowShort()

        if self.Primed != 2 then return end

        local tr = self.Owner:GetEyeTrace()

        if (!SERVER) then return end

        local ent = ents.Create (self.NadeClass)

                        local v = self.Owner:GetShootPos()
                                v = v + self.Owner:GetForward() * 2
                                v = v + self.Owner:GetRight() * 3
                                v = v + self.Owner:GetUp() * -3
                        ent:SetPos( v )

        ent:SetAngles ((Vector(math.random(1,100),math.random(1,100),math.random(1,100))):Angle())
        ent.GrenadeOwner = self.Owner
        ent:Spawn()

        local phys = ent:GetPhysicsObject()

        ent:SetVelocity(self.Owner:GetVelocity())
        phys:ApplyForceCenter(self.Owner:GetAimVector() *700*2 + Vector(0,0,200) )
        phys:AddAngleVelocity(Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200)))

        self.Owner:StripWeapon(self.Owner:GetActiveWeapon():GetClass())

end