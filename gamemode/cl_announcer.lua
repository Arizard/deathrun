local msgs = {}

timer.Create("UpdateDeathrunAnnouncements", 1,0, function() -- when convars change

	msgs = {
		"You're playing on "..GetHostName()..", enjoy your stay!",
		"Don't hesitate to ask the staff any questions, they are here to help.",
		"Using Autojump will result in your velocity being capped at "..tostring(GetConVar("deathrun_autojump_velocity_cap"):GetInt()).." u/s. Disable Autojump through the !settings menu.",
		"Round limit is currently "..tostring(GetConVar("deathrun_round_limit"):GetInt()).." rounds.",
		"Zelpa has the best memes.",
		"Type !rtv to force a mapchange.",
		"Type !crosshair to customize your crosshair settings and achieve different designs.",
		"Type !help for information about the gamemode.",
		"Change the position of the HUD in the !settings menu.",
		"Change how long player names stay on the screen in the !settings menu",
		"Buttons are claimed automatically. Just walk up to them.",
		"Did you know the weapons have recoil patterns? Pull down gently to concentrate your spray!",
		"Too many squeakers? Mute players from the scoreboard.",
		"Disable these messages through the !settings menu."
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