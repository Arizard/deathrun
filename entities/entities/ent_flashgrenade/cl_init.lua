---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

include("shared.lua")
local Endflash, Startflash = 0, 0
local FLASHTIMER = 5; --time in seconds, for the grenade to transition from full white to clear
local EFFECT_DELAY = 2; --time, in seconds when the effects still are going on, even when the whiteness of the flash is gone (set to -1 for no effects at all =]).

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	if not IsValid(self) then return end
	local ply = self
	timer.Simple(2.98, function() ply:DynFlash() end)
end

function ENT:DynFlash()
	if(!IsValid(self)) then return end
		
	local dynamicflash = DynamicLight(self:EntIndex())

	if ( dynamicflash ) then
		dynamicflash.Pos = self:GetPos()
		dynamicflash.r = 255
		dynamicflash.g = 255
		dynamicflash.b = 255
		dynamicflash.Brightness = 5
		dynamicflash.Size = 1000
		dynamicflash.Decay = 1000
		dynamicflash.DieTime = CurTime() + 0.5
	end
end

/*---------------------------------------------------------
Think
---------------------------------------------------------*/
function ENT:Think()
end

/*---------------------------------------------------------
Draw
---------------------------------------------------------*/
function ENT:Draw()
        self:DrawModel()
end

/*---------------------------------------------------------
IsTranslucent
---------------------------------------------------------*/
function ENT:IsTranslucent()
        return true
end

function OnGotFlashUmsg( um )
        Startflash = um:ReadLong()
        Endflash = um:ReadLong()
        FLASHTIMER = Endflash-Startflash
end
usermessage.Hook("flashbang_flash",OnGotFlashUmsg)

function FlashEffect() 
        if Endflash > CurTime() then
                local Alpha
                if(Endflash - CurTime() > FLASHTIMER) then
                        Alpha = 150
                else
                        Alpha = (1 - (CurTime() - (Endflash - FLASHTIMER)) / (Endflash - (Endflash - FLASHTIMER))) * 150
                end
                surface.SetDrawColor(255, 255, 255, math.Round(Alpha))
                surface.DrawRect(0, 0, surface.ScreenWidth(), surface.ScreenHeight())
        end 
end

hook.Add("HUDPaint", "FlashEffect", FlashEffect);

local function StunEffect()
        if (Endflash > CurTime() and Endflash - EFFECT_DELAY - CurTime() <= FLASHTIMER) then
                DrawMotionBlur( 0, (1 - (CurTime() - (Endflash - FLASHTIMER)) / (FLASHTIMER)) / ((FLASHTIMER + EFFECT_DELAY) / (FLASHTIMER * 4)), 0)
        elseif (Endflash > CurTime()) then
                DrawMotionBlur( 0, 0.01, 0);
        end
end
hook.Add( "RenderScreenspaceEffects", "StunEffect", StunEffect )