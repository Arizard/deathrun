include("sh_zone.lua")

function ZONE:Save()

	local map = game.GetMap()
	local path = "deathrun/zones/"..map..".txt"

	local json = util.TableToJSON( ZONE.zones )
	file.Write( path, json )

	print("Zones were saved.")

end

function ZONE:Load()

	local map = game.GetMap()
	local path = "deathrun/zones/"..map..".txt"

	if not file.Exists("deathrun", "DATA") then
		file.CreateDir("deathrun")
	end

	if not file.Exists("deathrun/zones", "DATA") then
		file.CreateDir("deathrun/zones")
	end

	if not file.Exists( path ) then
		file.Write( path, "{}" )
	end

	local json = file.Read(path,"DATA")
	local tab = util.JSONToTable( json ) or {}

	ZONE.zones = table.Copy( tab )

	print("Zones were loaded.")

end

ZONE:Load()

function ZONE:Create( name, pos1, pos2, color, type )

	ZONE.zones[name] = {}

	ZONE.zones[name].pos1 = pos1
	ZONE.zones[name].pos2 = pos2
	ZONE.zones[name].color = color
	ZONE.zones[name].type = type

	ZONE:Save()

end

function ZONE:Tick() -- cycle through zones and check for players

	for name, z in pairs( ZONE.zones ) do
		for k, ply in ipairs(player.GetAll()) do

			-- create a bunch of variables on the player
			ply.InZones = ply.InZones or {}

			if not table.HasValue(ply.InZones, name) then
				if VectorInCuboid( ply:EyePos(), z.pos1, z.pos2 ) then -- if we don't remember them being inside, but they are inside, then they mustve just entered the zone.
					table.insert(ply.InZones, name)
					hook.Call("DeathrunPlayerEnteredZone", nil, ply, z.type, z.name)
				end
			else
				if not VectorInCuboid( ply:EyePos(), z.pos1, z.pos2 ) then -- if we remember them being inside, but they arent anymore, then they left.
					table.RemoveByValue(ply.InZones, name)
					hook.Call("DeathrunPlayerExitedZone", nil, ply, z.type, z.name)
				end
			end
		end
	end

end

util.AddNetworkString("ZoneSendZones")
function ZONE:SendZones( ply )
	net.Start("ZoneSendZones")
	net.WriteTable( ZONE.zones )
	net.Send( ply )
end

function ZONE:BroadcastZones()
	net.Start("ZoneSendZones")
	net.WriteTable( ZONE.zones )
	net.Broadcast()
end

hook.Add("PlayerInitialSpawn", "ZoneSendZonesInitialSpawn", function( ply )
	ZONE:SendZones( ply )
	print("Sent zones to player "..ply:Nick())
end)

hook.Add("DeathrunPlayerEnteredZone", "Testing", function(ply, ty, name)
	print("Player "..ply:Nick().." entered zone "..name.." of type "..ty)
end)

-- add some concommands for creating zones
concommand.Add("zone_create", function(ply, cmd, args) -- e.g. zone_create endmap end
	if DR:GeneralAdminAccess( ply ) and #args == 2 then
		ZONE:Create(args[1], Vector(0,0,0), Vector(0,0,0), Color(255,255,255), args[2])
		DR:SafeChatPrint( ply, "Created zone '"..args[1].."'' of type '"..args[2].."'")
	end
end)
DR:AddChatCommand("createzone", function(ply, args)
	ply:ConCommand("zone_create "..args[1].." "..args[2] )
end)

concommand.Add("zone_setpos1", function(ply, cmd, args)
	if DR:GeneralAdminAccess( ply ) and #args == 2 then
		if args[2] == "eyetrace" and IsValid( ply ) then
			if ZONE.zones[args[1]] then
				ZONE.zones[args[1]].pos1 = ply:GetEyeTrace().HitPos
				ZONE:BroadcastZones()
				ZONE:Save()
			else
				DR:SafeChatPrint( ply "Zone does not exist.")
			end
		else
			DR:SafeChatPrint("Please use eyetrace.")
		end
	end
end)
DR:AddChatCommand("setzonepos1", function(ply, args)
	ply:ConCommand("zone_setpos1 "..args[1].." "..args[2] )
end)



concommand.Add("zone_setpos2", function(ply, cmd, args)
	if DR:GeneralAdminAccess( ply ) and #args == 2 then
		if args[2] == "eyetrace" and IsValid( ply ) then
			if ZONE.zones[args[1]] then
				ZONE.zones[args[1]].pos2 = ply:GetEyeTrace().HitPos
				ZONE:BroadcastZones()
				ZONE:Save()
			else
				DR:SafeChatPrint( ply "Zone does not exist.")
			end
		else
			DR:SafeChatPrint("Please use eyetrace.")
		end
	end
end)
DR:AddChatCommand("setzonepos2", function(ply, args)
	ply:ConCommand("zone_setpos2 "..args[1].." "..args[2] )
end)

concommand.Add("zone_setcolor", function(ply, cmd, args) -- RGBA e.g. zone_setcolor endmap 255 0 0 255
	if DR:GeneralAdminAccess( ply ) and #args > 0 then
		if ZONE.zones[args[1]] then
			ZONE.zones[args[1]].color = Color( tonumber(args[2]) or 255, tonumber(args[3]) or 255, tonumber(args[4]) or 255, tonumber(args[5]) or 255 )
			ZONE:BroadcastZones()
			ZONE:Save()
		else
			DR:SafeChatPrint( ply "Zone does not exist.")
		end
	end
end)

DR:AddChatCommand("setzonecolor", function(ply, args)
	ply:ConCommand("zone_setcolor "..args[1].." "..args[2].." "..args[3].." "..args[4].." "..args[5] )
end)

concommand.Add("zone_settype", function(ply, cmd, args) -- e.g. zone_settype endmap end
	if DR:GeneralAdminAccess( ply ) and #args == 2 then
		if ZONE.zones[args[1]] then
			ZONE.zones[args[1]].type = args[2]
			ZONE:BroadcastZones()
			ZONE:Save()
		else
			DR:SafeChatPrint( ply "Zone does not exist.")
		end
	end
end)
DR:AddChatCommand("setzonetype", function(ply, args)
	ply:ConCommand("zone_settype "..args[1].." "..args[2] )
end)
