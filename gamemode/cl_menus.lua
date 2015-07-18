print("Loaded cl_menus.lua...")

local crosshair_convars = {
	{"deathrun_crosshair_thickness",0,16, "Stroke Thickness"},
	{"deathrun_crosshair_gap",0,32, "Inner Gap"},
	{"deathrun_crosshair_size",0,32, "Stroke Length"},
	{"deathrun_crosshair_red",0,255, "Red"},
	{"deathrun_crosshair_green",0,255, "Green"},
	{"deathrun_crosshair_blue",0,255, "Blue"},
	{"deathrun_crosshair_alpha",0,255, "Transparency"},
}

function DR:OpenCrosshairCreator()
	local frame = vgui.Create("deathrun_window")
	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Crosshair Creator")

	local panel = vgui.Create("DPanel", frame)
	panel:SetSize( frame:GetWide()-8, frame:GetTall()-44 )
	panel:SetPos(4,32)
	function panel:Paint() end

	local drawx = vgui.Create("DPanel", panel)
	drawx:SetSize( panel:GetWide()/2 - 2, panel:GetTall() )
	drawx:SetPos(0,0)

	function drawx:Paint(w,h)

		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(0,0,w,h)

		local XHairThickness = GetConVar("deathrun_crosshair_thickness")
		local XHairGap = GetConVar("deathrun_crosshair_gap")
		local XHairSize = GetConVar("deathrun_crosshair_size")
		local XHairRed = GetConVar("deathrun_crosshair_red")
		local XHairGreen = GetConVar("deathrun_crosshair_green")
		local XHairBlue = GetConVar("deathrun_crosshair_blue")
		local XHairAlpha = GetConVar("deathrun_crosshair_alpha")

		local thick = XHairThickness:GetInt()
		local gap = XHairGap:GetInt()
		local size = XHairSize:GetInt()

		surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), XHairAlpha:GetInt())
		surface.DrawRect(w/2 - (thick/2), h/2 - (size + gap/2), thick, size )
		surface.DrawRect(w/2 - (thick/2), h/2 + (gap/2), thick, size )
		surface.DrawRect(w/2 + (gap/2), h/2 - (thick/2), size, thick )
		surface.DrawRect(w/2 - (size + gap/2), h/2 - (thick/2), size, thick )
	end

	local controls = vgui.Create("DPanel", panel)
	controls:SetSize( panel:GetWide()/2 - 2, panel:GetTall() )
	controls:SetPos( panel:GetWide() - controls:GetWide(), 0 )

	function controls:Paint(w,h)
		surface.SetDrawColor( DR.Colors.Clouds )
		surface.DrawRect(0,0,w,h)
	end

	local scr = vgui.Create("DScrollPanel", controls)
	scr:SetSize( controls:GetWide()-16, controls:GetTall()-16 )
	scr:SetPos(8,8)

	local vbar = scr:GetVBar()
	vbar:SetWide(4)

	function vbar:Paint(w,h)
		surface.SetDrawColor(0,0,0,100) 
		surface.DrawRect(0,0,w,h)
	end
	function vbar.btnUp:Paint() end
	function vbar.btnDown:Paint() end
	function vbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(0,0,w,h)
	end

	local dlist = vgui.Create("DIconLayout", scr)
	dlist:SetSize( scr:GetSize() )
	dlist:SetPos(0,0)
	dlist:SetSpaceX(0)
	dlist:SetSpaceY(4)

	local lbl = vgui.Create("DLabel")
	lbl:SetFont("deathrun_derma_Small")
	lbl:SetTextColor(DR.Colors.Turq)
	lbl:SetText("Crosshair Options")
	lbl:SizeToContents()
	lbl:SetWide( dlist:GetWide() )
	dlist:Add(lbl)

	for i = 1, #crosshair_convars do
		local cv = crosshair_convars[i]
		local lbl = vgui.Create("DLabel")
		lbl:SetFont("deathrun_derma_Tiny")
		lbl:SetTextColor( HexColor("#333") )
		lbl:SetText(cv[4] or cv[1])
		lbl:SizeToContents()
		lbl:SetWide( dlist:GetWide() )
		dlist:Add(lbl)

		-- slider
		local sl = vgui.Create("Slider")
		sl:SetMin( cv[2] )
		sl:SetMax( cv[3] )
		sl:SetWide(dlist:GetWide())
		sl:SetValue( GetConVar( cv[1] ):GetFloat() )

		sl.convarname = cv[1]

		function sl:OnValueChanged()
			RunConsoleCommand(self.convarname, self:GetValue())
		end

		dlist:Add(sl)
	end

