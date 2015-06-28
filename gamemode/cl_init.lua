include( "hexcolor.lua" )

include( "arizard_derma.lua" )

include( "shared.lua" )

include( "roundsystem/sh_round.lua" )
include( "roundsystem/cl_round.lua" )
include( "sh_definerounds.lua" )

concommand.Add("dr_test_menu", function()
	local frame = vgui.Create("arizard_window")
	frame:SetSize(640,480)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Test Window Please Ignore")
end)