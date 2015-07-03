local columns = {"Name", "Title", "Rank", "Ping"}
local columnFunctions = {
	function( ply ) return ply:Nick() end,
	function( ply ) 
		return ply:SteamID() == "STEAM_0:0:29351088" and "Worst GR Member 2k15" or "" 
	end,
	function( ply ) 
		return string.upper(ply:GetUserGroup())
	end,
	function( ply ) return ply:Ping() end,
}
local columnColorFunctions = {
	function( ply ) return Color(255,255,255) end,
	function( ply ) return Color(255,255,255) end,
	function( ply ) return Color(255,255,255) end,
	function( ply ) return Color(255,255,255) end,
}


function DR:CreateScoreboard()
	local scoreboard = vgui.Create("DPanel")
	scoreboard:SetSize(ScrW()/2, ScrH()-100)
	scoreboard:Center()

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
	header:SetSize( dlist:GetWide(), 44 )

	function header:Paint(w,h)
		surface.SetDrawColor( DR.Colors.Turq or HexColor("#303030") )
		surface.DrawRect(0,0,w,h)

		draw.SimpleText(GetHostName(), "deathrun_derma_Large", w/2, h/2, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
	data:SetSize(w-h-8, h)
	data:SetPos(h+8,0)
	data.bgcol = tcol
	data.ply = ply

	function data:Paint(w,h)

	end

	for i = 1, #columns do
		local k = i-1
		local align = 0.5

		if i <= 1 then align = 0 end
		if i >= #columns then align = 1 end

		local label = vgui.Create("DLabel", data)
		label:SetText( columnFunctions[i]( ply ) )
		label:SetTextColor( columnColorFunctions[i]( ply ) )
		label:SetFont("deathrun_derma_Small")
		label:SizeToContents()
		label:SetPos( k * ((data:GetWide()-8)/(#columns-1)) - label:GetWide()*align, data:GetTall()/2 - label:GetTall()/2 - 1 )

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

		local mute = menu:AddOption( "Toggle Voice" )
		mute.ply = menu.ply
		mute:SetIcon("icon16/sound.png")
		function mute:DoClick()
			RunConsoleCommand("deathrun_toggle_mute",self.ply:SteamID())
			DR:ChatMessage( "Toggled mute on "..mute.ply:Nick().."!" )
		end

		menu:Open()
	end

	function but:Paint() end

	return panel

end

function DR:DestroyScoreboard()
	if IsValid( DR.ScoreboardPanel ) then
		DR.ScoreboardPanel:Remove()
		DR.ScoreboardIsOpen = false
	end
end

DR:DestroyScoreboard()

function GM:ScoreboardHide()
	DR:DestroyScoreboard()
end

function GM:ScoreboardShow()
	DR:CreateScoreboard()
end

hook.Add("CreateMove", "DeathrunScoreboardPopup", function( cmd )

	if input.WasMousePressed( MOUSE_RIGHT ) then
		if DR.ScoreboardIsOpen == true then
			DR.ScoreboardPanel:MakePopup()
		end
	end

end)