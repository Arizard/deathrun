local buttons = {}
local claim_radius = 75 -- if you can knife it, you can claim it.

if SERVER then
	util.AddNetworkString("UpdateButtonClaims")

	local function UpdateButtonClaims()

		net.Start("UpdateButtonClaims")
		net.WriteTable( buttons )
		net.Broadcast()

	end

	local function CheckButtonClaims()
		local but_ents = ents.FindByClass("func_button")
		local but_ids = {}
		local players = {}
		local buttonswerechanged = false

		for k,v in ipairs( player.GetAllPlaying() ) do
			if v:Alive() and v:Team() == TEAM_DEATH then -- get living death players
				table.insert( players, v )
			end
		end

		--compile all the button entities into the table buttons
		for k,v in ipairs( but_ents ) do
			if not buttons[ v:MapCreationID() ] then
				buttons[ v:MapCreationID() ] = {
					claimed = false,
					claimedPlayer = "null",
					pos = v:GetPos() + v:OBBCenter()
				}
			else
				local pos = buttons[ v:MapCreationID() ].pos
				local closestDist = 10000000
				local closestPlayer = nil

				for _,ply in ipairs( players ) do
					local dist = ply:EyePos():Distance( pos )

					if dist < closestDist then
						closestDist = dist
						closestPlayer = ply
					end
				end

				local currentClaimPly = nil
				for _,ply in ipairs(team.GetPlayers(TEAM_DEATH)) do
						if ply:SteamID() == buttons[ v:MapCreationID() ].claimedPlayer then
							currentClaimPly = ply
						end
				end

				local currentClaimPlyDist = 99999
				if currentClaimPly then
					currentClaimPlyDist = currentClaimPly:EyePos():Distance(pos)
				end

				if closestDist < claim_radius and buttons[ v:MapCreationID() ].claimed == false then -- someone within claiming distance, and the button is unclaimed
					buttons[ v:MapCreationID() ].claimed = true
					buttons[ v:MapCreationID() ].claimedPlayer = closestPlayer:SteamID()
					buttonswerechanged = true
				elseif ( currentClaimPlyDist > claim_radius ) and buttons[ v:MapCreationID() ].claimed == true then
					buttons[ v:MapCreationID() ].claimed = false -- nobody within claiming distance
					buttons[ v:MapCreationID() ].claimedPlayer = "null"
					buttonswerechanged = true
				end
				
			end
		end

		if buttonswerechanged then -- only update the buttons when something changes! this saves bandwidth.
			UpdateButtonClaims()
		end
	end
	timer.Create("CheckButtonClaims", 0.35, 0, function()
		
		CheckButtonClaims()

	end)

	local function PlayerCanButton( ply, ent )
		if not ply:Alive() or ply:Team() == TEAM_SPECTATOR or ply:GetObserverMode() ~= OBS_MODE_NONE then
			return false 
		end

		local mid = ent:MapCreationID()
		local sid = ply:SteamID()

		if ply:Team() == TEAM_RUNNER then 
			if ent:GetSaveTable().m_toggle_state == 1 and not ent:GetSaveTable().m_bLocked and ply:KeyPressed( IN_USE ) then
				hook.Call("DeathrunButtonActivated", nil, ply, ent)
			end

			ent.User = ply
			return
		end -- to stop secrets breaking

		if not buttons[ mid ] then 
			if ent:GetSaveTable().m_toggle_state == 1 and not ent:GetSaveTable().m_bLocked and ply:KeyPressed( IN_USE ) then
				hook.Call("DeathrunButtonActivated", nil, ply, ent)
			end

			ent.User = ply
			return
		end -- if that shit doesnt exist then sure, just do it, don't let your dreams be dreams

		if buttons[ mid ].claimedPlayer == sid or buttons[ mid ].claimed == false then -- if they own it, or if it is unclaimed (e.g. they run and press it the moment before it updates on the server, it won't disable and it wont cause them to lose the runner.)
			if ent:GetSaveTable().m_toggle_state == 1 and not ent:GetSaveTable().m_bLocked and ply:KeyPressed( IN_USE ) then
				hook.Call("DeathrunButtonActivated", nil, ply, ent)
			end

			ent.User = ply
			return
		else
			return false
		end
	end
	hook.Add("PlayerUse", "DeathrunButtonClaimPlayerUse", PlayerCanButton )

end

if CLIENT then 

	net.Receive("UpdateButtonClaims", function()

		buttons = net.ReadTable()



	end)


	hook.Add("HUDPaint", "DeathrunButtonClaimHUD", function()
		if LocalPlayer():Team() == TEAM_RUNNER then return end
		for k,v in pairs( buttons ) do
			local dist = v.pos:Distance( LocalPlayer():EyePos() )
			if dist < claim_radius*3 then

				local alpha = 255

				if dist > claim_radius then
					alpha = Lerp( InverseLerp( dist, claim_radius, claim_radius*3 ), 255, 0 )
				end

				local x,y = v.pos:ToScreen().x, v.pos:ToScreen().y

				local claimtext = "Unclaimed"

				for _,ply in ipairs( team.GetPlayers(TEAM_DEATH) ) do
					if ply:SteamID() == v.claimedPlayer then
						claimtext = "Claimed by "..ply:Nick()
					end
				end
				draw.SimpleText( claimtext , "deathrun_derma_Tiny", x, y, Color(v.claimed and 255 or 100, (not v.claimed) and 255 or 100,100, alpha), TEXT_ALIGN_CENTER )
			end
		end
	end)

end
