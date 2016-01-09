if SERVER then
	for k,v in ipairs( file.Find("gamemode/mapsettings/*.lua", "LUA") ) do
		AddCSLuaFile("mapsettings/"..v)
	end
end

hook.Add("InitPostEntity", "MapSettings", function()
	include("mapsettings/"..game.GetMap()..".lua")
end)