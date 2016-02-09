include("sh_zone.lua")

net.Receive("ZoneSendZones", function()
	ZONE.zones = net.ReadTable()
end)

local line_mat = Material("color.vmt")
function ZONE:DrawCuboid( pos1, pos2, col, alt )
	local pos1, pos2 = VectorMinMax( pos1, pos2 )

	col = Color(col.r, col.g, col.b, col.a )

	local points = {}
	points[1] = pos1
	points[7] = pos2

	points[2] = points[1] + ( Vector( pos2.x - pos1.x,0, 0) ) -- top level
	points[3] = points[2] + ( Vector( 0 ,pos2.y - pos1.y, 0) )
	points[4] = points[1] + ( Vector( 0 ,pos2.y - pos1.y, 0) )

	points[5] = points[1] + Vector( 0, 0, pos2.z - pos1.z)
	points[6] = points[5] + ( Vector( pos2.x - pos1.x,0, 0) )
	points[7] = points[6] + ( Vector( 0 ,pos2.y - pos1.y, 0) )
	points[8] = points[5] + ( Vector( 0 ,pos2.y - pos1.y, 0) )

	render.SetMaterial( line_mat )

	local width = 2

	render.DrawBeam( points[1], points[2], width, 1, 1, col )
	render.DrawBeam( points[2], points[3], width, 1, 1, col )
	render.DrawBeam( points[3], points[4], width, 1, 1, col )
	render.DrawBeam( points[4], points[1], width, 1, 1, col ) -- top level

	render.DrawBeam( points[5], points[6], width, 1, 1, col ) --bottom level
	render.DrawBeam( points[6], points[7], width, 1, 1, col )
	render.DrawBeam( points[7], points[8], width, 1, 1, col )
	render.DrawBeam( points[8], points[5], width, 1, 1, col )

	--Vertical connectors
	render.DrawBeam( points[1], points[5], width, 1, 1, col )
	render.DrawBeam( points[2], points[6], width, 1, 1, col )
	render.DrawBeam( points[3], points[7], width, 1, 1, col )
	render.DrawBeam( points[4], points[8], width, 1, 1, col )

	if alt then


		width = width/2 * (1+math.floor(CurTime()*4)%2)
		render.DrawBeam( points[1], points[3], width, 1, 1, col)
		render.DrawBeam( points[2], points[4], width, 1, 1, col)

		render.DrawBeam( points[1], points[6], width, 1, 1, col)
		render.DrawBeam( points[2], points[5], width, 1, 1, col)

		render.DrawBeam( points[4], points[7], width, 1, 1, col)
		render.DrawBeam( points[3], points[8], width, 1, 1, col)

		render.DrawBeam( points[3], points[6], width, 1, 1, col)
		render.DrawBeam( points[2], points[7], width, 1, 1, col)

		render.DrawBeam( points[1], points[8], width, 1, 1, col)
		render.DrawBeam( points[4], points[5], width, 1, 1, col)

		render.DrawBeam( points[5], points[7], width, 1, 1, col)
		render.DrawBeam( points[6], points[8], width, 1, 1, col)
	end

end

CreateClientConVar("deathrun_zones_visibility","1",true, false)

hook.Add("PostDrawTranslucentRenderables", "DeathrunZoneCuboidDrawing", function()
	for name, z in pairs( ZONE.zones or {} ) do
		if z.type then
			local center = 0.5*(z.pos1 + z.pos2)
			local dist = center:Distance( LocalPlayer():GetPos() )
			if dist < 1000 then
				if GetConVar("deathrun_zones_visibility"):GetBool() == true then
					local tempcolor = table.Copy( z.color )

					local frac = math.Clamp( InverseLerp( dist, 1000, 400 ), 0,1)
					tempcolor.a = frac*z.color.a

					local alt = false
					local ply = LocalPlayer()

					if z.type == "deny_team_runner" and ply:Team() == TEAM_RUNNER then
						alt = true
					end
					if z.type == "deny_team_death" and ply:Team() == TEAM_DEATH then
						alt = true
					end
					if z.type == "deny" then
						alt = true
					end

					ZONE:DrawCuboid( z.pos1, z.pos2, tempcolor, alt )

					--if string.sub( z.type, 1, 4 ) == "deny" then
						--ZONE:DrawCuboid( z.pos1, z.pos2, tempcolor, true )
					--end
				end
			end
		end
	end
end)