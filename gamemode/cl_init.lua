include( "hexcolor.lua" )

include("config.lua")

include( "cl_derma.lua" )

include( "shared.lua" )

include( "cl_scoreboard.lua" )

include( "mapvote/sh_mapvote.lua" )
include( "mapvote/cl_mapvote.lua" )

include( "roundsystem/sh_round.lua" )
include( "roundsystem/cl_round.lua" )
include( "sh_definerounds.lua" )

include( "cl_hud.lua" )
include( "cl_menus.lua" )

include( "sh_buttonclaiming.lua" )

concommand.Add("dr_test_menu", function()
	local frame = vgui.Create("arizard_window")
	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Test Window Please Ignore")
end)

function DR:ChatMessage( msg )
	chat.AddText(DR.Colors.Clouds, "[", DR.Colors.Turq, "DEATHRUN", DR.Colors.Clouds, "] ",msg)
end

net.Receive("DeathrunChatMessage", function(len, ply)
	DR:ChatMessage( net.ReadString() )
end)

LocalPlayer().mutelist = LocalPlayer().mutelist or {}

net.Receive("DeathrunSyncMutelist", function(len, ply)
	LocalPlayer().mutelist = net.ReadTable()
end)

