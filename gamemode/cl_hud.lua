print("Loaded cl_hud.lua")

local HideElements = {
	["CHudBattery"] = true,
	["CHudCrosshair"] = true,
	["CHudHealth"] = true,
	["CHudAmmo"] = true
}

function GM:HUDShouldDraw( el )
	if HideElements[ el ] then
		return false
	else
		return true
	end
end

local fontstandard = "Franklin Gothic"


surface.CreateFont("deathrun_hud_Large", {
	font = fontstandard,
	size = 30,
	antialias = true,
	weight = 800
})
surface.CreateFont("deathrun_hud_Medium", {
	font = fontstandard,
	size = 20,
	antialias = true,
	weight = 800
})
surface.CreateFont("deathrun_hud_Small", {
	font = fontstandard,
	size = 14,
	antialias = true,
	weight = 800
})

--local CrosshairStyle = CreateClientConVar("deathrun_crosshair_style", 1, true, false)
local XHairThickness = CreateClientConVar("deathrun_crosshair_thickness", 2, true, false)
local XHairGap = CreateClientConVar("deathrun_crosshair_gap", 8, true, false)
local XHairSize = CreateClientConVar("deathrun_crosshair_size", 8, true, false)
local XHairRed = CreateClientConVar("deathrun_crosshair_red", 255, true, false)
local XHairGreen = CreateClientConVar("deathrun_crosshair_green", 255, true, false)
local XHairBlue = CreateClientConVar("deathrun_crosshair_blue", 255, true, false)
local XHairAlpha = CreateClientConVar("deathrun_crosshair_alpha", 255, true, false)

-- convars to adjust hud positioning
local HudPos = CreateClientConVar("deathrun_hud_position", 6, true, false) -- 0 topleft, 1 topcenter, 2 topright, 3 centerleft, 4 centercenter, 5 centerright, 6 bottomleft, 7 bottomcenter, 8 bottomright

local RoundNames = {}
RoundNames[ROUND_WAITING] = "Waiting for players"
RoundNames[ROUND_PREP] = "Preparing"
RoundNames[ROUND_ACTIVE] = "Time Left"
RoundNames[ROUND_OVER] = "Round Over"

function GM:HUDPaint()
	
	-- draw the crosshair

	local thick = XHairThickness:GetInt()
	local gap = XHairGap:GetInt()
	local size = XHairSize:GetInt()

	surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), XHairAlpha:GetInt())
	surface.DrawRect(ScrW()/2 - (thick/2), ScrH()/2 - (size + gap/2), thick, size )
	surface.DrawRect(ScrW()/2 - (thick/2), ScrH()/2 + (gap/2), thick, size )
	surface.DrawRect(ScrW()/2 + (gap/2), ScrH()/2 - (thick/2), size, thick )
	surface.DrawRect(ScrW()/2 - (size + gap/2), ScrH()/2 - (thick/2), size, thick )

	local hud_positions = {
		{ 8, 8 },
		{ ScrW()/2 - 228/2, 8 },
		{ ScrW() - 228 - 8, 8 },
		{ 8, ScrH()/2 - 108/2 },
		{ ScrW()/2 - 228/2, ScrH()/2 - 108/2 },
		{ ScrW() - 228 - 8, ScrH()/2 - 108/2 },
		{ 8, ScrH() - 108 - 8 },
		{ ScrW()/2 - 228/2, ScrH() - 108 - 8 },
		{ ScrW() - 228 - 8, ScrH() - 108 - 8 },
	}

	DR:DrawTargetID()
	DR:DrawPlayerHUD( hud_positions[ HudPos:GetInt() +1 ][1] or 8, hud_positions[ HudPos:GetInt() +1 ][2] or 8 )

end

DR.TargetIDAlpha = 0
DR.TargetIDName = ""
DR.TargetIDColor = Color(255,255,255)
local lastTargetCycle = CurTime()

local TargetIDFadeTime = CreateClientConVar( "deathrun_targetid_fade_duration", 1, true, false )
function DR:DrawTargetID()

	local dt = CurTime() - lastTargetCycle
	lastTargetCycle = CurTime()

	local fps = 1/dt
	local fmul = 100/fps

	local tr = LocalPlayer():GetEyeTrace()

	if tr.Hit then
		if tr.Entity then
			if tr.Entity:IsPlayer() then
				

				DR.TargetIDAlpha = 255
				DR.TargetIDName = tr.Entity:Nick()
				DR.TargetIDColor = team.GetColor( tr.Entity:Team() )
				DR.TargetIDPlayer = tr.Entity

			end
		end
	end

	local x , y = ScrW()/2, ScrH()/2 + 16
	DR.TargetIDColor.a = math.pow(DR.TargetIDAlpha, 0.3)*255 / math.pow(255, 0.3)
	local tidText =  DR.TargetIDName..( IsValid(DR.TargetIDPlayer) and " - "..tostring( math.Clamp( DR.TargetIDPlayer:Health(), 0, 100 ) ).."%" or "" ) 
	draw.SimpleText(tidText , "deathrun_hud_Medium", x+1, y+1, Color(0,0,0,DR.TargetIDColor.a*0.9) ,TEXT_ALIGN_CENTER)
	draw.SimpleText( tidText , "deathrun_hud_Medium", x, y, DR.TargetIDColor ,TEXT_ALIGN_CENTER)
	draw.SimpleText( tidText , "deathrun_hud_Medium", x, y, Color(255,255,255,DR.TargetIDColor.a*0.2) ,TEXT_ALIGN_CENTER)

	-- our benchmark is 100fps
	-- e.g. our fade time is 3s
	-- so each frame at 100fps the alpha is alpha - 1/(3s * 100f) * 255 * fmul

	DR.TargetIDAlpha = math.Clamp( DR.TargetIDAlpha - ( 1/( (TargetIDFadeTime:GetFloat()) * 100) ) * 255 * fmul, 0, 255 )

