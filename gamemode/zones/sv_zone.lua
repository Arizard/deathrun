include("sh_zone.lua")

function ZONE:Save()

	local map = game.GetMap()
	local path = "deathrun/zones/"..map..".txt"

	local json = util.TableToJSON( self.zones )
	file.Write( path, json )

	print("Zones were saved.")

end

function ZONE:Load()

	local map = game.GetMap()
	local path = "deathrun/zones/"..map..".txt"

	if not file.Exists("deathrun/zones", "DATA") then
		file.CreateDir("deathrun/zones")
	end

	if not file.Exists( path, "DATA" ) then
		file.Write( path, "{}" )
	end

	local json = file.Read(path,"DATA")
	local tab = util.JSONToTable( json ) or {}

	self.zones = table.Copy( tab )

	print("Zones were loaded.")

end

ZONE:Load()

function ZONE:Create( name, pos1, pos2, color, type, force )

	if not istable(self.zones[name]) or next(self.zones[name]) == nil or force then -- empty table
		self.zones[name] = {}

		self.zones[name].pos1 = pos1
		self.zones[name].pos2 = pos2
		self.zones[name].color = color
		self.zones[name].type = type

		self:Save()

		return true
	end

	return false

end

function ZONE:ZoneData( name )
	return self.zones[name] or false
end

function ZONE:GetPlayerInZone( name )
	return ply.InZones and ply.InZones[name]
end

function ZONE:GetPlayerInZoneType( ply, t )
	for k,v in pairs( ply.InZones or {} ) do
		if self.zones[ k ] and v == true then
			if type(t) == "string" then
				if self.zones[ k ].type == t then
					return true
				end
			elseif type(t) == "table" then
				for _,j in ipairs( t ) do
					if self.zones[ k ].type == j then
						return true
					end
				end
			end
		end
	end
	return false
end

local skipcount = 0
local skip = 0
local tickrate = math.ceil( 1/engine.TickInterval() ) -- makes it a bit less taxing, at the cost of reducing the resolution of records

if tickrate >= 100 then
	skip = 2
elseif tickrate >= 66 then
	skip = 1
end

function ZONE:Tick() -- cycle through zones and check for players
	if skipcount == skip then
		for name, z in pairs( self.zones ) do
			if z.type then
				for k, ply in ipairs(player.GetAllPlaying()) do
					if ply:GetPos():Distance( (z.pos1 + z.pos2)/2 ) < z.pos1:Distance(z.pos2) * 0.6 then
						-- create a bunch of variables on the player
						ply.InZones = ply.InZones or {}

						if not ply.InZones[ name ] then
							if PlayerInCuboid( ply, z.pos1, z.pos2 ) then -- if we don't remember them being inside, but they are inside, then they mustve just entered the zone.
								ply.InZones[name] = true
								hook.Call("DeathrunPlayerEnteredZone", nil, ply, name, z)
								
							end
						else
							if not PlayerInCuboid( ply, z.pos1, z.pos2 ) then -- if we remember them being inside, but they arent anymore, then they left.
								ply.InZones[name] = false
								hook.Call("DeathrunPlayerExitedZone", nil, ply, name, z)
							end
						end

						if PlayerInCuboid( ply, z.pos1, z.pos2 ) then -- if we don't remember them being inside, but they are inside, then they mustve just entered the zone.
							hook.Call("DeathrunPlayerInsideZone", nil, ply, name, z)	
						end
					end
				end
			end
		end
		skipcount = 0
	else
		skipcount = skipcount + 1
	end
end

hook.Add("Tick", "ZoneTick", function() ZONE:Tick() end)

util.AddNetworkString("ZoneSendZones")
function ZONE:SendZones( ply )
	net.Start("ZoneSendZones")
	net.WriteTable( self.zones )
	net.Send( ply )
end

function ZONE:BroadcastZones()
	net.Start("ZoneSendZones")
	net.WriteTable( self.zones )
	net.Broadcast()
end

hook.Add("PlayerSpawn", "ZoneSendZonesSpawn", function( ply )
	ZONE:SendZones( ply )
	print("Sent zones to player "..ply:Nick())
end)

