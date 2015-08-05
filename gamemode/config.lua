print("Loading Config...")

DR = DR or {}

print("Creating global table DR...")

DR.Colors = {
	DeathTeam = HexColor( "#F26C4F" ),
	RunnerTeam = HexColor( "#3A89C9" ),
	Clouds = HexColor("#E9F2F9"),
	Silver = HexColor("#bdc3c7"),
	Concrete = HexColor("#95a5a6"),
	Alizarin = HexColor("#e74c3c"),
	Peter = HexColor("#3498db"),
	Turq = HexColor("#1abc9c"),
	DarkBlue = HexColor("#1B325F"),
	LightBlue = HexColor("#9CC4E4"),
	Sunflower = HexColor("#f1c40f"),
	Orange = HexColor("#f39c12")
}

DR.AirAccelerate = 1000

--[[

	ANNOUNCER

	To change the appearance of the announcer ( [HELP] Messages ) use the following two functions ON THE CLIENT:

	DR:SetAnnouncerName( STRING name ) -- sets the name, default is "HELP"
	DR:SetAnnouncerColor( COLOR col ) -- sets the color of the announcer name, default is DR.Colors.Alizarin
	DR:SetAnnouncerTable( TABLE tbl ) -- sets the table of messages that the announcer broadcasts into player's chats.
	DR:GetAnnouncerTable( ) -- returns the table of messages that gets broadcasted so that you can make changes to it.
	DR:AddAnnouncement( STRING announcement ) -- Adds an announcement to the table of announcements that are broadcast by the announcer.

]]

--[[
	
	MOTD

	To change the MOTD behaviour, use the following functions ON THE CLIENT:

	DR:SetMOTDEnabled( BOOLEAN enabled ) -- False to disable globally, True to enable globally (clients can still disable for themselves using F2 menu )
	DR:SetMOTDTitle( STRING title ) -- Title of the MOTD Window
	DR:SetMOTDSize( NUMBER w, NUMBER h ) -- Size of the MOTD window
	DR:SetMOTDPage( STRING url ) -- the URL to open in the MOTD window, e.h. http://www.MyCommunityIsCool.com
	
]]