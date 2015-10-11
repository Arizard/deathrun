-- script to keep track of all statistics for players
-- kills, deaths, round wins
-- if a runner dies, then that's 1 kill for everyone on the Death team.
print("Loading Statistics...")

if SERVER then

	sql.Query( "CREATE TABLE deathrun_stats ( sid STRING, kills INTEGER, deaths INTEGER, runner_wins INTEGER, death_wins INTEGER )" )

	hook.Add("PlayerAuthed", "CreateStatsRow", function( ply, steamid, uid )
		local res = sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..steamid.."'" )
		if not res then
			res = sql.Query( "INSERT INTO deathrun_stats VALUES ( '"..steamid.."', 0, 0, 0, 0 )" )
		end

		res = sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..steamid.."'" )
	end)

	hook.Add("PlayerDeath", "DeathrunStats", function( vic, inf, att )

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
		local res = sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'" )

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

			net.Send( ply )
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

end

if CLIENT then

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

	net.Receive( "deathrun_display_stats", function()

		if IsValid( LocalPlayer() ) then
			if statsvis:GetBool() == true then
				local kills, deaths, run_win, dea_win

				kills = net.ReadInt( 16 )
				deaths = net.ReadInt( 16 )
				run_win = net.ReadInt( 16 )
				dea_win = net.ReadInt( 16 )

				stats3d.data = {
					kills,
					deaths,
					run_win,
					dea_win
				}

				stats3d.pos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward()*36
				stats3d.ang = LocalPlayer():EyeAngles()
				stats3d.ang:RotateAroundAxis( LocalPlayer():EyeAngles():Right(), 90 )
				stats3d.ang:RotateAroundAxis( LocalPlayer():EyeAngles():Forward(), 90 )
				stats3d.born = CurTime()
			end
		end
	end)

	local w, h = 600, 380
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
			cam.Start3D2D( stats3d.pos, stats3d.ang, 0.05 )

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

				deathrunShadowTextSimple("YOUR STATS", "deathrun_3d2d_large", 0, y, DR.Colors.Clouds, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2)

				local labels = {
				"Kills",
				"Deaths",
				"Runner Wins",
				"Death Wins"
				}

				for i = 1, #labels do
					deathrunShadowTextSimple(labels[i], "deathrun_3d2d_small", x+20, y + 100 + 70*(i-1), DR.Colors.Text.Grey3, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 0)
				end
				for i = 1, #stats3d.data do
					deathrunShadowTextSimple(tostring(stats3d.data[i]), "deathrun_3d2d_small", x+w-20, y + 100 + 70*(i-1), DR.Colors.Text.Turq, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 0)
				end
				-- close stencil

				render.SetStencilEnable(false)


			cam.End3D2D()
		end

		
	end)

end
