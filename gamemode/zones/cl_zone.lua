include("sh_zone.lua")

local line_mat = Material("color.vmt")
function ZONE:DrawCuboid( pos1, pos2, col )
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
	render.DrawBeam( points[1], points[2], 5, 1, 1, col )
	render.DrawBeam( points[2], points[3], 5, 1, 1, col )
	render.DrawBeam( points[3], points[4], 5, 1, 1, col )
	render.DrawBeam( points[4], points[1], 5, 1, 1, col ) -- top level

	render.DrawBeam( points[5], points[6], 5, 1, 1, col ) --bottom level
	render.DrawBeam( points[6], points[7], 5, 1, 1, col )
	render.DrawBeam( points[7], points[8], 5, 1, 1, col )
	render.DrawBeam( points[8], points[5], 5, 1, 1, col )

	--Vertical connectors
	render.DrawBeam( points[1], points[5], 5, 1, 1, col )
	render.DrawBeam( points[2], points[6], 5, 1, 1, col )
	render.DrawBeam( points[3], points[7], 5, 1, 1, col )
	render.DrawBeam( points[4], points[8], 5, 1, 1, col )

end

hook.Add("PreDrawTranslucentRenderables", "DeathrunZoneCuboidDrawing", function()
	for name, z in pairs( ZONE.zones ) do
		ZONE:DrawCuboid( z.pos1, z.pos2, z.color )
	end
end)