-- script to keep track of all statistics for players
-- kills, deaths, round wins
-- if a runner dies, then that's 1 kill for everyone on the Death team.
print("Loading Statistics...")

if SERVER then

	-- record timings
	--sql.Query("DROP TABLE deathrun_records")
	sql.Query("CREATE TABLE IF NOT EXISTS deathrun_records ( sid64 STRING, mapname STRING, seconds REAL )")

	hook.Add("DeathrunPlayerFinishMap", "DeathrunMapRecords", function( ply, zname, zone, place, seconds )
		local sid64 = ply:SteamID64()
		local mapname = game.GetMap()

		sql.Query("INSERT INTO deathrun_records VALUES ('"..sid64.."', '"..mapname.."', "..tostring(seconds)..")")
	end)

	local endmap = nil
	local function findendmap()
		--PrintTable( ZONE.zones )
		if ZONE.zones then
			for k,v in pairs( ZONE.zones ) do
				print(v.type)
				if v.type == "end" then
					endmap = v
				end
			end
		end
	end
	findendmap()

	hook.Add("InitPostEntity", "DeathrunFindEndZone", function()
		findendmap()
	end)

	hook.Add("DeathrunBeginPrep", "DeathrunSendRecords", function()

		-- deathrun_send_map_records
		--
		res = sql.Query("SELECT * FROM deathrun_records WHERE mapname = '"..game.GetMap().."' ORDER BY seconds ASC LIMIT 3")

		--PrintTable( endmap )
		if endmap ~= nil and res ~= false then
			if res == nil then 
				res = {}
			else
				for i = 1, #res do
					res[i]["nickname"] = DR:SteamToNick( res[i]["sid64"] )
				end
			end

			net.Start("deathrun_send_map_records")
			net.WriteVector( 0.5*(endmap.pos1 + endmap.pos2) )
			net.WriteString( util.TableToJSON( res ) )
			net.Broadcast()
		end

		for k,ply in ipairs(player.GetAll()) do
			res2 = sql.Query("SELECT * FROM deathrun_records WHERE mapname = '"..game.GetMap().."' AND sid64 = '"..ply:SteamID64().."' ORDER BY seconds ASC LIMIT 3")
			if endmap ~= nil and res2 ~= false then
				local seconds = -1
				if res2 ~= nil then
					if res2[1] then
						if res2[1]["seconds"] then
							seconds = res2[1]["seconds"]
						end
					end
				end

				net.Start("deathrun_send_map_pb")
				net.WriteFloat( seconds )
				net.Send( ply )
			end
		end

	end)

	-- store a table of all the player names and associated steamid communityid when they join

	sql.Query( "CREATE TABLE deathrun_ids ( sid64 STRING, sid STRING, nick STRING )" )

	hook.Add("PlayerInitialSpawn", "UpdatePlayerIDs", function(ply)
		-- update player names
		local id64 = ply:SteamID64()
		local id = ply:SteamID()

		local res = sql.Query( "SELECT * FROM deathrun_ids WHERE sid64 = '"..id64.."'" )
		if not res then
			res = sql.Query( "INSERT INTO deathrun_ids VALUES ( '"..id64.."', '"..id.."', '"..Base64Encode( ply:Nick() ).."' )" )
		else
			res = sql.Query( "UPDATE deathrun_ids SET nick = '"..Base64Encode( ply:Nick() ).."' WHERE sid64 = '"..id64.."' " )
		end
	end)

	function DR:SteamToNick( sid )
		local com = true
		if string.find( sid, "STEAM_" ) ~= nil then com = false end

		local nick = "UNKNOWN"
		local res

		if com then
			res = sql.Query( "SELECT * FROM deathrun_ids WHERE sid64 = '"..sid.."'" )
		else
			res = sql.Query( "SELECT * FROM deathrun_ids WHERE sid = '"..sid.."'" )
		end

		if res then
			nick = Base64Decode( res[1]["nick"] )
		end

		return nick

	end


	sql.Query( "CREATE TABLE deathrun_stats ( sid STRING, kills INTEGER, deaths INTEGER, runner_wins INTEGER, death_wins INTEGER )" )

	hook.Add("PlayerAuthed", "CreateStatsRow", function( ply, steamid, uid )
		local res = sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..steamid.."'" )
		if not res then
			res = sql.Query( "INSERT INTO deathrun_stats VALUES ( '"..steamid.."', 0, 0, 0, 0 )" )
		end

		res = sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..steamid.."'" )

	end)

	hook.Add("PlayerDeath", "DeathrunStats", function( vic, inf, att )

		if ROUND:GetCurrent() == ROUND_ACTIVE then

			if att:IsPlayer() then
				if vic:Team() ~= att:Team() then
					data1 = sql.Query( "SELECT kills FROM deathrun_stats WHERE sid = '"..att:SteamID().."'")
					local kills = data1[1]["kills"]
					res = sql.Query( "UPDATE deathrun_stats SET kills = "..tostring(kills+1).." WHERE sid = '"..att:SteamID().."'" )
				end
			else
				if vic:Team() == TEAM_RUNNER then
					for _, ply in ipairs( team.GetPlayers( TEAM_DEATH ) ) do
						if not ply:IsBot() then
							data1 = sql.Query( "SELECT kills FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'")
							local kills = data1[1]["kills"]
							res = sql.Query( "UPDATE deathrun_stats SET kills = "..tostring(kills+1).." WHERE sid = '"..ply:SteamID().."'" )
						end
					end
				end
			end

			if vic:IsPlayer() and not vic:IsBot() then
				data2 = sql.Query( "SELECT deaths FROM deathrun_stats WHERE sid = '"..vic:SteamID().."'")
				local deaths = data2[1]["deaths"]
				res = sql.Query( "UPDATE deathrun_stats SET deaths = "..tostring(deaths+1).." WHERE sid = '"..vic:SteamID().."'" )
			end

		end

	end)

	hook.Add("DeathrunRoundWin", "stats", function( winteam )
		if winteam == TEAM_RUNNER or winteam == TEAM_DEATH then
			players = team.GetPlayers( winteam )
			if winteam == TEAM_RUNNER then
				for k,ply in ipairs( players ) do
					if not ply:IsBot() then 
						local data1 = sql.Query("SELECT runner_wins FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'")
						local wins = data1[1]["runner_wins"]
						sql.Query( "UPDATE deathrun_stats SET runner_wins = "..tostring( wins+1 ).." WHERE sid = '"..ply:SteamID().."'")
					end
				end
			end
			if winteam == TEAM_DEATH then
				for k,ply in ipairs( players ) do
					if not ply:IsBot() then 
						local data1 = sql.Query("SELECT death_wins FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'")
						local wins = data1[1]["death_wins"]
						sql.Query( "UPDATE deathrun_stats SET death_wins = "..tostring( wins+1 ).." WHERE sid = '"..ply:SteamID().."'")
					end
				end
			end
		end
	end)

	concommand.Add("stats_test", function( ply, cmd, args )
		PrintTable( sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'" ) )
	end)

	function DR:DisplayStats( ply ) -- displays a player's stats in front of their face
		if IsValid( ply ) then
			local res = sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'" )
			local res2 = sql.Query("SELECT sid, (runner_wins + death_wins) AS total_wins FROM deathrun_stats ORDER BY total_wins DESC LIMIT 1")

			local highscoreName = ""
			local highscore = 0

			if res2 then
				highscoreName = DR:SteamToNick( res2[1]["sid"] )
				highscore = res2[1]["total_wins"]

				--PrintTable( res2 )
			end

			if res then
				net.Start("deathrun_display_stats")
				--kills
				net.WriteInt( res[1]["kills"], 16 )
				--deaths
				net.WriteInt( res[1]["deaths"], 16 )
				--runner_wins
				net.WriteInt( res[1]["runner_wins"], 16 )
				--death_wins
				net.WriteInt( res[1]["death_wins"], 16 )

				net.WriteString( highscoreName )
				net.WriteInt( highscore, 32 )

				net.Send( ply )
			end
		end
	end

	hook.Add("PlayerLoadout", "DisplayStatsForPlayers", function(ply)
		if ply:Alive() and not ply:GetSpectate() then
			timer.Simple(0.5, function()
				DR:DisplayStats( ply )
			end )
		end
	end)

	concommand.Add("deathrun_display_stats", function( ply, cmd, args )
		DR:DisplayStats( ply )
	end)

	util.AddNetworkString("deathrun_send_stats")
	util.AddNetworkString("deathrun_display_stats")
	util.AddNetworkString("deathrun_send_map_records")
	util.AddNetworkString("deathrun_send_map_pb")


end

if CLIENT then

	DR.MapRecordsDrawPos = Vector(0,0,0)
	DR.MapRecordsCache = {}
	DR.MapPBCache = 0



	net.Receive("deathrun_send_map_records", function()
		DR.MapRecordsDrawPos = net.ReadVector()
		DR.MapRecordsCache = util.JSONToTable( net.ReadString() )

		print("Records Pos",DR.MapRecordsDrawPos)
		PrintTable( DR.MapRecordsCache )
	end)

	net.Receive("deathrun_send_map_pb", function()
		DR.MapPBCache = net.ReadFloat()
	end)

	DR.PlayerStatsCache = {}

	net.Receive( "deathrun_send_stats", function()
		--print("meme")
		local t = table.Copy( net.ReadTable() )
		DR.PlayerStatsCache[ t[1]["sid"] ] = t[1]
		--print("meme")
		local name = t[1]["sid"]
		for k,v in ipairs(player.GetAll()) do
			if name == v:SteamID() then
				name = v:Nick()
			end
		end

		local msg = [[Stats for ]]..name..[[:
	Kills: ]]..tostring(t[1]["kills"])..[[

	Deaths: ]]..tostring(t[1]["deaths"])..[[

	Runner Wins: ]]..tostring(t[1]["runner_wins"])..[[

	Death Wins: ]]..tostring(t[1]["death_wins"])..[[
]]

		DR:ChatMessage( msg )
	end)

	-- display stats on a player's face
	local stats3d = {
		pos = Vector(0,0,0),
		ang = Angle(0,0,0),
		data = {},
		born = 0
	}

	local statsvis = CreateClientConVar( "deathrun_stats_visibility", 1, true, false )
	local labels = {}

	net.Receive( "deathrun_display_stats", function()

		if IsValid( LocalPlayer() ) then
			if statsvis:GetBool() == true then
				local kills, deaths, run_win, dea_win

				kills = net.ReadInt( 16 )
				deaths = net.ReadInt( 16 )
				run_win = net.ReadInt( 16 )
				dea_win = net.ReadInt( 16 )
				mo_wins_name = net.ReadString()
				mo_wins = net.ReadInt( 32 )

				stats3d.data = {
					kills,
					deaths,
					run_win,
					dea_win,
					mo_wins_name.." ("..tostring(mo_wins)..")",
				}

				labels = {
					"Your Kills",
					"Your Deaths",
					"Your Runner Wins",
					"Your Death Wins",
					"Most Wins",
				}

				stats3d.pos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward()*36
				stats3d.ang = LocalPlayer():EyeAngles()
				stats3d.ang:RotateAroundAxis( LocalPlayer():EyeAngles():Right(), 90 )
				stats3d.ang:RotateAroundAxis( LocalPlayer():EyeAngles():Forward(), 90 )
				stats3d.born = CurTime()

				hook.Call( "DeathrunAddStatsRow", nil, labels, stats3d.data)
			end
		end


	end)

	local w, h = 1000, 380
	local x, y = -w/2, -h/2

	surface.CreateFont("deathrun_3d2d_large", {
		font = "Roboto Black",
		size = 80,
		antialias = true,
	})
	surface.CreateFont("deathrun_3d2d_small", {
		font = "Roboto Black",
		size = 50,
		antialias = true,
	})

	

	hook.Add( "PostDrawTranslucentRenderables", "statsdisplay", function()
	
		local delay = 0.45
		local lifetime = 10 + delay

		local t = CurTime()-( stats3d.born + delay )

		if t < lifetime then
			h = 80 + 75 * #labels

			cam.Start3D2D( stats3d.pos, stats3d.ang, 0.04 )

				render.ClearStencil()
				render.SetStencilEnable(true) -- i dont know how this works?!?!?!?

				render.SetStencilFailOperation(STENCILOPERATION_KEEP)
				render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
				render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
				render.SetStencilReferenceValue(1)

				surface.SetDrawColor(Color(0, 0, 0, 255))
				if t < lifetime-1 then
					surface.DrawRect(x,y,w,h*QuadLerp( math.Clamp( InverseLerp(t,0,1), 0, 1 ), 0, 1 ) )
				else
					surface.DrawRect(x,y,w, h*QuadLerp( math.Clamp( InverseLerp( t, lifetime-1, lifetime ), 0, 1 ), 1, 0 ) )
				end

				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				render.SetStencilPassOperation(STENCILOPERATION_REPLACE)

				-- draw
				surface.SetDrawColor( DR.Colors.Clouds )
				surface.DrawRect(x,y,w,h)

				surface.SetDrawColor( DR.Colors.Turq )
				surface.DrawRect(x,y,w,80)

				deathrunShadowTextSimple("STATS", "deathrun_3d2d_large", 0, y, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2)

				

				for i = 1, #labels do
					deathrunShadowTextSimple(labels[i], "deathrun_3d2d_small", x+20, y + 100 + 70*(i-1), DR.Colors.Text.Grey3, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0)
				end
				for i = 1, #stats3d.data do
					deathrunShadowTextSimple(tostring(stats3d.data[i]), "deathrun_3d2d_small", x+w-20, y + 100 + 70*(i-1), DR.Colors.Text.Turq, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 0)
				end
				-- close stencil

				render.SetStencilEnable(false)


			cam.End3D2D()
		end

		if DR.MapRecordsDrawPos ~= Vector(0,0,0) and DR.MapRecordsDrawPos ~= nil then
			local dist = LocalPlayer():GetPos():Distance( DR.MapRecordsDrawPos )
			if dist < 1000 then
				-- 

				-- local recordsAng = ( (LocalPlayer():EyePos() - DR.MapRecordsDrawPos):GetNormalized() )
				-- recordsAng = recordsAng:Angle() + Angle(90,0,00)
				-- recordsAng:RotateAroundAxis( recordsAng:Up(), 90)
				-- recordsAng.roll = 90

				--recordsAng:RotateAroundAxis( LocalPlayer():EyeAngles():Right(), 90 )
				--recordsAng:RotateAroundAxis( LocalPlayer():EyeAngles():Forward(), 90 )

				--local scale = math.Clamp( InverseLerp( dist, 1000, 400 ), 0,1) * 0.12

				--if dist < 20 then
					local recordsAng = LocalPlayer():EyeAngles()
					recordsAng:RotateAroundAxis( LocalPlayer():EyeAngles():Right(), 90 )
					recordsAng:RotateAroundAxis( LocalPlayer():EyeAngles():Forward(), 90 )
					recordsAng.roll = 90
				--end

				cam.Start3D2D( DR.MapRecordsDrawPos, recordsAng, 0.10 )
					
					surface.SetDrawColor( DR.Colors.Turq )
					surface.DrawRect(-700,-300, 1400, 80 )

					deathrunShadowTextSimple("TOP 3 RECORDS", "deathrun_3d2d_large", 0, -300, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2)
						
					if DR.MapRecordsCache[1] ~= nil then
						for i = 1, #DR.MapRecordsCache + 2 do
							local k = i-1
							if i <= #DR.MapRecordsCache then
								local v = DR.MapRecordsCache[i]

								deathrunShadowTextSimple( tostring(i)..". "..string.sub( v["nickname"] or "", 1, 24 ), "deathrun_3d2d_large", -700, -150 + 100*k, DR.Colors.Text.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2 )
								deathrunShadowTextSimple( string.ToMinutesSecondsMilliseconds(v["seconds"] or "0"), "deathrun_3d2d_large", 700, -150 + 100*k, DR.Colors.Text.Turq, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2 )

								surface.SetDrawColor( DR.Colors.Turq )
								surface.DrawRect(-700,-150 + 100*k + 80, 1400, 2 )
							elseif i == #DR.MapRecordsCache + 2 and DR.MapPBCache ~= 0 then
								deathrunShadowTextSimple( "Personal Best", "deathrun_3d2d_large", -700, -150 + 100*k, DR.Colors.Text.Clouds, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2 )
								deathrunShadowTextSimple( string.ToMinutesSecondsMilliseconds( DR.MapPBCache or 0 ), "deathrun_3d2d_large", 700, -150 + 100*k, DR.Colors.Text.Turq, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2 )

								surface.SetDrawColor( DR.Colors.Turq )
								surface.DrawRect(-700,-150 + 100*k + 80, 1400, 2 )
							end
						end
					else
						deathrunShadowTextSimple( "No records yet!", "deathrun_3d2d_large", 0, -200, DR.Colors.Text.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2 )
					end
				cam.End3D2D()
			end
		end

		
	end)

end

-- calculate DAS score
-- Deathrun Aggregated Score is calculated like so:
-- { [ ( 1 - 0.5^(death_wins + runner_wins) ) / 0.5 ] -1 } * sqrt(KDR)
-- where KDR = K/D

if SERVER then
	
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+='
function Base64Encode(data)
	return ((data:gsub('.', function(x) 
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

function Base64Decode(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

if SERVER then
	DR:AddChatCommand("records",function(ply, args)
		ply:ConCommand("deathrun_records_menu")
	end)
end