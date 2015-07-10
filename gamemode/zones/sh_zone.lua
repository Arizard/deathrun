-- zone format
-- table containing the following
-- name (unique identifier)
-- corner1
-- corner2
-- color
-- type <start|end>

ZONE = ZONE or {} -- global table

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