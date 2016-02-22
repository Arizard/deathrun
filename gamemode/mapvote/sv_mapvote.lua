include("sh_mapvote.lua")
util.AddNetworkString("MapvoteUpdateMapList")
util.AddNetworkString("MapvoteSendAllMaps")
util.AddNetworkString("MapvoteSetActive")
util.AddNetworkString("MapvoteSyncNominations")

MV.MapList = {}
MV.Players = {} -- store each player's vote - {Player, Map}
MV.PlayerNominations = {}
MV.Nominations = {}

MV.Active = false
MV.TimeLeft = MV.VotingTime

MV.LoadTime = CurTime()

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE

if not file.Exists("map_statistics.txt", "DATA") then
	file.Write("map_statistics.txt","[]")
end

MV.MapStats = util.JSONToTable( file.Read("map_statistics.txt", "DATA") )

hook.Add("DeathrunBeginPrep", "RecordMapStats", function() -- increment stats by 1 each time a round is played on the map
	local map = game.GetMap()
	MV.MapStats[map] = MV.MapStats[map] or #player.GetAllPlaying()
	MV.MapStats[map] = MV.MapStats[map] + #player.GetAllPlaying()
	file.Write("map_statistics.txt", util.TableToJSON( MV.MapStats ) )
end)

--commands
concommand.Add("mapvote_list_maps", function(ply)

	net.Start("MapvoteSendAllMaps")
	net.WriteTable({
		maps = MV:GetGoodMaps(),
		action = "openlist"
	})
	net.Send( ply )

end)

DR:AddChatCommand("nominate", function( ply )
	ply:ConCommand( "mapvote_list_maps" )
end)
DR:AddChatCommandAlias("nominate", "maps")

function MV:SyncMapList()
	net.Start( "MapvoteUpdateMapList" )
	net.WriteTable( MV.MapList )
	net.Broadcast()
end

function MV:GetGoodMaps()
	-- get a list of maps
	local mapfiles = file.Find("maps/*.bsp", "GAME", "nameasc")

	-- cleanup the names
	for i = 1, #mapfiles do
		mapfiles[i] = string.sub( mapfiles[i], 1, -5 )
	end

	-- remove files that don't have the right prefix
	local goodmaps = {}
	for k,map in ipairs( mapfiles ) do
		for _, filter in ipairs( MV.Filter ) do
			local length = string.len( filter )
			local mapname = string.sub( map, 1, length )

			if mapname == filter then
				if not table.HasValue( goodmaps, map ) then -- ignore duplicates
					table.insert(goodmaps, map)
				end
			end
		end
	end

	return goodmaps
end

function MV:UpdateMapVote()

	net.Start("MapvoteUpdateMapList")
	net.WriteTable( MV.MapList )
	net.Broadcast()
end

