print("Loaded cl_hud.lua")

--local CrosshairStyle = CreateClientConVar("deathrun_crosshair_style", 1, true, false)
local XHairThickness = CreateClientConVar("deathrun_crosshair_thickness", 2, true, false)
local XHairGap = CreateClientConVar("deathrun_crosshair_gap", 8, true, false)
local XHairSize = CreateClientConVar("deathrun_crosshair_size", 8, true, false)
local XHairRed = CreateClientConVar("deathrun_crosshair_red", 255, true, false)
local XHairGreen = CreateClientConVar("deathrun_crosshair_green", 255, true, false)
local XHairBlue = CreateClientConVar("deathrun_crosshair_blue", 255, true, false)
local XHairAlpha = CreateClientConVar("deathrun_crosshair_alpha", 255, true, false)

--start and end cues
local CuesConVar = CreateClientConVar("deathrun_round_cues", 1, true, false)

-- convars to adjust hud positioning
local HudPos = CreateClientConVar("deathrun_hud_position", 6, true, false) -- 0 topleft, 1 topcenter, 2 topright, 3 centerleft, 4 centercenter, 5 centerright, 6 bottomleft, 7 bottomcenter, 8 bottomright
local HudAmmoPos = CreateClientConVar("deathrun_hud_ammo_position", 8, true, false) 
local HudTheme = CreateClientConVar("deathrun_hud_theme", 0, true, false) -- different themes
local HudAlpha = CreateClientConVar("deathrun_hud_alpha", 255, true, false)


local HideElements = {
	["CHudBattery"] = false,
	["CHudCrosshair"] = false,
	["CHudHealth"] = false,
	["CHudAmmo"] = false,
	["CHudDamageIndicator"] = false
}

hook.Add("HUDPaint","FixCHudAmmo", function()
	if HudTheme:GetInt() == 2 then
		HideElements["CHudAmmo"] = true
	else
		HideElements["CHudAmmo"] = false
	end
	hook.Remove("HUDPaint", "FixCHudAmmo")
end)

local hudThemeCache = HudTheme:GetInt()
cvars.AddChangeCallback( "deathrun_hud_theme", function( cv, o, n )
	if math.floor(tonumber(n)) == 2 then
		HideElements["CHudAmmo"] = true
	else
		HideElements["CHudAmmo"] = false
	end
end)

function GM:HUDShouldDraw( el )
	local hide = HideElements[ el ]
	if hide == false then
		return false
	else
		return true
	end
end

local fontstandard = "Roboto Bold"


surface.CreateFont("deathrun_hud_Xlarge", {
	font = fontstandard,
	size = 48,
	antialias = true,
	weight = 1200
})

surface.CreateFont("deathrun_hud_Large", {
	font = fontstandard,
	size = 48,
	antialias = true,
	weight = 800
})
surface.CreateFont("deathrun_hud_Medium", {
	font = fontstandard,
	size = 20,
	antialias = true,
	weight = 800
})
surface.CreateFont("deathrun_hud_Medium_light", {
	font = "Roboto Regular",
	size = 20,
	antialias = true,
})
surface.CreateFont("deathrun_hud_Small", {
	font = fontstandard,
	size = 14,
	antialias = true,
})


DR.HUDDrawFunctions = {}
DR.HUDDrawFunctions[0] = { function(x,y) DR:DrawPlayerHUD( x, y ) end, function(x,y) DR:DrawPlayerHUDAmmo( x, y ) end }

-- make it easy to add new HUDs
function DR:AddCustomHUD( index, leftfunc, rightfunc ) -- leftfunc e.g. health and velocity, rightfunc e.g. ammo, points
	DR.HUDDrawFunctions[ index ] = { leftfunc, rightfunc }
end

--sasshud
DR:AddCustomHUD( 1, function(x,y) DR:DrawPlayerHUDSass( x, y ) end, function(x,y) DR:DrawPlayerHUDAmmoSass( x, y ) end )
--classichud
DR:AddCustomHUD( 2, function(x,y) DR:DrawPlayerHUDClassic( x, y ) end, function(x,y) DR:DrawPlayerHUDAmmoClassic( x, y ) end )

