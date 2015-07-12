print("Loaded pointshop support...")

local hasPointshop = false
local hasPointshop2 = false

if PS then
	hasPointshop = true 
end

if (false) then
	hasPointshop2 = true -- ask kamshak about this so i can add support
end

local PointshopReward = CreateConVar("deathrun_pointshop_reward", 10, FCVAR_REPLICATED, "How many points to award the player when he finishes the map." )

if SERVER then
	hook.Add("DeathrunPlayerFinishMap", "PointshopRewards", function( ply, zname, z, place )
		if hasPointshop then

			local amt = PointshopReward:GetInt()

			ply:PS_GivePoints( amt )
			ply:PS_Notify("You were given "..tostring( amt ).." points for finishing the map!")

		end
	end)
end