end

concommand.Add("deathrun_open_crosshair_creator", function()
	DR:OpenCrosshairCreator()
end)

function DR:OpenHelp()

	local frame = vgui.Create("deathrun_window")
	frame:SetSize(ScrW(), ScrH())
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Deathrun Help")

	local lbl = vgui.Create("DLabel", frame)
	lbl:SetText("Please wait while page loads...")
	lbl:SetFont("deathrun_derma_Large")
	lbl:SizeToContents()
	lbl:Center()

	local html = vgui.Create("DHTML", frame)
	html:SetSize( frame:GetWide()-8, frame:GetTall() - 44 )
	html:SetPos(4, 32)
	html:OpenURL( GetConVar("deathrun_help_url"):GetString() )

end

concommand.Add("deathrun_open_help", function()
	DR:OpenHelp()
end)

local deathrun_settings = {}

timer.Create("UpdateDeathrunSettingsConvars", 1,0,function()
	deathrun_settings = {
		["boolean"] = {
			{"deathrun_autojump","Autojump (Enabling this limits velocity to "..tostring(GetConVarNumber("deathrun_autojump_velocity_cap")).." u/s)"},
			{"deathrun_enable_announcements", "Help messages"},
			{"deathrun_thirdperson_enabled", "Thirdperson mode"},
			{"deathrun_round_cues", "Audible round cues at starts and ends of rounds"},
			{"deathrun_info_on_join", "Show the info menu when joining the server"},
			{"deathrun_spectate_only", "Spectate-only mode"}
		},
		["number"] = {
			{"deathrun_hud_theme",0,2,"HUD Theme"},
			{"deathrun_hud_position",0,8,"Position of the HUD (HP, Velocity, Time)"},
			{"deathrun_hud_ammo_position",0,8,"Position of the Ammo HUD"},
			{"deathrun_hud_alpha",0,255,"Transparency of the HUD background"},
			{"deathrun_targetid_fade_duration",0,10,"Seconds for names to fade from the screen after looking away from a player"},
			{"deathrun_announcement_interval", 0, 500, "Seconds between help messages."},
			{"deathrun_thirdperson_offset_x", -40, 40, "Thirdperson camera horizontal offset"},
			{"deathrun_thirdperson_offset_y", -40, 40, "Thirdperson camera vertical offset"},
			{"deathrun_thirdperson_offset_z", -75, 75, "Thirdperson camera forward-backward offset"},
			{"deathrun_teammate_fade_distance", 0, 512, "Teammate fade distance - teammates closer than this distance will become transparent."}
		},
		["string"] = {
			{"deathrun_sample_string_convar","Sample String ConVar"}
		}
	}
end)


