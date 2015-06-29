local columns = {"Name", "Title", "Rank", "Ping"}
local columnFunctions = {
	function( ply ) return ply:Nick() end,
	function( ply ) return "custom_title" end,
	function( ply ) return ply:GetUserGroup() end,
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

	end

	local dlist = vgui.Create("DIconLayout", scoreboard)
	dlist:SetSize(scoreboard:GetWide(), scoreboard:GetTall())
	dlist:SetPos(0,0)

	dlist:SetSpaceX(0)
	dlist:SetSpaceY(4)

	local header = vgui.Create("DPanel")
	header:SetSize( dlist:GetWide(), 44 )

	function header:Paint(w,h)
		surface.SetDrawColor( HexColor("#303030") )
		surface.DrawRect(0,0,w,h)

		draw.SimpleText(GetHostName(), "deathrun_derma_Large", w/2, h/2, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	dlist:Add( header )

	for k,ply in ipairs(team.GetPlayers( TEAM_DEATH )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), 28 ) )
	end
	for k,ply in ipairs(team.GetPlayers( TEAM_RUNNER )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), 28 ) )
	end
	for k,ply in ipairs(team.GetPlayers( TEAM_SPECTATOR )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), 28 ) )
	end

	dlist:Add( DR:NewScoreboardSpacer( {"memes"}, dlist:GetWide(), 32 ) )

	DR.ScoreboardPanel = scoreboard
	DR.ScoreboardIsOpen = true
end

function DR:NewScoreboardSpacer( tbl_cols, w, h, customColor ) -- static columns
	local panel = vgui.Create("DPanel")
	panel:SetSize(w,h)

	function panel:Paint(w,h)
		surface.SetDrawColor( HexColor("#303030") or customColor )
		surface.DrawRect(0,0,w,h)
	end

	return panel
end

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

		if not self.ply:Alive() then
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawRect(0,0,w,h)
		end
	end

	local av = vgui.Create("AvatarImage", panel)
	av:SetSize(h,h)
	av:SetPos(0,0)
	av:SetPlayer( ply )
	av.ply = ply

	function av:PaintOver(w,h)
		if not self.ply:Alive() then
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawRect(0,0,w,h)
		end
	end

	local data = vgui.Create("DPanel", panel)
	data:SetSize(w-h-8, h)
	data:SetPos(h+8,0)
	data.bgcol = tcol
	data.ply = ply

	function data:Paint(w,h)

		w = w - 8

		for i = 1, #columns do
			local k = i-1
			local align = TEXT_ALIGN_CENTER

			if i <= 1 then align = TEXT_ALIGN_LEFT end
			if i >= #columns then align = TEXT_ALIGN_RIGHT end
			draw.SimpleText( columnFunctions[i]( self.ply ), "deathrun_derma_Small", k * (w/(#columns-1)),h/2, columnColorFunctions[i]( self.ply ), align , TEXT_ALIGN_CENTER )
		end
	end

	local but = vgui.Create("DButton", panel)
	but:SetSize(w, h)
	but:SetText("")

	--options for clicking on a player: Copy steamid, Open profile

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