end

function DR:DrawPlayerHUD( x, y )

	-- 228x16 text size 12
	-- 228x16 text size 12

	-- 32x32 text 18, 192x32 text 30
	-- 32x32 text 18, 192x32 text 30

	-- spacing of 4 between all
	local ply = LocalPlayer()

	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end
	end

	local tcol = team.GetColor( ply:Team() )
	local dx, dy = x, y

	surface.SetDrawColor( tcol )
	surface.DrawRect(dx,dy,228,16) -- team box

	draw.SimpleText( string.upper( team.GetName( ply:Team() ) ), "deathrun_hud_Small", dx + 228/2,  dy + 16/2, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- team name

	dy = dy + 16 + 4

	surface.SetDrawColor( DR.Colors.Clouds ) -- Time Left
	surface.DrawRect(dx,dy,228,16)

	draw.SimpleText( string.upper( RoundNames[ ROUND:GetCurrent() ]  or "TIME LEFT" ), "deathrun_hud_Small", dx+4,  dy + 16/2, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText( string.ToMinutesSeconds( math.Clamp( ROUND:GetTimer(), 0, 99999 ) ), "deathrun_hud_Small", dx + 228-4,  dy + 16/2, tcol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	dy = dy + 16 + 4

	surface.SetDrawColor( DR.Colors.Alizarin ) -- hp bar
	surface.DrawRect( dx, dy, 32, 32 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	surface.SetDrawColor( 255,255,255,100 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	local maxhp = 100 -- yeah fuck yall
	local curhp = math.Clamp( ply:Health(), 0, maxhp )
	
	local hpfrac = InverseLerp( curhp, 0, maxhp )

	surface.SetDrawColor( DR.Colors.Alizarin )

	surface.DrawRect( dx + 32 + 4, dy, 192*hpfrac, 32 )

	-- hp text
	draw.SimpleText( "HP", "deathrun_hud_Medium", dx + 32/2, dy + 32/2, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( tostring( curhp ), "deathrun_hud_Large", dx + 32 + 4 + 4, dy + 32/2, DR.Colors.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	dy = dy + 32 + 4

	surface.SetDrawColor( DR.Colors.Turq ) -- vel bar
	surface.DrawRect( dx, dy, 32, 32 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	surface.SetDrawColor( 255,255,255,100 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	local maxvel = 1000 -- yeah fuck yall
	local curvel = math.Round( math.Clamp( ply:GetVelocity():Length2D(), 0, maxvel ) )
	
	local velfrac = InverseLerp( curvel, 0, maxvel )

	surface.SetDrawColor( DR.Colors.Turq )

	surface.DrawRect( dx + 32 + 4, dy, 192*velfrac, 32 )

	-- hp text
	draw.SimpleText( "VL", "deathrun_hud_Medium", dx + 32/2, dy + 32/2, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( tostring( curvel )..((ply.AutoJumpEnabled == true and GetConVar("deathrun_allow_autojump"):GetBool() == true) and " AUTO" or ""), "deathrun_hud_Large", dx + 32 + 4 + 4, dy + 32/2, DR.Colors.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

end

-- make a notification thing
local notifications = {}
local emptynotification = {
	x = 0,
	y = 0,
	text = "",
	dx = 0,
	dy = 0,
	ddx = 0,
	ddy = 0,
	dur = 10,
	born = 0,
}

function DR:AddNotification( msg, x, y, dx, dy, ddx, ddy, dur )

	msg = string.Replace(msg, "%newline%","\n")

	local new = table.Copy( emptynotification )
	new.text = msg
	new.x = x or 0
	new.y = y or 0
	new.dx = dx or 0
	new.dy = dy or 0
	new.ddx = ddx or 0 
	new.ddy = ddy or 0 
	new.dur = dur or 10
	new.born = CurTime()



	table.insert(notifications, new)
end

local lastCycle = CurTime()
function DR:UpdateNotifications( )
	local dt = CurTime() - lastCycle
	lastCycle = CurTime()

	local fps = (1/dt)
	local fmul = 100/fps

	for k,v in ipairs( notifications ) do
		
		local aliveFor = CurTime() - v.born
		local fadein = math.Clamp( Lerp( InverseLerp(aliveFor,0,v.dur/5), 0, 255 ), 0, 255 )

		draw.DrawText( v.text, "deathrun_hud_Medium", v.x+1, v.y+1, Color(0,0,0,fadein), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		draw.DrawText( v.text, "deathrun_hud_Medium", v.x, v.y, Color(255,255,255,fadein), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

		v.x = v.x + v.dx * fmul
		v.y = v.y + v.dy * fmul

		v.dx = v.dx + v.ddx * fmul
		v.dy = v.dy + v.ddy * fmul

		if CurTime() - v.born > v.dur then
			table.remove( notifications, k )
		end
	end

end

hook.Add("HUDPaint","DeathrunNotifications", function()
	DR:UpdateNotifications()
end)