-- add some concommands for creating zones
concommand.Add("zone_create", function(ply, cmd, args) -- e.g. zone_create endmap end
	if DR:CanAccessCommand(ply, cmd) and #args == 2 then
		if ZONE:Create(args[1], Vector(0,0,0), Vector(0,0,0), Color(255,255,255), args[2], ply.LastZoneDenied == args[1]) then
			ZONE:BroadcastZones()
			DR:SafeChatPrint( ply, "Created zone '"..args[1].."' of type '"..args[2].."'")
			ply.LastZoneDenied = nil
		else
			DR:SafeChatPrint( ply, "There already exists a zone named '"..args[1].."'. Please delete it first!\nIf you wish to overwrite it run this command again")
			ply.LastZoneDenied = args[1]
		end
	end
end)
DR:AddChatCommand("createzone", function(ply, args)
	ply:ConCommand("zone_create "..(args[1] or "").." "..(args[2] or "") )
end)

concommand.Add("zone_remove", function(ply, cmd, args) -- e.g. zone_create endmap end
	if DR:CanAccessCommand(ply, cmd) and #args == 1 then
		ZONE.zones[args[1]] = nil
		ZONE:Save() 
		ZONE:BroadcastZones()
		DR:SafeChatPrint( ply, "Deleted zone '"..args[1].."'")
	end
end)
DR:AddChatCommand("removezone", function(ply, args)
	ply:ConCommand("zone_remove "..(args[1] or "") )
end)

concommand.Add("zone_setpos1", function(ply, cmd, args)
	if DR:CanAccessCommand(ply, cmd) and #args == 2 then
		if args[2] == "eyetrace" and IsValid( ply ) then
			if ZONE.zones[args[1]] then
				ZONE.zones[args[1]].pos1 = ply:GetEyeTrace().HitPos
				ZONE:BroadcastZones()
				ZONE:Save()
				DR:SafeChatPrint( ply, args[1]..".pos1 set to "..tostring( ZONE.zones[args[1]].pos1) )
			else
				DR:SafeChatPrint( ply, "Zone does not exist.")
			end
		else
			DR:SafeChatPrint( ply, "Please use eyetrace.")
		end
	end
end)
DR:AddChatCommand("setzonepos1", function(ply, args)
	ply:ConCommand("zone_setpos1 "..(args[1] or "").." "..(args[2] or "") )
end)



concommand.Add("zone_setpos2", function(ply, cmd, args)
	if DR:CanAccessCommand(ply, cmd) and #args == 2 then
		if args[2] == "eyetrace" and IsValid( ply ) then
			if ZONE.zones[args[1]] then
				ZONE.zones[args[1]].pos2 = ply:GetEyeTrace().HitPos
				ZONE:BroadcastZones()
				ZONE:Save()
				DR:SafeChatPrint( ply, args[1]..".pos2 set to "..tostring( ZONE.zones[args[1]].pos2) )
			else
				DR:SafeChatPrint( ply, "Zone does not exist.")
			end
		else
			DR:SafeChatPrint( ply, "Please use eyetrace.")
		end
	end
end)
DR:AddChatCommand("setzonepos2", function(ply, args)
	ply:ConCommand("zone_setpos2 "..(args[1] or "").." "..(args[2] or "") )
end)

concommand.Add("zone_setcolor", function(ply, cmd, args) -- RGBA e.g. zone_setcolor endmap 255 0 0 255
	if DR:CanAccessCommand(ply, cmd) and #args > 0 then
		if ZONE.zones[args[1]] then
			ZONE.zones[args[1]].color = Color( tonumber(args[2]) or 255, tonumber(args[3]) or 255, tonumber(args[4]) or 255, tonumber(args[5]) or 255 )
			ZONE:BroadcastZones()
			ZONE:Save()
			DR:SafeChatPrint( ply, args[1]..".color set to "..tostring( ZONE.zones[args[1]].color) )
		else
			DR:SafeChatPrint( ply, "Zone does not exist.")
		end
	end
end)

DR:AddChatCommand("setzonecolor", function(ply, args)
	ply:ConCommand("zone_setcolor "..(args[1] or "").." "..(args[2] or "").." "..(args[3] or "").." "..(args[4] or "").." "..(args[5] or "") )
end)

