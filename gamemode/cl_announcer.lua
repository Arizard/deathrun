local msgs = {}

timer.Create("UpdateDeathrunAnnouncements", 1,0, function() -- when convars change

	msgs = {
		"You're playing on "..GetHostName()..", enjoy your stay!",
		"Don't hesitate to ask the staff any questions, they are here to help.",
		"Type !rtv to force a mapchange.",
		"Type !crosshair to customize your crosshair settings and achieve different designs.",
		"Type !help or press F1 for help and information about the gamemode.",
		"Change the position of the HUD by pressing F2 or typing !settings.",
		"Change how long player names stay on the screen by pressing F2 or typing !settings.",
		"Buttons are claimed automatically. Just walk up to them!",
		"Did you know the weapons have recoil patterns? Pull down gently to concentrate your spray!",
		"Too many squeakers? Mute players from the scoreboard by holding TAB.",
		"Disable these messages through the !settings menu or by pressing F2.",
		"Enable Thirdperson, disable Autojump, change HUD position and more by pressing F2.",
		"Change your HUD them in the F2 menu.",
		"Disconnecting while on the Death team is not allowed and will be considered death avoidance. You will be forced to play "..tostring( GetConVar("deathrun_death_avoid_punishment"):GetInt() ).." extra rounds as Death.",
	}

end)

local AnnouncementInterval = CreateClientConVar("deathrun_announcement_interval", 60, true, false)
local AnnouncementEnabled = CreateClientConVar("deathrun_enable_announcements", 1, true, false)

local idx = 1

local function DoAnnouncements()
	if AnnouncementEnabled:GetBool() == false then return end

	chat.AddText(DR.Colors.Clouds, "[", DR.Colors.Alizarin, "HELP", DR.Colors.Clouds, "] "..(msgs[idx]))
	idx = idx + 1
	if idx > #msgs then idx = 1 end
end

cvars.AddChangeCallback( "deathrun_announcement_interval", function( name, old, new )
	timer.Destroy("DeathrunAnnouncementTimer")
	timer.Create("DeathrunAnnouncementTimer", new, 0, function()
		DoAnnouncements()
	end)
end, "DeathrunAnnouncementInterval")

timer.Create("DeathrunAnnouncementTimer", AnnouncementInterval:GetFloat(), 0, function()
	DoAnnouncements()
end)