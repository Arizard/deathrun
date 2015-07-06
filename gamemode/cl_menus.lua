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
			{"deathrun_autojump","Autojump (Enabling this limits velocity to "..tostring(GetConVar("deathrun_autojump_velocity_cap"):GetFloat()).." u/s)"},
			{"deathrun_enable_announcements", "Help messages"},
			{"deathrun_thirdperson_enabled", "Thirdperson mode"}
		},
		["number"] = {
			{"deathrun_hud_position",0,8,"Position of the HUD (HP, Velocity, Time)"},
			{"deathrun_targetid_fade_duration",0,10,"Seconds for names to fade from the screen after looking away from a player"},
			{"deathrun_announcement_interval", 0, 500, "Seconds between help messages."},
			{"deathrun_thirdperson_offset_x", -40, 40, "Thirdperson camera horizontal offset"},
			{"deathrun_thirdperson_offset_y", -40, 40, "Thirdperson camera vertical offset"},
			{"deathrun_thirdperson_offset_z", -75, 75, "Thirdperson camera forward-backward offset"},
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

