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
				res = sql.Query( "UPDATE deathrun_stats SET kills = "..tostring(kills+1) )
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
			res = sql.Query( "UPDATE deathrun_stats SET deaths = "..tostring(deaths+1) )
		end

	end)

	concommand.Add("stats_test", function( ply, cmd, args )
		PrintTable( sql.Query( "SELECT * FROM deathrun_stats WHERE sid = '"..ply:SteamID().."'" ) )
	end)

	util.AddNetworkString("deathrun_send_stats")

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



end
