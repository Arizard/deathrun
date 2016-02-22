include("sh_mapvote.lua")

MV.Nominations = {}
net.Receive("MapvoteSyncNominations", function()
	MV.Nominations = table.Copy( net.ReadTable() )
	MV:RepopulateMapList()
end)

function MV:IsMapNominated( mapname )
	if table.HasValue(MV.Nominations, mapname) then
		return true
	else
		return false
	end
end

function MV:NewDermaRow( tbl_cols, w, h, customColor, customColor2, doclick )

	if doclick == nil then
		doclick = function() end
	end

	local panel = vgui.Create("DPanel")
	panel:SetSize(w,h)
	panel.tbl_cols = tbl_cols
	panel.customColor = customColor

	function panel:Paint(w,h)

		surface.SetDrawColor( customColor or DR.Colors.Turq )
		surface.DrawRect(0,0,w,h)

		--surface.SetDrawColor( customColor ~= nil and HexColor("#303030",80) or Color(0,0,0,0) )
		surface.DrawRect(0,0,w,h)

	end

	local columns = tbl_cols

	for i = 1, #columns do
		local k = i-1
		local align = 0.5

		if i <= 1 then align = 0 end
		if i >= #columns then align = 1 end

		local label = vgui.Create("DLabel", panel)
		label:SetText( columns[i] )
		label:SetTextColor( customColor2 or DR.Colors.Clouds )
		label:SetFont("deathrun_derma_Tiny")
		label:SizeToContents()
		label:SetPos( #columns > 1 and 4+(k * ((panel:GetWide()-8)/(#columns-1)) - label:GetWide()*align) or (panel:GetWide()-8)/2 - label:GetWide()/2, panel:GetTall()/2 - label:GetTall()/2 - 1 )

		--draw.SimpleText( , "deathrun_derma_Small", k * (w/(#columns-1)),h/2, , align , TEXT_ALIGN_CENTER )
	end

	-- clickable
	local btn = vgui.Create("DButton", panel)
	btn:SetSize( panel:GetSize() )
	btn:SetPos(0,0)
	btn:SetText("")
	function btn:Paint() end
	btn.DoClick = doclick or function( self )
		self:GetParent():DoClick()
	end

	return panel
end

function MV:OpenFullMapList( maps )
	local frame = vgui.Create("deathrun_window")
	frame:SetSize(480, math.min(ScrH()-64, (480*1.618 - 44) ) ) -- GOLDEN RATIO FIBONACCI SPIRAL OMG
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Map List")

	local panel = vgui.Create("DPanel", frame)
	panel:SetPos(4,32)
	panel:SetSize( frame:GetWide() - 4, frame:GetTall() - 44 )

	function panel:Paint(w,h)
		
	end

	local scr = vgui.Create("DScrollPanel", panel)
	scr:SetSize(panel:GetWide()-8, panel:GetTall())
	scr:SetPos(4,0)

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
	dlist:SetSize(panel:GetWide(), 1500)
	dlist:SetPos(0,0)

	dlist:SetSpaceX(0)
	dlist:SetSpaceY(4)

	dlist.maps = maps

	MV.AllMapsListList = dlist

	MV:RepopulateMapList()
end

function MV:RepopulateMapList()
	if IsValid(MV.AllMapsListList) then
		local dlist = MV.AllMapsListList
		local maps = dlist.maps
		dlist:Clear()

		local lb = dlist:Add( "DLabel" )
		lb:SetFont( "deathrun_derma_Medium" )
		lb:SetText("Maps")
		lb:SetColor( DR.Colors.Turq )
		lb:SizeToContents()
		lb:SetWide( dlist:GetWide() )

		local lb = dlist:Add( "DLabel" )
		lb:SetFont( "deathrun_derma_Tiny" )
		lb:SetText("Click on a map to see its options!")
		lb:SetColor( DR.Colors.Turq )
		lb:SizeToContents()
		lb:SetWide( dlist:GetWide() )

		local pn = dlist:Add("DPanel")
		pn:SetWide( dlist:GetWide() )
		pn:SetTall( 8 )
		pn.Paint = function() end


		--dlist:Add( MV:NewDermaRow({"Click on a map to see options!"}, dlist:GetParent():GetParent():GetWide()-4, 24 ) )
		for i = 1,#maps do
			if maps[i] ~= game.GetMap() then
				local mapderma = MV:NewDermaRow({maps[i] or "Error.", MV:IsMapNominated( maps[i] ) and "[NOMINATED]" or "" }, dlist:GetParent():GetParent():GetWide()-8, 24, DR.Colors.Clouds, MV:IsMapNominated( maps[i] ) and DR.Colors.Turq or HexColor("#303030"),
					function( self )
						local map = self:GetParent().mapname

						local menu = vgui.Create("DMenu")
						local nominate = menu:AddOption("Nominate Map")
						nominate:SetIcon("icon16/lightbulb.png")
						nominate.mapname = map
						function nominate:DoClick()
							RunConsoleCommand("mapvote_nominate_map",self.mapname)
						end

						menu:Open()
					end
				)
				mapderma.mapname = maps[i]
				dlist:Add( mapderma )
			end
		end
	end
end

MV.AllMaps = {}

net.Receive("MapvoteSendAllMaps", function(len, ply)
	local data = net.ReadTable()
	MV:OpenFullMapList( data.maps )
end)

MV.Active = false
MV.VotingMapList = {}

-- actual voting menu place
function MV:OpenVotingPanel()

	local frame = vgui.Create("deathrun_window")
	frame:SetSize(230*1.618 + 4, (MV.MaxMaps*24) + (MV.MaxMaps-1)*4 + 44) -- GOLDEN RATIO FIBONACCI SPIRAL OMG
	frame:SetPos(4,0)
	frame:CenterVertical()
	--frame:MakePopup()
	frame:SetTitle("Mapvote")

	MV.VotingPanelDerma = frame

	local panel = vgui.Create("DPanel", frame)
	panel:SetPos(4,32)
	panel:SetSize( frame:GetWide() - 8, frame:GetTall() - 44 )

	function panel:Paint(w,h)
		
	end

	local dlist = vgui.Create("DIconLayout", panel)
	dlist:SetSize(panel:GetWide(), 1500)
	dlist:SetPos(0,0)

	dlist:SetSpaceX(0)
	dlist:SetSpaceY(4)

	MV.VotingPanelDermaList = dlist
	MV:RefreshVotingPanel()
end

MV.VotingMapsNoVotes = {}

function MV:RefreshVotingPanel()
	if IsValid( MV.VotingPanelDermaList ) then
		local dlist = MV.VotingPanelDermaList
		dlist:Clear()

		-- get the winning map--
		local win = ""
		local winvotes = 0
		for k,v in pairs(MV.VotingMapList) do
			if v > winvotes then
				winvotes = v
				win = k
			end
		end

		--if win == "" then win = table.Random( MV.VotingMapList )
		MV.VotingMapsNoVotes = {}
		local num = 0
		for k,v in pairs(MV.VotingMapList) do
			num = num + 1
			table.insert(MV.VotingMapsNoVotes, k)
			local row = MV:NewDermaRow({ tostring(num)..". ", k or 0,v or 0}, dlist:GetWide(), 24, k == win and DR.Colors.Turq or DR.Colors.Clouds, k == win and DR.Colors.Clouds or DR.Colors.Turq)
			row.mapname = k
			function row:DoClick()
				RunConsoleCommand("mapvote_vote",self.mapname)
			end
			dlist:Add( row )
		end
	end
end

net.Receive("MapvoteUpdateMapList", function()
	MV.VotingMapList = net.ReadTable()
	MV:RefreshVotingPanel()
end)

net.Receive("MapvoteSetActive", function()
	MV.Active = tobool(net.ReadBit())

	if MV.Active then MV:OpenVotingPanel() end
	MV.VotingMapList = net.ReadTable()
	MV.TimeLeft = net.ReadFloat()
	MV:RefreshVotingPanel()
end)


timer.Create("MapvoteCountdownTimer", 0.2, 0, function()
	if MV.Active == true then
		MV.TimeLeft = MV.TimeLeft - 0.2
		if IsValid(MV.VotingPanelDerma) then
			
			MV.VotingPanelDerma:SetTitle( "Mapvote - "..string.ToMinutesSeconds(MV.TimeLeft > 0 and MV.TimeLeft or 0) )

			if MV.TimeLeft <= 0 then
				timer.Simple(4, function()
					if IsValid(MV.VotingPanelDerma) then
						MV.VotingPanelDerma:Close()
					end
				end)
			end
		end
		if MV.TimeLeft < 0 then
			MV.TimeLeft = 0
		end
	end
end)

local keynums = {
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9,
}

hook.Add("SetupMove","MapvoteReceiveKeys", function( )
	if (not vgui.CursorVisible()) and MV.Active then
		for i = 1, #keynums do
			local mapname = MV.VotingMapsNoVotes[i]
			if input.WasKeyPressed( keynums[i] ) then
				RunConsoleCommand("mapvote_vote",mapname)
			end
		end
	end
end)