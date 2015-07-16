local columns = {"Name", "blank","Title", "Rank", "Ping"}
local columnFunctions = {
	function( ply ) return ply:Nick() end,
	function() return "" end,
	function( ply ) 
		if ply:SteamID() == "STEAM_0:1:30288855" then -- don't remove this or i kill u
			return "Super Player"
		end
		if ply:SteamID() == "STEAM_0:0:29351088" then
			return  "Worst Player Ever"
		end
		return ""
	end,
	function( ply ) 
		return string.upper(ply:GetUserGroup())
	end,
	function( ply ) return ply:Ping() end,
}


if IsValid(DR.ScoreboardPanel) then -- remove the scoreboard on autorefresh
	DR.ScoreboardPanel:Remove()
end

function DR:CreateScoreboard()

	local scoreboard = DR.ScoreboardPanel

	if not IsValid(DR.ScoreboardPanel) then

		local scoreboard = vgui.Create("DPanel")
		scoreboard:SetSize(ScrW()/2, ScrH()-100)
		scoreboard:SetPos( 0, ScrH() + 50 )

		scoreboard:CenterHorizontal()

		scoreboard.dt = 0
		scoreboard.lastthink = CurTime()
		function scoreboard:Think()
			local dt = CurTime() - self.lastthink
			self.lastthink = CurTime()

			local x, y = self:GetPos()
			local lerpspeed = 0.0005
			local dur = 0.2 -- 2 seconds

			self.dt = math.Clamp(self.dt + ( DR.ScoreboardIsOpen and dt or -dt ), 0, dur)

			self:SetPos( x, QuadLerp( math.Clamp( InverseLerp( self.dt,0,dur ), 0, 1), ScrH()+50, 128) )

			if DR.ScoreboardIsOpen == false and y > ScrH() then self:Remove() end
		end

		DR.ScoreboardPanel = scoreboard

	end

	scoreboard = DR.ScoreboardPanel

	--scoreboard:MakePopup()

	function scoreboard:Paint(w,h)

		surface.SetDrawColor( DR.Colors.Clouds )
		--surface.DrawRect(0,0,w,h)
		--DR:DrawPanelBlur( self, 6 )
	end

	local scr = vgui.Create("DScrollPanel", scoreboard)
	scr:SetSize(scoreboard:GetWide(), scoreboard:GetTall())
	scr:SetPos(0,0)

	local vbar = scr:GetVBar()
	vbar:SetWide(0)


	local dlist = vgui.Create("DIconLayout", scr)
	dlist:SetSize(scoreboard:GetWide(), 1500)
	dlist:SetPos(0,0)

	dlist:SetSpaceX(0)
	dlist:SetSpaceY(4)

	local header = vgui.Create("DPanel")
	header:SetSize( dlist:GetWide(), 48 )

	function header:Paint(w,h)
		surface.SetDrawColor( DR.Colors.Turq or HexColor("#303030") )
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(255,255,255, 155*(1-math.pow( ( ( (math.sin(CurTime())+1)/2 ) ), 0.1))  )
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(0,h-3,w,3)

		deathrunShadowTextSimple(GetHostName(), "deathrun_derma_Large", w/2, h/2-2, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
	end

	dlist:Add( header )
	dlist:Add( DR:NewScoreboardSpacer( {"[Hint] Right Click to interact with scoreboard."}, dlist:GetWide(), 32, DR.Colors.Turq ) )

	dlist:Add( DR:NewScoreboardSpacer( {tostring(#team.GetPlayers(TEAM_DEATH)).." players on Death Team"}, dlist:GetWide(), 32, team.GetColor( TEAM_DEATH ) ) )
	for k,ply in ipairs(team.GetPlayers( TEAM_DEATH )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), 28 ) )
	end
	dlist:Add( DR:NewScoreboardSpacer( {tostring(#team.GetPlayers(TEAM_RUNNER)).." players on Runner Team"}, dlist:GetWide(), 32, team.GetColor( TEAM_RUNNER ) ) )
	for k,ply in ipairs(team.GetPlayers( TEAM_RUNNER )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), 28 ) )
	end
	dlist:Add( DR:NewScoreboardSpacer( {tostring(#team.GetPlayers(TEAM_SPECTATOR)).." players Spectating"}, dlist:GetWide(), 32 ) )
	for k,ply in ipairs(team.GetPlayers( TEAM_SPECTATOR )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), 28 ) )

	end

	dlist:SizeToChildren()

	DR.ScoreboardPanel = scoreboard
	DR.ScoreboardIsOpen = true
end

function DR:NewScoreboardSpacer( tbl_cols, w, h, customColor ) -- static columns
	local panel = vgui.Create("DPanel")
	panel:SetSize(w,h)
	panel.tbl_cols = tbl_cols
	panel.customColor = customColor

	function panel:Paint(w,h)
		surface.SetDrawColor( DR.Colors.Clouds or HexColor("#303030") )
		surface.DrawRect(0,0,w,h)

		w = w-8

	end

	local columns = tbl_cols

	for i = 1, #columns do
		local k = i-1
		local align = 0.5

		if i <= 1 then align = 0 end
		if i >= #columns then align = 1 end

		local label = vgui.Create("DLabel", panel)
		label:SetText( columns[i] )
		label:SetTextColor( customColor )
		label:SetFont("deathrun_derma_Small")
		label:SizeToContents()
		label:SetPos( #columns > 1 and 4+(k * ((panel:GetWide()-8)/(#columns-1)) - label:GetWide()*align) or (panel:GetWide()-8)/2 - label:GetWide()/2, panel:GetTall()/2 - label:GetTall()/2 - 1 )

		--draw.SimpleText( , "deathrun_derma_Small", k * (w/(#columns-1)),h/2, , align , TEXT_ALIGN_CENTER )
	end

	return panel
end

local muteicon = Material("icon16/sound_mute.png")

function DR:NewScoreboardPlayer( ply, w, h )

	local t = ply:Team()
	local tcol = team.GetColor( t )

	local panel = vgui.Create("DPanel")
	panel:SetSize(w,h)
	panel.bgcol = tcol
	panel.ply = ply

	function panel:Paint(w,h)
		surface.SetDrawColor(self.bgcol)
		surface.DrawRect(0,0,w,h)

		if IsValid( self.ply ) then
			if not self.ply:Alive() then
				surface.SetDrawColor(Color(255,255,255,70))
				surface.DrawRect(0,0,w,h)
			end
		end

	end

	local av = vgui.Create("AvatarImage", panel)
	av:SetSize(h,h)
	av:SetPos(0,0)
	av:SetPlayer( ply )
	av.ply = ply

	function av:PaintOver(w,h)
		if IsValid( self.ply ) then
			if not self.ply:Alive() then
				surface.SetDrawColor(Color(255,255,255,100))
				surface.DrawRect(0,0,w,h)

				draw.SimpleText("✖", "deathrun_derma_Medium", 2,-1,DR.Colors.Alizarin )
			end
		end
		if self.ply:IsValid() then
			if table.HasValue( LocalPlayer().mutelist or {}, self.ply:SteamID() ) then
				surface.SetMaterial( muteicon )
				surface.SetDrawColor(Color(255,255,255,100))
				surface.DrawRect(0,0,w,h)
				surface.SetDrawColor(Color(255,255,255,255))
				surface.DrawTexturedRect(h/2-8,w/2-8,16,16)
			end
		end
	end

	local data = vgui.Create("DPanel", panel)
	data:SetSize(w-(h*2)-8, h)
	data:SetPos((h*2)+8,0)
	data.bgcol = tcol
	data.ply = ply

	-- get scoreboard icon
	local icon = vgui.Create("DPanel", panel)
	icon:SetSize(h,h)
	icon:SetPos(h,0)

	local path = hook.Call("GetScoreboardIcon", nil, ply)

	icon.Mat = path and Material( path ) or false

	function icon:Paint(w,h)
		if self.Mat ~= false then
			surface.SetDrawColor(255,255,255)
			surface.SetMaterial( self.Mat )
			surface.DrawTexturedRect( 0 + w/2 - 8, 0 + h/2 - 8, 16, 16 )
		end
	end


	function data:Paint(w,h)

	end

	local plyscorecol = hook.Call("GetScoreboardNameColor", nil, ply) or Color(255,255,255)

	for i = 1, #columns do
		local k = i-1
		local align = 0.5

		if i <= 1 then align = 0 end
		if i >= #columns then align = 1 end

		local label = vgui.Create("DLabel", data)
		label:SetText( columnFunctions[i]( ply ) )
		label:SetTextColor( plyscorecol )
		label:SetFont("deathrun_derma_Small")
		label:SetExpensiveShadow( 1 )
		label:SizeToContents()
		label:SetPos( k * ((data:GetWide()-8)/(#columns-1)) - label:GetWide()*align, data:GetTall()/2 - label:GetTall()/2  )

		--draw.SimpleText( , "deathrun_derma_Small", k * (w/(#columns-1)),h/2, , align , TEXT_ALIGN_CENTER )
	end


	local but = vgui.Create("DButton", panel)
	but:SetSize(w, h)
	but:SetText("")

	--options for clicking on a player: Copy steamid, Open profile, mute player

	function but:DoClick()
		local menu = vgui.Create("DMenu")
		menu.ply = self:GetParent().ply
		
		local copyID = menu:AddOption( "Copy SteamID to clipboard" )
		copyID.ply = menu.ply
		copyID:SetIcon("icon16/page_copy.png")
		function copyID:DoClick()
			SetClipboardText( self.ply:SteamID() )
			DR:ChatMessage( self.ply:Nick().."'s SteamID was copied to the clipboard!" )
		end

		--http://steamcommunity.com/profiles/

		local openprofile = menu:AddOption( "Open Steam profile" )
		openprofile.ply = menu.ply
		openprofile:SetIcon("icon16/page_world.png")
		function openprofile:DoClick()
			gui.OpenURL( "http://steamcommunity.com/profiles/"..self.ply:SteamID64() )
		end

		local mute = menu:AddOption( "Toggle voice" )
		mute.ply = menu.ply
		mute:SetIcon("icon16/sound.png")
		function mute:DoClick()
			RunConsoleCommand("deathrun_toggle_mute",self.ply:SteamID())
			DR:ChatMessage( "Toggled mute on "..self.ply:Nick().."!" )
		end
		
		menu:AddSpacer()

		-- ulx support
		if ulx then

			local option = menu:AddOption( "Gag player voice" ) -- gag
			option.ply = menu.ply
			option:SetIcon("icon16/sound.png")
			function option:DoClick()
				LocalPlayer():ConCommand( "ulx gag "..[["]]..self.ply:Nick()..[["]] )
			end
			local option = menu:AddOption( "Ungag player voice" ) -- ugag
			option.ply = menu.ply
			option:SetIcon("icon16/sound.png")
			function option:DoClick()
				LocalPlayer():ConCommand( "ulx ungag "..[["]]..self.ply:Nick()..[["]] )
			end
			local option = menu:AddOption( "Mute player chat" ) -- gag
			option.ply = menu.ply
			option:SetIcon("icon16/style_delete.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx mute "..[["]]..self.ply:Nick()..[["]] )
			end
			local option = menu:AddOption( "Unmute player chat" ) -- gag
			option.ply = menu.ply
			option:SetIcon("icon16/style_delete.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx unmute "..[["]]..self.ply:Nick()..[["]] )
			end
			local option = menu:AddOption( "Slay player" ) -- gag
			option.ply = menu.ply
			option:SetIcon("icon16/newspaper.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx slay "..[["]]..self.ply:Nick()..[["]] )
			end
			local option = menu:AddOption( "Kick from server" ) -- kick
			option.ply = menu.ply
			option:SetIcon("icon16/sport_football.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx kick "..[["]]..self.ply:Nick()..[["]]..' Kicked by server staff.' )
			end
			local option = menu:AddOption( "Ban for 30 minutes" ) -- 30m ban
			option.ply = menu.ply
			option:SetIcon("icon16/clock.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx banid 30 "..self.ply:SteamID()..' Banned by server staff for half an hour.' )
			end
			local option = menu:AddOption( "Ban for 2 hours" ) -- 2hr ban
			option.ply = menu.ply
			option:SetIcon("icon16/clock.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx banid 120 "..self.ply:SteamID()..' Banned by server staff for 2 hours.' )
			end
			local option = menu:AddOption( "Ban for 24 hours" ) -- 1d ban
			option.ply = menu.ply
			option:SetIcon("icon16/clock.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx banid 1440 "..self.ply:SteamID()..' Banned by server staff for 1 day.' )
			end
			local option = menu:AddOption( "Ban for 1 week" ) -- 7d ban
			option.ply = menu.ply
			option:SetIcon("icon16/clock.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx banid 10080 "..self.ply:SteamID()..' Banned by server staff for 1 week.' )
			end
			local option = menu:AddOption( "Ban permanently" ) -- 7d ban
			option.ply = menu.ply
			option:SetIcon("icon16/clock_red.png")
			function option:DoClick()
				LocalPlayer():ConCommand("ulx banid 0 "..self.ply:SteamID()..' Banned by server staff forever.' )
			end

		end

		menu:Open()
	end

	function but:Paint() end

	return panel

end

function DR:DestroyScoreboard()
	if IsValid( DR.ScoreboardPanel ) then
		
		
	end
	DR.ScoreboardIsOpen = false
	
end

DR:DestroyScoreboard()

function GM:ScoreboardHide()
	DR:DestroyScoreboard()
	DR.ScoreboardCloseTime = CurTime()
end

function GM:ScoreboardShow()
	DR:CreateScoreboard()
	DR.ScoreboardOpenTime = CurTime()
end

hook.Add("CreateMove", "DeathrunScoreboardPopup", function( cmd )

	if input.WasMousePressed( MOUSE_RIGHT ) then
		if DR.ScoreboardIsOpen == true then
			DR.ScoreboardPanel:MakePopup()
		end
	end

end)

hook.Add("GetScoreboardNameColor","memes", function( ply ) -- do not remove or i kill u
	if ply:SteamID() == "STEAM_0:1:30288855" then
		return Color(0,200,0)
	end
end)

hook.Add("GetScoreboardIcon","memes 2: electric dootaloo", function( ply )
	if ply:SteamID() == "STEAM_0:1:30288855" then
		return "icon16/bug.png"
	elseif ply:SteamID() == "STEAM_0:0:29351088" then
		return "icon16/box.png"
	end
end)