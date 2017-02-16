-- zone format
-- table containing the following
-- name (unique identifier)
-- corner1
-- corner2
-- color
-- type <start|end>

ZONE = ZONE or {} -- global table

ZONE.ZoneTypes = {
	"start",
	"end",
	"deny_team_death",
	"deny_team_runner",
	"deny",
	"custom1",
	"custom2",
	"custom3",
	"barrier",
}

function VectorMinMax( vec1, vec2 )
	local min = Vector(0,0,0)
	local max = Vector(0,0,0)

	if vec1.x > vec2.x then
		max.x = vec1.x
		min.x = vec2.x
	else
		max.x = vec2.x
		min.x = vec1.x
	end

	if vec1.y > vec2.y then
		max.y = vec1.y
		min.y = vec2.y
	else
		max.y = vec2.y
		min.y = vec1.y
	end

	if vec1.z > vec2.z then
		max.z = vec1.z
		min.z = vec2.z
	else
		max.z = vec2.z
		min.z = vec1.z
	end

	return min, max

end

function VectorInCuboid( pos, min, max ) -- check if vector is within cuboid
	local min, max = VectorMinMax( min, max ) -- get the min and max of the two corners
	if (pos.x > min.x and pos.x < max.x) and (pos.y > min.y and pos.y < max.y) and (pos.z > min.z and pos.z < max.z) then
		return true
	else
		return false
	end
end

function PlayerInCuboid( ply, min, max ) -- check if vector is within cuboid
	local plymin, plymax = ply:GetPos() + ply:OBBMins(), ply:GetPos() + ply:OBBMaxs()
	if VectorInCuboid( ply:GetPos() + Vector(0,0,50), min, max ) then
		return true
	end
	return CuboidOverlap( plymin, plymax, min, max )
end

function CuboidOverlap( min1, max1, min2, max2 )
	local min1, max1 = VectorMinMax( min1, max1 )
	local min2, max2 = VectorMinMax( min2, max2 )

	if (
		((min1.x <= min2.x and min2.x <= max1.x) or (min2.x <= min1.x and min1.x <= max2.x)) and
		((min1.y <= min2.y and min2.y <= max1.y) or (min2.y <= min1.y and min1.y <= max2.y)) and
		((min1.z <= min2.z and min2.z <= max1.z) or (min2.z <= min1.z and min1.z <= max2.z)) 
		) then
		return true 
		else return false
	end
end