function DR:OpenSettings()
	local frame = vgui.Create("deathrun_window")
	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Deathrun Settings")

	local controls = vgui.Create("DPanel", frame)
	controls:SetSize( frame:GetWide()-8, frame:GetTall()-44 )
	controls:SetPos( 4, 32 )

	function controls:Paint(w,h)
		surface.SetDrawColor( DR.Colors.Clouds )
		surface.DrawRect(0,0,w,h)
	end

	local scr = vgui.Create("DScrollPanel", controls)
	scr:SetSize( controls:GetWide()-16, controls:GetTall()-16 )
	scr:SetPos(8,8)

	local vbar = scr:GetVBar()
	vbar:SetWide(4)

	function vbar:Paint(w,h)
		surface.SetDrawColor(0,0,0,100) 
		surface.DrawRect(0,0,w,h)
	end
	function vbar.btnUp:Paint() end
	function vbar.btnDown:Paint() end
	function vbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(0,0,w,h)
	end

	local dlist = vgui.Create("DIconLayout", scr)
	dlist:SetSize( scr:GetSize() )
	dlist:SetPos(0,0)
	dlist:SetSpaceX(0)
	dlist:SetSpaceY(8)

	local lbl = vgui.Create("DLabel")
	lbl:SetFont("deathrun_derma_Small")
	lbl:SetTextColor(DR.Colors.Turq)
	lbl:SetText("Settings")
	lbl:SizeToContents()
	lbl:SetWide( dlist:GetWide() )
	dlist:Add(lbl)

	for k, v in pairs( deathrun_settings ) do
		if k == "boolean" then
			for _,cv in ipairs(v) do
				local lbl = vgui.Create("DLabel") -- label
				lbl:SetFont("deathrun_derma_Tiny")
				lbl:SetTextColor( HexColor("#333") )
				lbl:SetText(cv[2])
				lbl:SizeToContents()
				lbl:SetWide( dlist:GetWide() )
				dlist:Add(lbl)

				local check = vgui.Create("DCheckBoxLabel")
				check:SetValue( GetConVar(cv[1]):GetInt() )
				check:SetText("Enabled")
				check:SetTextColor( HexColor("#333") )
				check:SizeToContents()
				check:SetConVar(cv[1])
				dlist:Add( check )
			end
		end
		if k == "number" then
			for _,cv in ipairs(v) do
				local lbl = vgui.Create("DLabel") -- label
				lbl:SetFont("deathrun_derma_Tiny")
				lbl:SetTextColor( HexColor("#333") )
				lbl:SetText(cv[4])
				lbl:SizeToContents()
				lbl:SetWide( dlist:GetWide() )
				dlist:Add(lbl)

				-- slider
				local sl = vgui.Create("Slider")
				sl:SetMin( cv[2] )
				sl:SetMax( cv[3] )
				sl:SetWide(dlist:GetWide())
				sl:SetValue( GetConVar( cv[1] ):GetFloat() )

				sl.convarname = cv[1]

				function sl:OnValueChanged()
					RunConsoleCommand(self.convarname, self:GetValue())
				end

				dlist:Add(sl)
			end
		end
	end
end
concommand.Add("deathrun_open_settings", function()
	DR:OpenSettings()
end)

