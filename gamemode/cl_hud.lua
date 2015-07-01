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

local fontstandard = "Verdana"


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
local HudX = CreateClientConVar("deathrun_hud_x", 8, true, false)
local HudY = CreateClientConVar("deathrun_hud_y", 2, true, false)
local HudPos = CreateClientConVar("deathrun_hud_position", 6, true, false) -- 0 topleft, 1 topcenter, 2 topright, 3 centerleft, 4 centercenter, 5 centerright, 6 bottomleft, 7 bottomcenter, 8 bottomright


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

	DR:DrawPlayerHUD( hud_positions[ HudPos:GetInt() +1 ][1] or 8, hud_positions[ HudPos:GetInt() +1 ][2] or 8 )

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

	draw.SimpleText( "TIME LEFT", "deathrun_hud_Small", dx+4,  dy + 16/2, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
	draw.SimpleText( tostring( curvel ), "deathrun_hud_Large", dx + 32 + 4 + 4, dy + 32/2, DR.Colors.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

end