concommand.Add("zone_settype", function(ply, cmd, args) -- e.g. zone_settype endmap end
	if DR:CanAccessCommand(ply, cmd) and #args == 2 then
		if ZONE.zones[args[1]] then
			ZONE.zones[args[1]].type = args[2]
			ZONE:BroadcastZones()
			ZONE:Save()
			DR:SafeChatPrint( ply, args[1]..".type set to "..tostring( ZONE.zones[args[1]].type) )
		else
			DR:SafeChatPrint( ply, "Zone does not exist.")
		end
	end
end)
DR:AddChatCommand("setzonetype", function(ply, args)
	ply:ConCommand("zone_settype "..(args[1] or "").." "..(args[2] or "").." " )
end)


-- timing and rewards

local finishorder = {}
local function resetFinishers()
	for k, ply in ipairs(player.GetAll()) do
		ply.HasFinishedMap = false
	end
	finishorder = {}
end
resetFinishers()
hook.Add("DeathrunBeginActive", "DeathrunResetFinishers", resetFinishers)

ZONE.StartTime = nil

hook.Add("DeathrunBeginActive", "DeathrunResetZoneTimer", function()
	ZONE.StartTime = CurTime()
end)

local function denyZone( ply, name, z )

	if ply:Alive() and ply:GetObserverMode() == OBS_MODE_NONE then ply:Kill() end
	
end

hook.Add("DeathrunPlayerInsideZone", "DeathrunPlayerDenyZones", function(ply, name, z)
	if z.type == "deny_team_runner" and ply:Team() == TEAM_RUNNER then
		denyZone( ply, name, z )
		return
	end
	if z.type == "deny_team_death" and ply:Team() == TEAM_DEATH then
		denyZone( ply, name, z )
		return
	end
	if z.type == "deny" then
		denyZone( ply, name, z )
		return
	end
end)

-- hook.Add("Move", "DeathrunPlayerDenyZones", function( ply, cmd )
-- 	if ZONE:GetPlayerInZoneType( ply, {"deny", "deny_team_death", "deny_team_runner"} ) then
-- 		--cmd:SetMaxSpeed( 0 )
-- 		--cmd:SetMaxClientSpeed( 0 )
-- 	end
-- end)

hook.Add("DeathrunPlayerEnteredZone", "DeathrunPlayerFinishMap", function(ply, name, z)

	if string.sub( z.type, 1, 4 ) == "deny" then
		if not ply.DenyEntryList then
			ply.DenyEntryList = {}
		end
		ply.DenyEntryList[ name ] = ply:GetPos()
	end

	if (ply:Team() ~= TEAM_RUNNER) or ply:GetSpectate() or (not ply:Alive()) or ROUND:GetCurrent() == ROUND_WAITING then return end
	if z.type == "end" and ply.HasFinishedMap ~= true then
		table.insert( finishorder, ply )

		local place = #finishorder
		local placestring = tostring(place)
		local endchar = string.sub( placestring, -1, -1 )
		local end2char = string.sub( placestring, -1, -2 )
		local placetext = ""
		
		if end2char == "11" or end2char == "12" or end2char == "13" then
			placetext = placetext.."th"
		elseif endchar == "1" then
			placetext = placestring.."st"
		elseif endchar == "2" then
			placetext = placestring.."nd"
		elseif endchar == "3" then
			placetext = placestring.."rd"
		else
			placetext = placestring.."th"
		end

		
		for k,v in ipairs( team.GetPlayers( TEAM_DEATH ) ) do
			v:SetRunSpeed( 250 )
		end

		DR:ChatBroadcast(ply:Nick().." has finished the map in "..placetext.." place with a time of "..string.ToMinutesSecondsMilliseconds(CurTime() - ZONE.StartTime).."!")
		ply.HasFinishedMap = true

		for k,v in ipairs(team.GetPlayers( TEAM_DEATH )) do
			v:SetRunSpeed( v:GetWalkSpeed() ) -- deaths lose sprint when the runner finishes
		end

		hook.Call("DeathrunPlayerFinishMap", nil, ply, name, z, place, CurTime() - ZONE.StartTime)
	end
end)