function DR:OpenZoneEditor()
	local frame = vgui.Create("deathrun_window")
	frame:SetSize(320,480)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Zone Editor")

	local panel = vgui.Create("DPanel", frame)
	panel:SetSize( frame:GetWide()-8, frame:GetTall()-44 )
	panel:SetPos(4,32)
	function panel:Paint(w,h)
		surface.SetDrawColor(DR.Colors.Clouds)
		surface.DrawRect(0,0,w,h)
	end

	local scr = vgui.Create("DScrollPanel", panel)
	scr:SetSize( panel:GetWide()-12, panel:GetTall()-16 )
	scr:SetPos(8,8)

	local vbar = scr:GetVBar()
	vbar:SetWide(4)

	function vbar:Paint(w,h)
		surface.SetDrawColor(0,0,0,100) 
		surface.DrawRect(0,0,w,h)
	end
	function vbar.btnUp:Paint() end
	function vbar.btnDown:Paint() end
	function vbar.btnGrip:Paint(w, h)
		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(0,0,w,h)
	end

	local dlist = vgui.Create("DIconLayout", scr)
	dlist:SetSize( scr:GetWide()-6, scr:GetTall() )
	dlist:SetPos(0,0)
	dlist:SetSpaceX(4)
	dlist:SetSpaceY(8)

	local lbl = vgui.Create("DLabel")
	lbl:SetFont("deathrun_derma_Small")
	lbl:SetTextColor(DR.Colors.Turq)
	lbl:SetText("Create Zone")
	lbl:SizeToContents()
	lbl:SetWide( dlist:GetWide() )
	dlist:Add(lbl)

	local lbl = vgui.Create("DLabel")
	lbl:SetFont("deathrun_derma_Tiny")
	lbl:SetTextColor( HexColor("#333") )
	lbl:SetText("Zone Name:")
	lbl:SizeToContents()
	lbl:SetWide( dlist:GetWide()/2 -2 )
	dlist:Add(lbl)

	local te = vgui.Create("DTextEntry")
	te:SetSize( dlist:GetWide()/2 -2, 18 )
	te:SetText("new_zone")
	dlist:Add(te)

	local lbl = vgui.Create("DLabel")
	lbl:SetFont("deathrun_derma_Tiny")
	lbl:SetTextColor( HexColor("#333") )
	lbl:SetText("Zone Type:")
	lbl:SizeToContents()
	lbl:SetWide( dlist:GetWide()/2 -2 )
	dlist:Add(lbl)

	local dd = vgui.Create("DComboBox")
	dd:SetSize( dlist:GetWide()/2 -2, 18 )
	dd:SetValue("end")
	dd:AddChoice("start")
	dd:AddChoice("end")
	dd:AddChoice("custom")
	dlist:Add(dd)

	local sbmt =  vgui.Create("deathrun_button")
	sbmt:SetSize(dlist:GetWide(), 18)
	sbmt:SetText("Create Zone")
	sbmt:SetFont("deathrun_derma_Tiny")
	sbmt:SetOffsets(0,-7)
	dlist:Add(sbmt)

	sbmt.te = te
	te.sbmt = sbmt
	sbmt.dd = dd

	function te:OnTextChanged()
		self.sbmt:SetText("Create Zone '"..self:GetText().."'")
	end

	function sbmt:DoClick()
		LocalPlayer():ConCommand("zone_create "..self.te:GetText().." "..self.dd:GetValue().." " )
		print("zone_create", self.te:GetText().." "..self.dd:GetValue())
	end

	--edit zones
	local lbl = vgui.Create("DLabel")
	lbl:SetFont("deathrun_derma_Small")
	lbl:SetTextColor(DR.Colors.Turq)
	lbl:SetText("Modify Zone")
	lbl:SizeToContents()
	lbl:SetWide( dlist:GetWide() )
	dlist:Add(lbl)

	local dd = vgui.Create("DComboBox")
	dd:SetSize( dlist:GetWide(), 18 )
	dd:SetValue(LocalPlayer().LastSelectZone or "Select Zone")
	for name,z in pairs(ZONE.zones) do
		if z.type then
			dd:AddChoice( name )
		end
	end
	function dd:OnSelect( index, value )
		LocalPlayer().LastSelectZone = value
	end
	dlist:Add(dd)

	local pnl = vgui.Create("DPanel")
	pnl:SetSize( dlist:GetWide(), 85 )
	dlist:Add( pnl )
	pnl.dd = dd
	function pnl:Paint( w, h )
		local zone = ZONE.zones[ self.dd:GetValue() ] or nil
		if zone then
			local col = zone.color
			local info = {
				"Zone Name: "..self.dd:GetValue(),
				"Zone Type: "..zone.type,
				"Pos1: "..tostring(zone.pos1),
				"Pos2: "..tostring(zone.pos2),
				"Color:".." "..tostring(col.r).." "..tostring(col.g).." "..tostring(col.b).." "..tostring(col.a),
			}

			for i = 1, #info do
				local k = i-1
				draw.SimpleText(info[i], "deathrun_derma_Tiny", 0, 14*k, HexColor("#303030"))
			end
		end
	end

	-- ripped from wiki lmao
	local Mixer = vgui.Create( "DColorMixer" )
	Mixer:SetSize( dlist:GetWide(), 196 )
	Mixer:SetPalette( true ) 		--Show/hide the palette			DEF:true
	Mixer:SetAlphaBar( true ) 		--Show/hide the alpha bar		DEF:true
	Mixer:SetWangs( true )			--Show/hide the R G B A indicators 	DEF:true
	Mixer:SetColor( Color( 255, 255, 255 ) )	--Set the default color
	Mixer.dd = dd

	dlist:Add(Mixer)

	local but =  vgui.Create("deathrun_button")
	but:SetSize(dlist:GetWide(), 18)
	but:SetText("Set zone color")
	but:SetFont("deathrun_derma_Tiny")
	but:SetOffsets(0,-7)
	but.dd = dd
	but.mixer = Mixer
	dlist:Add(but)
	function but:DoClick()
		local col = self.mixer:GetColor()
		LocalPlayer():ConCommand("zone_setcolor "..self.dd:GetValue().." "..tostring(col.r).." "..tostring(col.g).." "..tostring(col.b).." "..tostring(col.a))
	end

	local but =  vgui.Create("deathrun_button")
	but:SetSize(dlist:GetWide(), 18)
	but:SetText("Set Pos1 to eyetrace")
	but:SetFont("deathrun_derma_Tiny")
	but:SetOffsets(0,-7)
	but.dd = dd
	dlist:Add(but)
	function but:DoClick()
		LocalPlayer():ConCommand("zone_setpos1 "..self.dd:GetValue().." eyetrace")
	end

	local but =  vgui.Create("deathrun_button")
	but:SetSize(dlist:GetWide(), 18)
	but:SetText("Set Pos2 to eyetrace")
	but:SetFont("deathrun_derma_Tiny")
	but:SetOffsets(0,-7)
	but.dd = dd
	dlist:Add(but)
	function but:DoClick()
		LocalPlayer():ConCommand("zone_setpos2 "..self.dd:GetValue().." eyetrace")
	end

	local but =  vgui.Create("deathrun_button")
	but:SetSize(dlist:GetWide(), 18)
	but:SetText("Remove this zone")
	but:SetFont("deathrun_derma_Tiny")
	but:SetOffsets(0,-7)
	but.dd = dd
	dlist:Add(but)
	function but:DoClick()
		LocalPlayer():ConCommand("zone_remove "..self.dd:GetValue())
	end