-- NOTE:
-- For those who want to add custom HUDs to the gamemode: 
-- For index, choose a number between 0 and 12 inclusive. Choosing the numbers 0, 1 or 2 will overwrite one of the default HUDs.
-- Two huds with the same index will overwrite eachother.
-- Create a function to draw your left-side hud (e.g. health, velocity, avatar) and substitute it for leftfunc.
-- Create a function to draw your righ-side hud (e.g. ammo, points) and substitute it for rightfunc.
-- leftfunc and rightfunc are both passed the parameters x and y, designating the position of their top-left corner
-- width and height should be within the values 228 and 108 respectively, e.g. 228 wide and 108 high, otherwise some clipping may occur with the edges of the screen.


local RoundNames = {}
RoundNames[ROUND_WAITING] = "Waiting for players"
RoundNames[ROUND_PREP] = "Preparing"
RoundNames[ROUND_ACTIVE] = "Time Left"
RoundNames[ROUND_OVER] = "Round Over"

local RoundEndData = {
	Active = false,
	BeginTime = 0,
}
net.Receive("DeathrunSendMVPs", function()
	RoundEndData = net.ReadTable()
	RoundEndData.BeginTime = CurTime()
	RoundEndData.Active = true

	if CuesConVar:GetBool() == true then
		if RoundEndData.winteam == 1 then
			local stalematesounds = {
				"ambient/animal/cow.wav",
				"ambient/misc/flush1.wav",
				"npc/crow/alert2.wav",
				"ambient/animal/dog_med_inside_bark_2.wav"
			}
			surface.PlaySound(table.Random(stalematesounds))
		else
			local endingsounds = {
			"ambient/alarms/warningbell1.wav",
			}
			surface.PlaySound(table.Random(endingsounds))
		end
	end

	hook.Call("DeathrunRoundWin", nil, RoundEndData.winteam)
end)

function GM:HUDPaint()
	
	-- draw the crosshair

	

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


	-- draw crosshair and account for thirdperson mode
	if GetConVar("deathrun_thirdperson_enabled"):GetBool() == true then
		local x,y = 0,0
		local tr = LocalPlayer():GetEyeTrace()
		x = tr.HitPos:ToScreen().x
		y = tr.HitPos:ToScreen().y

		DR:DrawCrosshair( x,y )
	else
		DR:DrawCrosshair( ScrW()/2, ScrH()/2 )
	end

	DR:DrawTargetID()

	local hx = hud_positions[ HudPos:GetInt() +1 ][1] or 8
	local hy = hud_positions[ HudPos:GetInt() +1 ][2] or 8
	local ax = hud_positions[ HudAmmoPos:GetInt() +1 ][1] or 8
	local ay = hud_positions[ HudAmmoPos:GetInt() +1 ][2] or 8

	local hudnum = HudTheme:GetInt()

	if DR.HUDDrawFunctions[ hudnum ] then
		if DR.HUDDrawFunctions[ hudnum ][1] then
			DR.HUDDrawFunctions[ hudnum ][1](hx, hy)
		end
		if DR.HUDDrawFunctions[ hudnum ][2] then
			DR.HUDDrawFunctions[ hudnum ][2](ax, ay)
		end
	end

	if RoundEndData.Active then -- check if it's stalemate, and don't do the thing, zhu li!
		DR:DrawWinners( RoundEndData.winteam, RoundEndData.mvps, ScrW()/2 - 628/2, 24, RoundEndData.winteam == 1 and true or false)
		if CurTime() > RoundEndData.BeginTime + RoundEndData.duration then
			RoundEndData.Active = false
		end
	end

end


