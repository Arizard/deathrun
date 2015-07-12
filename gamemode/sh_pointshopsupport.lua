print("Loaded pointshop support...")

local hasPointshop = false
local hasPointshop2 = false
local hadRedactedHub = false

if PS then
	hasPointshop = true 
end
if RS then
	hasRedactedHub = true 
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
		if hasRedactedHub then
			local amt = PointshopReward:GetInt()
			local storemoney = RS:GetStoreMoney() or 0
			if amt <= storemoney then
				ply:AddMoney( amt )
				RS:SubStoreMoney( amt )
				ply:DeathrunChatPrint("You were given "..tostring( amt ).." points for finishing the map!")
			else
				ply:DeathrunChatPrint("You finished the map, but unfortunately the store does not have enough points to reward you.")
			end			
		end
	end)
end