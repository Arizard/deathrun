local columns = {"Name", "blank","Title", "Rank", "Ping"}
local columnFunctions = {
	function( ply ) return ply:Nick() end,
	function() return "" end, -- empty space to even the spacings out
	function( ply ) 
		return hook.Call("GetScoreboardTag", nil, ply) or ""
	end,
	function( ply ) 
		return hook.Call("GetScoreboardRank", nil, ply) or string.upper(ply:GetUserGroup())
	end,
	function( ply ) return ply:Ping() end,
}

local function IsSupporting( ply )

	local strings = {
		"VHS7",
		"VHS-7",
		"vhs7.tv",
	}

	for i = 1, #strings do
		if string.find( string.lower( ply:Nick() ), string.lower( strings[i] ) ) ~= nil then
			return true
		end
	end

	return false
end

CreateClientConVar("deathrun_scoreboard_small", 1, true, false)


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

			self:SetPos( x, QuadLerp( math.Clamp( InverseLerp( self.dt,0,dur ), 0, 1), ScrH()+50, 50) )

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
	header.counter = 0.5
	function header:Paint(w,h)
		surface.SetDrawColor( DR.Colors.Turq or HexColor("#303030") )
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(255,255,255, 155*(1-math.pow( ( ( (math.sin(CurTime())+1)/2 ) ), 0.1))  )
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(0,h-3,w,3)

		-- make the hostname scroll left and right
		surface.SetFont("deathrun_derma_Large")

		local cycle = 12

		self.counter = self.counter + FrameTime()/cycle

		local fw, fh = surface.GetTextSize( GetHostName() )
		fw = fw + 64 -- 64 pixel gap



		if self.counter > 1 then self.counter = 0 end
		if fw > self:GetWide() then
			deathrunShadowTextSimple( GetHostName(), "deathrun_derma_Large", 4 + fw - self.counter * fw , h/2-2, DR.Colors.Text.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1)
			deathrunShadowTextSimple( GetHostName(), "deathrun_derma_Large", 4 - self.counter * fw , h/2-2, DR.Colors.Text.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1)
		else
			deathrunShadowTextSimple( GetHostName(), "deathrun_derma_Large", w/2 , h/2-2, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
		end
	end

	local small = GetConVar("deathrun_scoreboard_small"):GetBool()

	dlist:Add( header )
	dlist:Add( DR:NewScoreboardSpacer( {"[Hint] Right Click to scroll and interact with scoreboard."}, dlist:GetWide(), small and 24 or 32, DR.Colors.Turq ) )

	dlist:Add( DR:NewScoreboardSpacer( {tostring(#team.GetPlayers(TEAM_DEATH)).." players on Death Team"}, dlist:GetWide(), small and 24 or 32, team.GetColor( TEAM_DEATH ) ) )
	for k,ply in ipairs(team.GetPlayers( TEAM_DEATH )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), small and 22 or 28 ) )
	end
	dlist:Add( DR:NewScoreboardSpacer( {tostring(#team.GetPlayers(TEAM_RUNNER)).." players on Runner Team"}, dlist:GetWide(), small and 24 or 32, team.GetColor( TEAM_RUNNER ) ) )
	for k,ply in ipairs(team.GetPlayers( TEAM_RUNNER )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), small and 22 or 28 ) )
	end
	if GhostMode then -- GhostMode support
		dlist:Add( DR:NewScoreboardSpacer( {tostring(#team.GetPlayers(TEAM_GHOST)).." players in Ghost Mode"}, dlist:GetWide(), small and 24 or 32, team.GetColor( TEAM_GHOST ) ) )
		for k,ply in ipairs(team.GetPlayers( TEAM_GHOST )) do
			dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), small and 22 or 28 ) )
		end
	end
	dlist:Add( DR:NewScoreboardSpacer( {tostring(#team.GetPlayers(TEAM_SPECTATOR)).." players Spectating"}, dlist:GetWide(), small and 24 or 32,  HexColor("#303030") ) )
	for k,ply in ipairs(team.GetPlayers( TEAM_SPECTATOR )) do
		dlist:Add( DR:NewScoreboardPlayer( ply, dlist:GetWide(), small and 22 or 28 ) )
	end

	local options = DR:NewScoreboardSpacer( {""}, dlist:GetWide(), 24, HexColor("#303030") )

	local sizetog = vgui.Create("AuToggle_Deathrun", options)
	sizetog:SetConVar( "deathrun_scoreboard_small" )
	sizetog:SetText("Small Text")
	sizetog:SizeToContents()

	dlist:Add( options )
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

		local small = GetConVar("deathrun_scoreboard_small"):GetBool()

		label:SetFont(small and "deathrun_derma_Tiny" or "deathrun_derma_Small")
		label:SizeToContents()
		label:SetPos( #columns > 1 and 4+(k * ((panel:GetWide()-8)/(#columns-1)) - label:GetWide()*align) or (panel:GetWide()-8)/2 - label:GetWide()/2, 0 )
		label:CenterVertical()

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

				draw.SimpleText("✖", "deathrun_derma_Medium", w/2, h/2-1, DR.Colors.Alizarin, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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

	local path = false

	if ply:IsAdmin() or ply:IsSuperAdmin() then
		path = "icon16/shield.png"
	elseif IsSupporting( ply ) then
		path = "icon16/heart.png"
	end

	local tpath = hook.Call("GetScoreboardIcon", nil, ply)
	if tpath then
		path = tpath
	end

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
		local small = GetConVar("deathrun_scoreboard_small"):GetBool()

		label:SetFont(small and "deathrun_derma_Tiny" or "deathrun_derma_Small")
		label:SetExpensiveShadow( 1 )
		label:SizeToContents()
		label:SetPos( k * ((data:GetWide()-8)/(#columns-1)) - label:GetWide()*align, 0  )
		label:CenterVertical()

		--draw.SimpleText( , "deathrun_derma_Small", k * (w/(#columns-1)),h/2, , align , TEXT_ALIGN_CENTER )
	end


	local but = vgui.Create("DButton", panel)
	but:SetSize(w, h)
	but:SetText("")

	--options for clicking on a player: Copy steamid, Open profile, mute player

	function but:DoClick()
		local menu = vgui.Create("DMenu")
		menu.ply = self:GetParent().ply

		if not menu.ply:IsBot() then
		
			local copyID = menu:AddOption( "Copy SteamID to clipboard" )
			copyID.ply = menu.ply
			copyID:SetIcon("icon16/page_copy.png")
			function copyID:DoClick()
				if not IsValid(self.ply) then return end
				SetClipboardText( self.ply:SteamID() )
				DR:ChatMessage( self.ply:Nick().."'s SteamID was copied to the clipboard!" )
			end

			--http://steamcommunity.com/profiles/

			local openprofile = menu:AddOption( "Open Steam profile" )
			openprofile.ply = menu.ply
			openprofile:SetIcon("icon16/page_world.png")
			function openprofile:DoClick()
				if not IsValid(self.ply) then return end
				gui.OpenURL( "http://steamcommunity.com/profiles/"..self.ply:SteamID64() )
			end

			local mute = menu:AddOption( "Toggle voice" )
			mute.ply = menu.ply
			mute:SetIcon("icon16/sound.png")
			function mute:DoClick()
				if not IsValid(self.ply) then return end
				RunConsoleCommand("deathrun_toggle_mute",self.ply:SteamID())
				DR:ChatMessage( "Toggled mute on "..self.ply:Nick().."!" )
			end

		end

		if DR:CanAccessCommand( LocalPlayer(), "deathrun_force_spectate" ) then
			local specop = menu:AddOption( "Force to Spectator" ) -- spectator options... SPEC OPS!
			specop.ply = menu.ply
			specop:SetIcon("icon16/status_offline.png")
			function specop:DoClick()
				if not IsValid(self.ply) then return end
				net.Start("DeathrunForceSpectator")
				net.WriteString( self.ply:SteamID() )
				net.SendToServer()
			end
		end

		-- local punop = menu:AddOption( "Force Death for 1 round" )
		-- punop.ply = menu.ply
		-- punop:SetIcon("icon16/controller_delete.png")
		-- function punop:DoClick()
		-- 	if not IsValid( self.ply ) then return end

		-- 	RunConsoleCommand("deathrun_punish",)
		-- end
		
		menu:AddSpacer()

		-- ulx support
		if ulx then

			if ULib.ucl.query( LocalPlayer(), "ulx gag", true) then
				local option = menu:AddOption( "Gag player voice" ) -- gag
				option.ply = menu.ply
				option:SetIcon("icon16/sound.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand( "ulx gag "..[["]]..self.ply:Nick()..[["]] )
				end
			
				local option = menu:AddOption( "Ungag player voice" ) -- ugag
				option.ply = menu.ply
				option:SetIcon("icon16/sound.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand( "ulx ungag "..[["]]..self.ply:Nick()..[["]] )
				end
			end
			if ULib.ucl.query( LocalPlayer(), "ulx mute", true) then
				local option = menu:AddOption( "Mute player chat" ) -- gag
				option.ply = menu.ply
				option:SetIcon("icon16/style_delete.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx mute "..[["]]..self.ply:Nick()..[["]] )
				end
				local option = menu:AddOption( "Unmute player chat" ) -- gag
				option.ply = menu.ply
				option:SetIcon("icon16/style_delete.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx unmute "..[["]]..self.ply:Nick()..[["]] )
				end
			end
			if ULib.ucl.query( LocalPlayer(), "ulx slay", true) then
				local option = menu:AddOption( "Slay player" ) -- gag
				option.ply = menu.ply
				option:SetIcon("icon16/newspaper.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx slay "..[["]]..self.ply:Nick()..[["]] )
				end
			end
			if ULib.ucl.query( LocalPlayer(), "ulx kick", true) then
				local option = menu:AddOption( "Kick from server" ) -- kick
				option.ply = menu.ply
				option:SetIcon("icon16/sport_football.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx kick "..[["]]..self.ply:Nick()..[["]]..' Kicked by server staff.' )
				end
			end
			if ULib.ucl.query( LocalPlayer(), "ulx ban", true) then
				local option = menu:AddOption( "Ban for 30 minutes" ) -- 30m ban
				option.ply = menu.ply
				option:SetIcon("icon16/clock.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx banid "..self.ply:SteamID()..' 30 Banned by server staff for half an hour.' )
				end
				local option = menu:AddOption( "Ban for 2 hours" ) -- 2hr ban
				option.ply = menu.ply
				option:SetIcon("icon16/clock.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx banid "..self.ply:SteamID()..' 120 Banned by server staff for 2 hours.' )
				end
				local option = menu:AddOption( "Ban for 24 hours" ) -- 1d ban
				option.ply = menu.ply
				option:SetIcon("icon16/clock.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx banid "..self.ply:SteamID()..' 1440 Banned by server staff for 1 day.' )
				end
				local option = menu:AddOption( "Ban for 1 week" ) -- 7d ban
				option.ply = menu.ply
				option:SetIcon("icon16/clock.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx banid "..self.ply:SteamID()..' 10080 Banned by server staff for 1 week.' )
				end
				local option = menu:AddOption( "Ban permanently" ) -- 7d ban
				option.ply = menu.ply
				option:SetIcon("icon16/clock_red.png")
				function option:DoClick()
					if not IsValid(self.ply) then return end
					LocalPlayer():ConCommand("ulx banid "..self.ply:SteamID()..' 0 Banned by server staff forever.' )
				end
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

	local should = hook.Call("DeathrunOpenScoreboard", nil) -- return false to suppress scoreboard opening

	if should == false then return end

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

-- hall of fame/hall of lame
DR.ScoreboardSpecials = {}

function DR:SetScoreboardDisplay( sid, _icon, _col, _tag, _rank ) -- leave nil to use defaults
	DR.ScoreboardSpecials[ sid ] = {
		icon = _icon or nil,
		col = _col or nil, 
		tag = _tag or nil,
		rank = _rank or nil,
	}
end

DR:SetScoreboardDisplay( "STEAM_0:1:30288855", 	"icon16/cup.png", 						Color(50,200,0), 		"Author", 										nil ) -- arizard
DR:SetScoreboardDisplay( "STEAM_0:0:29351088", 	"icon16/rainbow.png", 					Color( 200, 0, 0 ), 	"Worst Player", 								nil ) -- zelpa
DR:SetScoreboardDisplay( "STEAM_0:1:128126755", "icon16/drink.png",						Color(255,200,255), 	"Confirmed Grill",								nil ) -- krystal
DR:SetScoreboardDisplay( "STEAM_0:0:90710956",	"icon16/cup_error.png",					HexColor( "#009600" ),	"Associate", 									nil ) -- tarkus
DR:SetScoreboardDisplay( "STEAM_0:1:147138529", "icon16/anchor.png",					HexColor( "#a66bbe" ),	"MEME MASTER",									nil ) -- kaay
DR:SetScoreboardDisplay( "STEAM_0:1:64432636",	"icon16/map_go.png",	HexColor( "#99ff33" ),	"Playboy Bunny",								nil ) -- gamefresh
DR:SetScoreboardDisplay( "STEAM_0:1:89220979",	"icon16/joystick.png",					HexColor( "#8cfaef" ),	"Neko Nation",									nil ) -- fich
DR:SetScoreboardDisplay( "STEAM_0:0:71992617",	"icon16/tux.png",						HexColor( "#8cfaef" ),	tostring( math.random(100) ).."% Unstable",		nil ) -- haina
DR:SetScoreboardDisplay( "STEAM_0:1:86065559",	"icon16/lightning.png",						Color(255, 18, 18),	"Little Kid",		nil ) -- josh
DR:SetScoreboardDisplay( "STEAM_0:0:56846935",	"icon16/money.png",	HexColor( "#ffc048" ),	"Scammer",								nil ) -- preck

hook.Add("GetScoreboardNameColor","memes", function( ply ) -- do not remove or i kill u

	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end

		--Added colours for the usual usergroups
	--if ply:GetUserGroup() == "moderator" then
		--return HexColor("#0ca917")
	--elseif ply:GetUserGroup() == "admin" then
		--return HexColor("#e16600")
	--elseif ply:GetUserGroup() == "superadmin" then
		--return HexColor("#8cfaef")
	--end
		
	if data then
		if data.col then
			return data.col
		end
	end
end)

hook.Add("GetScoreboardIcon","memes 2: electric dootaloo", function( ply )

	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end

	if data then
		if data.icon then
			return data.icon
		end
	end
end)

hook.Add("GetScoreboardTag", "memes 3: this time it's personal", function( ply )

	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end
	
	--Added easy to customise basic tags for usual ranks
	--if ply:GetUserGroup() == "moderator" then
		--return "Jr. Staff"
	--elseif ply:GetUserGroup() == "admin" then
		--return "Staff"
	--elseif ply:GetUserGroup() == "superadmin" then
		--return "Sr. Staff"
	--end	
	
	if data then
		if data.tag then
			return data.tag
		end
	end
end)

hook.Add("GetScoreboardRank", "memes 4: a good day to meme hard", function( ply )
	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end

	if data then
		if data.rank then
			return data.rank
		end
	end
end)