end
concommand.Add("deathrun_open_zone_editor", function()
	DR:OpenZoneEditor()
end)

function DR:OpenQuickInfo()

	local frame = vgui.Create("deathrun_window")
	frame:SetSize(640, 480)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Deathrun Information")

	function frame:OnClose()
		if ROUND:GetCurrent() == ROUND_WAITING then
			DR:OpenWaitingMenu()
		end
	end

	local lbl = vgui.Create("DLabel", frame)
	lbl:SetText("Please wait while page loads...")
	lbl:SetFont("deathrun_derma_Large")
	lbl:SizeToContents()
	lbl:Center()

	local html = vgui.Create("DHTML", frame)
	html:SetSize( frame:GetWide()-8, frame:GetTall() - 44 )
	html:SetPos(4, 32)
	html:OpenURL( "http://arizard.github.io/deathruninfo.html" )
	html:SetAllowLua( true )

	DR.QuickInfoFrame = frame

end

function OpenSteamGroup()
	if IsValid( DR.QuickInfoFrame ) then
		DR.QuickInfoFrame:Close()
		gui.OpenURL("http://steamcommunity.com/groups/vhs7")
	end
end

concommand.Add("deathrun_open_quickinfo", function()
	DR:OpenQuickInfo()
end)

infoOpened = infoOpened ~= nil and infoOpened or false -- needs to be global
local ShowInfo = CreateClientConVar("deathrun_info_on_join", 1, true, false) -- whether we see info on join

hook.Add("HUDPaint", "openquickinfo", function()
	if infoOpened == false and ShowInfo:GetBool() == true then
		DR:OpenQuickInfo()
	end
	infoOpened = true -- only check once, then leave it
end)

function DR:GetWordWrapText( text, w, font )
	local displaytext = ""
	local displayline = ""
	local displayfont = font
	surface.SetFont( displayfont )
	
	text = string.Replace( text, "\n", "")
	text = string.Replace( text, "\t", "")

	text = string.Replace( text, [[\n]], "\n")
	text = string.Replace( text, [[\t]], "\t")
	text = string.Replace( text, [[\b]], "• ")

	local args = string.Split( text, " " )

	for i = 1, #args do
		local word = args[i]
		local tw, th = surface.GetTextSize( displayline..word.." " )
		if tw > w then
			displaytext = displaytext..displayline.."\n"
			displayline = word.." "
		else
			displayline = displayline..word.." "
		end
		if i == #args then
			displaytext = displaytext..displayline
		end
	end

	return displaytext
end


-- waiting menu
function DR:OpenWaitingMenu()

	local frame = vgui.Create("deathrun_window")
	frame:SetSize(600,270)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Waiting For Players")

	local panel = vgui.Create("panel", frame)
	panel:SetSize(frame:GetWide()-8, frame:GetTall()-44)
	panel:SetPos(4,32)

	function panel:Paint(w,h)
		local x,y = 0, 0

		surface.SetDrawColor(DR.Colors.Clouds)
		surface.DrawRect(x,y,w,h)

		local ix, iy, iw, ih = x+8, y+8, w-16, h-16

		local info = [[Welcome to the server! Currently there are no players online. 
		This means that you can explore the map at your own pace 
		from the safety of godmode, so you can practice 
		your Bhop and check for auto-traps with ease.\n\n
		Some useful commands:\n
		\t\b !respawn - Respawn yourself.\n
		\t\b !cleanup - Reset all traps on the map.\n
		\t\b !help - View the help menu.\n\n
		Enjoy, and have fun!]]

		info = DR:GetWordWrapText( info, iw, "deathrun_hud_Medium_light" )
		deathrunShadowText(info, "deathrun_hud_Medium_light", ix, iy, HexColor("#303030"), nil, nil, 0 )
	end
end

concommand.Add("deathrun_open_waitingmenu", function()
	DR:OpenWaitingMenu()
end)
