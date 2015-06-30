print("Loaded cl_hud.lua")

local HideElements = {
	["CHudBattery"] = true,
	["CHudCrosshair"] = true,
	["CHudHealth"] = true
}

function GM:HUDShouldDraw( el )
	if HideElements[ el ] then
		return false
	else
		return true
	end
end