function MV:BeginMapVote() -- initiates the mapvote, and syncs the maps once

	mapfiles = MV:GetGoodMaps()

	-- populate the maplist
	MV.MapList = {}

	for i = 1, MV.MaxMaps do -- add nominations
		if MV.Nominations[i] then
			MV.MapList[ MV.Nominations[i] ] = 0
		end
	end

	--print(#MV.MapList, MV.MaxMaps, #mapfiles)
	local totalloops = 0
	local numMaps = 0
	for k,v in pairs(MV.MapList) do 
		numMaps = numMaps + 1 
	end
	while numMaps < MV.MaxMaps and totalloops < 200 and #mapfiles > 0 do

		local r =  math.random( #mapfiles )
		local randmap = mapfiles[r]
		MV.MapList[ randmap ] = 0

		table.remove( mapfiles, r )

		totalloops = totalloops + 1

		numMaps = 0
		for k,v in pairs(MV.MapList) do 
			numMaps = numMaps + 1 
		end
	end

	numMaps = 0
	for k,v in pairs(MV.MapList) do 
		numMaps = numMaps + 1 
	end

	--PrintTable( MV.MapList )

	net.Start("MapvoteSetActive")
	net.WriteBit( true )
	net.WriteTable( MV.MapList )
	net.WriteFloat( MV.VotingTime )
	net.Broadcast()

	MV.Active = true
	MV.TimeLeft = MV.VotingTime
end

function MV:StopMapVote()
	net.Start("MapvoteSetActive")
	net.WriteBit( false )
	net.WriteTable( {} )
	net.WriteFloat( 9999 )
	net.Broadcast()

	MV.Active = false
	MV.TimeLeft = 9999
end

function MV:FinishMapVote()
	MV.Active = false
	-- find winning map
	-- change to it

	local win = ""
	local winvotes = 0
	for k,v in pairs(MV.MapList) do
		if v > winvotes then
			winvotes = v
			win = k
		end
	end

	MV.VotingMapsNoVotes = {}
	local num = 0
	for k,v in pairs(MV.MapList) do
		num = num + 1
		table.insert(MV.VotingMapsNoVotes, k)
	end

	if win == "" then win = table.Random( MV.VotingMapsNoVotes ) end

	DR:ChatBroadcast("The next map will be "..win..". Map will change in 5 seconds.")

	local nextmap = win

	timer.Simple(5, function()
		DR:ChatBroadcast("Changing to the next map...")
		RunConsoleCommand("changelevel", nextmap)
	end)

end

timer.Create("MapvoteCountdownTimer", 0.2, 0, function()
	if MV.Active == true then
		MV.TimeLeft = MV.TimeLeft - 0.2
		if MV.TimeLeft < 0 then
			MV:FinishMapVote()
		end
	end
end)

concommand.Add("mapvote_begin_mapvote", function(ply, cmd, args)

	local cont = false
	if IsValid( ply ) then
		if ply:IsAdmin() then
			cont = true
		end
	else
		cont = true
	end

	if not hook.Call("DeathrunStartMapvote", nil, ROUND:GetRoundsPlayed()) then
		MV:BeginMapVote()
	end

end)

concommand.Add("mapvote_vote", function(ply, cmd, args)
	if MV.Active == false then return end
	if args[1] and IsValid( ply ) then
		vot = args[1]
		MV.Players[ ply:SteamID() ] = vot

		for k,v in pairs( MV.MapList ) do
			MV.MapList[k] = 0
		end
		for k,v in pairs( MV.Players ) do
			MV.MapList[v] = (MV.MapList[v] or 0) + 1
		end

		MV:UpdateMapVote()
	else
		if IsValid(ply) then
			ply:DeathrunChatPrint("Please specify a map.")
		end
	end
end)

concommand.Add("mapvote_nominate_map", function(ply, cmd, args)

	if args[1] then
		nom = args[1]

		print(nom, game.GetMap())

		if nom == game.GetMap() then
			ply:DeathrunChatPrint("You can't nominate the map you are currently playing.")
			return
		end

		MV.PlayerNominations[ ply:SteamID() ] = nom

		MV.Nominations = {}
		for k,v in pairs( MV.PlayerNominations ) do
			if not table.HasValue( MV.Nominations ) then
				table.insert( MV.Nominations, v )
			end
		end

		DR:ChatBroadcast(ply:Nick().." has nominated "..nom.." for the mapvote!")

		net.Start("MapvoteSyncNominations")
		net.WriteTable( MV.Nominations )
		net.Broadcast()
	end

end)

concommand.Add("mapvote_update_mapvote", function(ply, cmd, args)

	local cont = false
	if IsValid( ply ) then
		if ply:IsAdmin() then
			cont = true
		end
	else
		cont = true
	end

	MV:UpdateMapVote()

end)

-- RTV Features

local RTVRatio = CreateConVar("mapvote_rtv_ratio", 0.5, defaultFlags, "The ratio between votes and players in order to initiate a mapvote.")

function MV:CheckRTV( suppress )

	if MV.Active then return end

	if not suppress then
		if MV.LoadTime + 60 > CurTime() then
			DR:ChatBroadcast("It is too early to call an RTV.")
			return
		end
	end

	local votes = 0
	local numplayers = #player.GetAll()

	for k,v in ipairs(player.GetAll()) do
		v.WantsRTV = v.WantsRTV or false
		if v.WantsRTV == true then
			votes = votes + 1
		end
	end

	local ratio = votes/numplayers
	if ratio > RTVRatio:GetFloat() then
		if not hook.Call("DeathrunStartMapvote", nil, ROUND:GetRoundsPlayed()) then
			MV:BeginMapVote()
		end
		DR:ChatBroadcast("RTV limit reached. Initiating mapvote.")
	else

		local needed = math.ceil(RTVRatio:GetFloat() * numplayers) - votes + 1
		if not suppress then
			DR:ChatBroadcast(tostring(needed).." more votes needed in order to change the map. Type !rtv to vote.")
		end
	end

end

concommand.Add( "mapvote_rtv", function( ply )

	local suppress = ply.WantsRTV

	ply.WantsRTV = true

	MV:CheckRTV( suppress )

end)

DR:AddChatCommand("rtv",function( ply )
	ply:ConCommand( "mapvote_rtv" )
end)

hook.Add("PlayerSay", "CheckRTVChat", function(ply, text, pub)
	local args = string.Split( text, " " )
	if #args == 1 then
		if args[1] == "rtv" then
			ply:ConCommand( "mapvote_rtv" )
		end
		if args[1] == "nominate" or args[1] == "maps" then
			ply:ConCommand( "mapvote_list_maps" )
		end
	end
end)