function DR:DrawCrosshair( x, y )
	local thick = XHairThickness:GetInt()
	local gap = XHairGap:GetInt()
	local size = XHairSize:GetInt()

	surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), XHairAlpha:GetInt())
	surface.DrawRect(x - (thick/2), y - (size + gap/2), thick, size )
	surface.DrawRect(x - (thick/2), y + (gap/2), thick, size )
	surface.DrawRect(x + (gap/2), y - (thick/2), size, thick )
	surface.DrawRect(x - (size + gap/2), y - (thick/2), size, thick )
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

	local tr = LocalPlayer() and LocalPlayer():GetEyeTrace() or {}

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
	deathrunShadowTextSimple( tidText , "deathrun_hud_Medium", x, y, DR.TargetIDColor ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
	deathrunShadowTextSimple( tidText , "deathrun_hud_Medium", x, y, Color(255,255,255,DR.TargetIDColor.a*0.2) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	-- our benchmark is 100fps
	-- e.g. our fade time is 3s
	-- so each frame at 100fps the alpha is alpha - 1/(3s * 100f) * 255 * fmul

	DR.TargetIDAlpha = math.Clamp( DR.TargetIDAlpha - ( 1/( (TargetIDFadeTime:GetFloat()) * 100) ) * 255 * fmul, 0, 255 )

	-- draw floating names if you're on the Death team
	-- draw them for Runners as well, but not thru walls
	for _, ply in ipairs(player.GetAll()) do

		local data = ply:EyePos():ToScreen()
		local draw = false

		if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and ply ~= LocalPlayer() then
			if LocalPlayer():Team() == ply:Team() and LocalPlayer():Alive() then
				draw = true
			end
			if (LocalPlayer():Team() ~= TEAM_RUNNER) or LocalPlayer():Alive() == false then
				if (ply ~= LocalPlayer():GetObserverTarget()) or (LocalPlayer():GetObserverMode() ~= OBS_MODE_IN_EYE) then
					draw = true
				end
			end
		end

		if draw then
			local a = 0
			local dist = LocalPlayer():EyePos():Distance( ply:EyePos() )
			if dist > 750 then
				a = 0
			elseif dist < 200 then
				a = 255
			else
				a = InverseLerp( dist, 750, 200 )*255
			end

			local tcol = team.GetColor( ply:Team() )
			tcol.a = a

			deathrunShadowTextSimple( ply:Nick(), "deathrun_hud_Medium", data.x, data.y-32, Color(255,255,255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			deathrunShadowTextSimple( team.GetName( ply:Team() ), "deathrun_hud_Small", data.x, data.y-16, tcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

end

local clouds = table.Copy(DR.Colors.Clouds)
local aliz = table.Copy(DR.Colors.Alizarin)
--local turq = table.Copy(DR.Colors.Turq) -- store these separately so we can edit their alpha values

function DR:DrawPlayerHUD( x, y )
	
	

	turq = table.Copy(DR.Colors.Turq)
	local alpha = HudAlpha:GetInt()

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
	otcol = table.Copy( tcol )
	tcol.a = alpha
	local dx, dy = x, y

	
	clouds.a = alpha
	aliz.a = alpha
	turq.a = alpha


	surface.SetDrawColor( tcol )
	surface.DrawRect(dx,dy,228,16) -- team box
	surface.SetDrawColor(0,0,0,100)
	surface.DrawRect(dx,dy+14,228,2)

	local teamtext = string.upper( team.GetName( ply:Team() ) )
	if ply ~= LocalPlayer() then
		teamtext = string.upper( ply:Nick() )
	end

	deathrunShadowTextSimple( teamtext , "deathrun_hud_Small", dx + 228/2,  dy + 16/2, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1) -- team name

	dy = dy + 16 + 4

	surface.SetDrawColor( clouds ) -- Time Left
	surface.DrawRect(dx,dy,228,16)

	deathrunShadowTextSimple( string.upper( RoundNames[ ROUND:GetCurrent() ]  or "TIME LEFT" ), "deathrun_hud_Small", dx+4,  dy + 16/2, otcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	deathrunShadowTextSimple( string.ToMinutesSeconds( math.Clamp( ROUND:GetTimer(), 0, 99999 ) ), "deathrun_hud_Small", dx + 228-4,  dy + 16/2, otcol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	dy = dy + 16 + 4

	surface.SetDrawColor( aliz ) -- hp bar
	surface.DrawRect( dx, dy, 32, 32 )
	surface.SetDrawColor( 255,255,255,(alpha/255)*50 )
	surface.DrawRect( dx, dy, 32, 32 )
	surface.SetDrawColor( aliz )
	surface.DrawRect( dx, dy, 32, 32 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	surface.SetDrawColor( 255,255,255,(alpha/255)*50 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	local maxhp = 100 -- yeah fuck yall
	local curhp = math.Clamp( ply:Health(), 0, 999 )	
	local hpfrac = math.Clamp( InverseLerp( curhp, 0, maxhp ), 0, 1 )

	surface.SetDrawColor( aliz )

	surface.DrawRect( dx + 32 + 4, dy, 192*hpfrac, 32 )

	-- hp text
	deathrunShadowTextSimple( "HP", "deathrun_hud_Medium", dx + 32/2, dy + 32/2, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
	deathrunShadowTextSimple( tostring( curhp ), "deathrun_hud_Large", dx + 32 + 4 + 4, dy + 32/2-1, DR.Colors.Text.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )

	dy = dy + 32 + 4

	surface.SetDrawColor( turq ) -- vel bar
	surface.DrawRect( dx, dy, 32, 32 )
	surface.SetDrawColor( 255,255,255,(alpha/255)*50 ) -- vel bar
	surface.DrawRect( dx, dy, 32, 32 )
	surface.SetDrawColor( turq ) -- vel bar
	surface.DrawRect( dx, dy, 32, 32 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	surface.SetDrawColor( 255,255,255,(alpha/255)*50 )
	surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

	local maxvel = 1000 -- yeah fuck yall
	local curvel = math.Round( math.Clamp( ply:GetVelocity():Length2D(), 0, maxvel ) )
	
	local velfrac = InverseLerp( curvel, 0, maxvel )

	surface.SetDrawColor( turq )

	surface.DrawRect( dx + 32 + 4, dy, 192*velfrac, 32 )

	-- hp text
	deathrunShadowTextSimple( "VL", "deathrun_hud_Medium", dx + 32/2, dy + 32/2, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
	deathrunShadowTextSimple( tostring( curvel )..((ply.AutoJumpEnabled == true and GetConVar("deathrun_allow_autojump"):GetBool() == true) and " AUTO" or ""), "deathrun_hud_Large", dx + 32 + 4 + 4, dy + 32/2 -1, DR.Colors.Text.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )


end
local orange = table.Copy(DR.Colors.Orange) 
local clouds2 = table.Copy(DR.Colors.Clouds)
function DR:DrawPlayerHUDAmmo( x, y )

	local alpha = HudAlpha:GetInt()
	orange.a = alpha
	clouds2.a = alpha

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

	local wep = ply:GetActiveWeapon()

	if not IsValid( wep ) then
		return
	end

	local wepdata = GetWeaponHUDData( ply )
	if wepdata.HoldType == "melee" or wepdata.HoldType == "knife" then return end

	local tcol = team.GetColor( ply:Team() )
	local dx, dy = x, y

	local otrans = table.Copy( orange )
	otrans.a = 200*(alpha/255)

	surface.SetDrawColor( clouds2 )
	surface.DrawRect( dx, dy, 228, 16 )
	surface.SetDrawColor( otrans )
	surface.DrawRect( dx, dy, 228, 16 )


	dy = dy + 16  +4

	surface.SetDrawColor( orange ) -- name of wep
	surface.DrawRect( dx, dy, 228, 32 )
	surface.SetDrawColor( 255,255,255,(alpha/255)*50 )
	surface.DrawRect( dx, dy, 228, 32 )
	surface.SetDrawColor( orange )
	surface.DrawRect( dx, dy, 228, 32 )	




	if IsValid( wep ) then
		deathrunShadowTextSimple( tostring( wepdata.Name ), "deathrun_hud_Large", dx + 224, dy + 32/2 -1, DR.Colors.Text.Clouds, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1 )
	else
		return
	end

	dy = dy + 32 + 4

	if IsValid( wep ) then

		local frac = wepdata.Clip1/wepdata.Clip1Max
		frac = math.Clamp( frac, 0, 1 )

		surface.SetDrawColor( orange )
		surface.DrawRect( dx, dy, 32, 32 )
		surface.SetDrawColor( 255,255,255,(alpha/255)*50 )
		surface.DrawRect( dx, dy, 32, 32 )
		surface.SetDrawColor( orange )
		surface.DrawRect( dx, dy, 32, 32 )
		surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

		surface.SetDrawColor( 255,255,255,(alpha/255)*50 )
		surface.DrawRect( dx + 32 + 4, dy, 192, 32 )

		surface.SetDrawColor( orange )
		surface.DrawRect( dx + 32 + 4, dy, 192*frac, 32 )

		deathrunShadowTextSimple( "AM", "deathrun_hud_Medium", dx + 32/2, dy + 32/2, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)

		if wepdata.ShouldDrawHUD then
			deathrunShadowTextSimple( tostring( wepdata.Clip1 ).." +"..tostring( wepdata.Remaining1 ), "deathrun_hud_Large", dx + 32 + 192, dy + 32/2 -1, DR.Colors.Text.Clouds, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1)
		end
	end

	dy = dy + 32 + 4

	surface.SetDrawColor( clouds2 )
	surface.DrawRect( dx, dy, 228, 16 )
	surface.SetDrawColor( otrans )
	surface.DrawRect( dx, dy, 228, 16 )

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

net.Receive("DeathrunNotification", function()
	DR:AddNotification( net.ReadString(), ScrW()-32,ScrH()/6, 0, -0.35, 0, -0.00025, 10 )
end)



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

	MsgC(Color(0,255,0),msg.."\n")
end

concommand.Add("deathrun_test_notification", function(ply, cmd, args)

	local msg = ""
	for i = 1, #args do
		msg = msg .. args[i].." "
	end

	DR:AddNotification( msg, ScrW()/2, ScrH()/2, 0, 0, 0, 0, 10 )

end)


local lastCycle = CurTime()
function DR:UpdateNotifications( )
	local dt = CurTime() - lastCycle
	lastCycle = CurTime()

	local fps = (1/dt)
	local fmul = 100/fps

	for k,v in ipairs( notifications ) do
		
		local aliveFor = CurTime() - v.born
		local fadein = math.Clamp( Lerp( InverseLerp(aliveFor,0,0.5), 0, 255 ), 0, 255 )
		local scalein = math.pow(fadein/255, 1/4)

		

		deathrunShadowTextSimple( v.text, "deathrun_hud_Medium", v.x+1, v.y+1, Color(0,0,0,fadein), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		deathrunShadowTextSimple( v.text, "deathrun_hud_Medium", v.x, v.y, Color(255,255,255,fadein), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )


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


function DR:DrawWinners( winteam, tbl_mvps, x, y, stalemate )
	local col = stalemate == false and team.GetColor( winteam ) or HexColor("#303030")

	local spread = 2
	local w, h = 628, 88
	local sinval = math.sin(CurTime()*1.5)
	local cosval = math.cos(CurTime()*1.5)
	local doubleval = math.cos(CurTime()*0.7)
	local mw, mh = w, 24
	local gap = 4

	surface.SetDrawColor( col )
	surface.DrawRect(x,y,w,h)

	if not stalemate then
		surface.SetDrawColor( DR.Colors.Clouds )
		surface.DrawRect(x, y + h + gap, mw, mh)
		--deathrunShadowTextSimple( "NOTABLE PLAYERS", "deathrun_hud_Medium", x + w/2, y + h + gap +mh/2 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
		-- draw MVPs
		surface.SetDrawColor( col )
		for i = 1, #tbl_mvps do
			local name = tbl_mvps[i]
			if name then
				surface.DrawRect(x, y+h+(gap+mh)*i + gap, mw, mh)
				deathrunShadowTextSimple( name, "deathrun_hud_Medium", x + w/2, y + h +(gap+mh)*i + gap +mh/2 - 1, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
			end
		end
	end

	deathrunShadowTextSimple( stalemate == false and string.upper(team.GetName( winteam ).." win the round!") or "STALEMATE!", "deathrun_hud_Xlarge", x + w/2, y + h/2, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
	surface.SetDrawColor( DR.Colors.Clouds )
	surface.DrawRect(x, y + h + gap, mw, mh)
	deathrunShadowTextSimple( stalemate and "YOU'RE ALL TERRIBLE!" or "MOST VALUABLE PLAYERS", "deathrun_hud_Medium", x + w/2, y + h + gap +mh/2 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0 )
end

function GM:HUDWeaponPickedUp( wep )
	DR:AddNotification( "+ "..(wep.PrintName or "Weapon"), ScrW()-32, ScrH()/2, 0, -0.2, 0, 0, 5 )
end
function GM:HUDAmmoPickedUp( name, amt )
	DR:AddNotification( "+ "..(amt or 0).." "..(name or "Ammo"), ScrW()-32, ScrH()/2 + 20, 0, -0.2, 0, 0, 5 )
end

-- sass hud
surface.CreateFont("sassLarge",
{
	font = "Coolvetica",
	size = 56,
	antialias = true,
})

surface.CreateFont("sassMedium",
{
	font = "Coolvetica",
	size = 36,
	antialias = true,
	weight = 100,
})
surface.CreateFont("sassSmall",
{
	font = "Coolvetica",
	size = 20,
	antialias = true,
	weight = 500,
})
surface.CreateFont("sassTiny",
{
	font = "Coolvetica",
	size = 12,
	antialias = true,
	weight = 500,
})

if IsValid( avatar ) then avatar:Remove() end
local avatar = IsValid(avatar) and avatar or vgui.Create("AvatarImage")
avatar:SetSize(46,46)
avatar:SetPos(0,0)
avatar:SetPlayer( LocalPlayer(), 64 )
avatar.ply = LocalPlayer()
avatar.visible = true
avatar.desiredpos = {-128, 0}

function avatar:Think()
	local ply = LocalPlayer()

	if not self.desiredpos then return end

	if not IsValid( ply ) then return end

	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end
	end

	if ply ~= self.ply then
		self.ply = ply
		self:SetPlayer( ply, 64 )
	end

	if HudTheme:GetInt() == 1 and self.visible == false then
		self:SetPos( self.desiredpos[1] or 0, self.desiredpos[2] or 0 )
		self.visible = true
	end
	if HudTheme:GetInt() ~= 1 and self.visible == true then
		self:SetPos( -128, self.desiredpos[2] or 0 )
		self.visible = false
	end

	self:SetAlpha( HudAlpha:GetInt() )

end

function DR:DrawPlayerHUDSass( x, y )
	-- dimensions:
	-- 228 x 108
	local ply = LocalPlayer()

	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end
	end

	local w, h = 228, 108
	local alpha = HudAlpha:GetInt()
	local amul = alpha/255

	surface.SetDrawColor(255,0,0)
	--surface.DrawOutlinedRect( x,y,w,h )

	surface.SetDrawColor( HexColor("#101010", alpha) )
	--size of avatar: 46x46
	--size of container: 48x48
	draw.RoundedBox( 2, x + 8, y + h/2 - 24, 48,48, HexColor("#101010", alpha) )

	-- hp bar
	-- width 228 - 16 - 48
	-- height 20
	draw.RoundedBox(2, x + 8+48, y + h/2 - 10, 228-16-48,20, HexColor("#101010", alpha))
	surface.SetDrawColor( HexColor("#909090", alpha/2) )
	surface.DrawRect( x + 8 + 48, y + h/2 - 10 + 2, 228-16-48-2, 16)

	-- velocity
	draw.RoundedBox(2, x + 8+48, y + h/2 + 8, 228-16-48,10, HexColor("#101010", alpha))
	surface.SetDrawColor( HexColor("#909090", alpha/2) )
	surface.DrawRect( x + 8 + 48, y + h/2 + 8 + 2, 228-16-48-2, 6)

	local maxvel = 1500 -- yeah fuck yall
	local curvel = math.Round( math.Clamp( ply:GetVelocity():Length2D(), 0, maxvel ) )
	local velfrac = InverseLerp( curvel, 0, maxvel )

	surface.SetDrawColor( Color(50,50,255, alpha) )
	surface.DrawRect( x + 8 + 48, y + h/2 + 8 + 2, (228-16-48-2)*velfrac, 6)
	surface.SetDrawColor( Color(255,255,255, 5*amul) )
	surface.DrawRect( x + 8 + 48, y + h/2 + 8 + 2, (228-16-48-2)*velfrac, 2)

	local maxhp = 100 -- yeah fuck yall
	local curhp = math.Clamp( ply:Health(), 0, 999 )	
	local hpfrac = math.Clamp( InverseLerp( curhp, 0, maxhp ), 0, 1 )

	surface.SetDrawColor( Color(50,255,50, alpha) )
	surface.DrawRect(x + 8 + 48, y + h/2 - 10 + 2, (228-16-48-2)*hpfrac, 16)
	surface.SetDrawColor( Color(255,255,255, 40*amul) )
	surface.DrawRect(x + 8 + 48, y + h/2 -10 + 2, (228-16-48-2)*hpfrac, 7)

	-- HP TEXT
	deathrunShadowTextSimple(tostring(curhp), "sassLarge", x+128,y + h/2+2, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2 )
	deathrunShadowTextSimple("HP", "sassSmall", x+132,y + h/2+1, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2 )

	deathrunShadowTextSimple(tostring(curvel).." VL", "sassSmall", x+w - 12,y + h/2 + 24+1, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2 )

	-- team text
	local teamtext = team.GetName(ply:Team())

	if ply ~= LocalPlayer() then -- must be spectating
		teamtext = ply:Nick()
	end

	deathrunShadowTextSimple(teamtext.." - "..string.ToMinutesSeconds( math.Clamp( ROUND:GetTimer(), 0, 99999 ) ), "sassSmall", x+8, y + h/2 + 24, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2 )


	-- position avatar
	local avx, avy = avatar:GetPos()
	if avx ~= x+9 or avy ~= y + h/2 - 24+1 then
		avatar:SetPos( x+9, y + h/2 - 23 )
	end

	avatar.desiredpos = { avx, avy }

end
function DR:DrawPlayerHUDAmmoSass( x, y )

	local alpha = HudAlpha:GetInt()
	
	local w, h = 228, 108
	surface.SetDrawColor(255,0,0)

	local ply = LocalPlayer()

	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end
	end

	local wep = ply:GetActiveWeapon()

	if not IsValid( wep ) then
		return
	end

	local wepdata = GetWeaponHUDData( ply )

	local tcol = team.GetColor( ply:Team() )
	local dx, dy = x, y

	if IsValid( wep ) then
		local frac = wepdata.Clip1/wepdata.Clip1Max
		frac = math.Clamp( frac, 0, 1 )
		--print( wepdata.ShouldDrawHUD )
		if wepdata.ShouldDrawHUD == true then
			deathrunShadowTextSimple( wepdata.Name, "sassSmall", x + w - 4, y + h - 68, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2 )
			deathrunShadowTextSimple( tostring( wepdata.Clip1 ).." +"..tostring( wepdata.Remaining1 ), "sassLarge", x + w - 4, y + h - 20, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2 )
		end
	else
		return
	end


end

-- draw classic deathrun HUD

surface.CreateFont( "Deathrun_Smooth", { font = "Trebuchet18", size = 14, weight = 700, antialias = true } ) -- taken from Mr. Gash's gamemode
surface.CreateFont( "Deathrun_SmoothMed", { font = "Trebuchet18", size = 24, weight = 700, antialias = true } )
surface.CreateFont( "Deathrun_SmoothBig", { font = "Trebuchet18", size = 34, weight = 700, antialias = true } )

function DR:DrawPlayerHUDClassic(x,y)

	local ply = LocalPlayer()

	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		if IsValid( ply:GetObserverTarget() ) then
			ply = ply:GetObserverTarget()
		end
	end

	local w, h = 228, 108
	local alpha = HudAlpha:GetInt()
	local amul = alpha/255

	local hw, hh = 204, 36

	draw.RoundedBox( 4, x + w/2 - hw/2, y+h-hh, hw, hh, Color( 44, 44, 44, 175*amul ) )
	draw.RoundedBox( 0, x + w/2 - hw/2 +4, y+h-hh+4, hw - 8, hh-8, Color( 180, 80, 80, 255*amul*amul ) )

	local maxhp = 100 -- yeah fuck yall
	local curhp = math.Clamp( ply:Health(), 0, 999 )	
	local hpfrac = math.Clamp( InverseLerp( curhp, 0, maxhp ), 0, 1 )

	draw.RoundedBox( 0, x + w/2 - hw/2 +4, y+h-hh+4, (hw - 8)*hpfrac, hh-8, Color( 80, 180, 60, 255*amul ) )

	deathrunShadowText( tostring(curhp > 999 and "dafuq" or math.max( curhp, 0 ) ), "Deathrun_SmoothBig", x+w/2 - hw/2 + 5, y + h - hh, Color(255,255,255), nil, nil, 1 )

	-- timer
	local timetext = string.ToMinutesSeconds( ROUND:GetTimer() )
	local tw, th = hw/2, hh*1.25
	local tx, ty = x + w/2 - tw/2, y + h - hh - 4 - th 
	draw.RoundedBox( 4, tx, ty, tw, th, Color(44,44,44,175*amul) )
	deathrunShadowText( timetext, "Deathrun_SmoothBig", tx + tw/2, ty + 4, Color(255,255,255), TEXT_ALIGN_CENTER, nil, 1 )

	local spectext = ""
	if ply ~= LocalPlayer() then
		spectext = ply:Nick()
	end
	deathrunShadowTextSimple( spectext, "Deathrun_Smooth", tx + tw/2, ty, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)

end

function DR:DrawPlayerHUDAmmoClassic(x,y)

end

function GetWeaponHUDData( ply )

	local data = {}
	local weptable = {}
	local wep = ply:GetActiveWeapon()

	if IsValid( wep ) then
		weptable = wep:GetTable()

		data.Name = wep:GetPrintName() or "Weapon"
		data.Clip1 = wep:Clip1() or -1
		data.Clip2 = wep:Clip2() or -1
		data.Clip1Max = 1
		data.Clip2Max = 1
		data.Remaining1 = ply:GetAmmoCount( wep:GetPrimaryAmmoType()  ) or wep:Ammo1() or 0
		data.Remaining2 = ply:GetAmmoCount( wep:GetSecondaryAmmoType()  ) or wep:Ammo2() or 0
		data.HoldType = weptable.HoldType or "melee"
		if weptable.Primary then
			data.Clip1Max = weptable.Primary.ClipSize or data.Clip2Max
		end
		if weptable.Secondary then
			data.Clip2Max = weptable.Secondary.ClipSize or data.Clip2Max
		end

		data.ShouldDrawHUD = true
		if data.Clip1 < 0 then data.ShouldDrawHUD = false end
	end

	return data	

end


if IsValid( DR.TVBorder ) then
	DR.TVBorder:Remove()
end

local meme = CreateClientConVar("deathrun_vhs7", 0, false, false)
if meme:GetBool() == true then
	DR.TVBorder = vgui.Create("DHTML")
	DR.TVBorder:SetSize( ScrW(), ScrH() )
	DR.TVBorder:SetPos(0,0)
	DR.TVBorder:OpenURL("http://arizard.github.io/overlay.html")
end

hook.Add("RenderScreenspaceEffects", "DeathrunTVBorder", function()
	if meme:GetBool() == true then
		DrawSharpen( 1.1, 1.7 )
		DrawMotionBlur( 0.4, 0.8, 0.005 )
	end
end)

cvars.AddChangeCallback("deathrun_vhs7", function( name, old, new )
	if IsValid( DR.TVBorder ) then
		DR.TVBorder:Remove()
	end
	if tonumber(new) == 1 then
		DR.TVBorder = vgui.Create("DHTML")
		DR.TVBorder:SetSize( ScrW(), ScrH() )
		DR.TVBorder:SetPos(0,0)
		DR.TVBorder:OpenURL("http://arizard.github.io/overlay.html")
	end
end, "tvborder_callback")

hook.Add("HUDPaintBackground", "Vaporwave", function()


	local M = Matrix()

	M:Translate( Vector(ScrW()/2, ScrH()/2) )
	M:Rotate( Angle(0,5 * math.sin(CurTime()*0.5),0) )
	M:Scale( Vector(1,1,1) * (0.9 + 0.2*math.sin( CurTime()*0.3)) )
	M:Translate( -Vector(ScrW()/2, ScrH()/2) )  

	--cam.PushModelMatrix( M )
end)

hook.Add("PostDrawHUD", "Vaporwave", function()

	--cam.PopModelMatrix()
end)
