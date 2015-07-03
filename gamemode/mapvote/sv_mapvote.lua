include("sh_mapvote.lua")
util.AddNetworkString("MapvoteUpdateMapList")
util.AddNetworkString("MapvoteSetActive")

MV.MapList = {}
MV.Players = {} -- store each player's vote - {Player, Map}
MV.Nominations = {}

function MV:SyncMapList()
	net.Start( "MapvoteUpdateMapList" )
	net.WriteTable( MV.MapList )
	net.Broadcast()
end

function MV:BeginMapVote() -- initiates the mapvote, and syncs the maps once

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

	mapfiles = table.Copy( goodmaps )

	-- populate the maplist
	MV.MapList = {}

	for i = 1, MV.MaxMaps do -- add nominations
		if MV.Nominations[i] then
			MV.MapList[ MV.Nominations[i] ] = 0
		end
	end

	print(#MV.MapList, MV.MaxMaps, #mapfiles)
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

	--print("Total Loops:",totalloops, "NumMaps", numMaps)

	PrintTable( MV.MapList )

	-- for i = 1, MV.MaxMaps - #MV.MapList do -- fill the remaining slots
	-- 	if mapfiles[i] then
	-- 		MV.MapList[ mapfiles[i] ] = 0
	-- 	end
	-- end

	

	net.Start("MapvoteSetActive")
	net.WriteBit( true )
	net.WriteTable( MV.MapList )
	net.Broadcast()
end