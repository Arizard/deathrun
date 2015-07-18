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

include( "zones/sh_zone.lua" )
include( "zones/cl_zone.lua" )

include( "cl_hud.lua" )
include( "cl_menus.lua" )

include( "sh_buttonclaiming.lua" )

include( "cl_announcer.lua" )

include( "sh_pointshopsupport.lua" )

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

-- thirdperson support -- from arizard_thirdperson.lua
if CLIENT then
	local ThirdpersonOn = CreateClientConVar("deathrun_thirdperson_enabled", 0, true, false)
	local ThirdpersonX = CreateClientConVar("deathrun_thirdperson_offset_x", 0, true, false)
	local ThirdpersonY = CreateClientConVar("deathrun_thirdperson_offset_y", 0, true, false)
	local ThirdpersonZ = CreateClientConVar("deathrun_thirdperson_offset_z", 0, true, false)

	local function CalcViewThirdPerson( ply, pos, ang, fov, nearz, farz )

		if ThirdpersonOn:GetBool() == true and ply:Alive() and (ply:Team() ~= TEAM_SPECTATOR) then
			local view = {}

			local newpos = Vector(0,0,0)
			local dist = 100 + ThirdpersonZ:GetFloat()

			local tr = util.TraceHull(
				{
				start = pos, 
				endpos = pos + ang:Forward()*-dist + Vector(0,0,9) + ang:Right() * ThirdpersonX:GetFloat() + ang:Up() * ThirdpersonY:GetFloat(),
				mins = Vector(-5,-5,-5),
				maxs = Vector(5,5,5),
				filter = player.GetAll(),
				mask = MASK_SHOT_HULL
				
			})

			newpos = tr.HitPos
			view.origin = newpos
			view.angles = ang
			view.fov = fov

			-- test for thirdperson scoped weapons
			local wep = ply:GetActiveWeapon()
			if wep then
				if wep.Scope then
					if wep:GetIronsights() == true then
						view.fov = wep.ScopedFOV or fov
					end
				end
			end

			--print( tracedist )

			return view
		end

	end
	hook.Add("CalcView", "deathrun_thirdperson_script", CalcViewThirdPerson )

	local function DrawLocalPlayerThirdPerson()
		local ply = LocalPlayer()
		if ThirdpersonOn:GetBool() == true and ply:Alive() and (ply:Team() ~= TEAM_SPECTATOR) then
			return true
		end
	end
	hook.Add("ShouldDrawLocalPlayer", "deathrun_thirdperson_script", DrawLocalPlayerThirdPerson)
else

end

concommand.Add("+menu", function(ply)
	RunConsoleCommand("deathrun_not_amused")
end)

concommand.Add("deathrun_toggle_thirdperson", function(ply)
	if GetConVarNumber("deathrun_thirdperson_enabled") == 0 then
		ply:ConCommand("deathrun_thirdperson_enabled 1")
	else
		ply:ConCommand("deathrun_thirdperson_enabled 0")
	end
end)

hook.Add("CreateMove",'CheckClientsideKeyBinds', function()
	local ply = LocalPlayer()
	if input.WasKeyPressed(KEY_F8) then
		ply:ConCommand("deathrun_toggle_thirdperson")
	end

end)

hook.Add("PrePlayerDraw", "TransparencyPlayers", function( ply )

	if ply:GetRenderMode() ~= RENDERMODE_TRANSALPHA then
		ply:SetRenderMode( RENDERMODE_TRANSALPHA )
	end

	local fadedistance = 75

	local eyedist = LocalPlayer():EyePos():Distance( ply:EyePos() )

	if eyedist < fadedistance then
		local frac = InverseLerp( eyedist, 5, fadedistance )
		local col = ply:GetColor()
		col.a = Lerp( frac, 5, 255 )

		if ply:Team() ~= LocalPlayer():Team() then col.a = 255 end

		ply:SetColor( col )
	end

end)