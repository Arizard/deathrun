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
if Pointshop2 then
	hasPointshop2 = true
end

local PointshopFinishReward = CreateConVar("deathrun_pointshop_finish_reward", 10, FCVAR_REPLICATED, "How many points to award the player when he finishes the map." )
local PointshopKillReward = CreateConVar("deathrun_pointshop_kill_reward", 5, FCVAR_REPLICATED, "How many points to award the player when they kill another player." )
local PointshopWinReward = CreateConVar("deathrun_pointshop_win_reward", 3, FCVAR_REPLICATED, "How many points to award the player when their team wins." )

if SERVER then

	function DR:RewardPlayer( ply, amt, reason )
		amt = amt or 0
		if hasPointshop then
			ply:PS_GivePoints( amt )
			ply:PS_Notify("You were given "..tostring( amt ).." points for "..(reason or "playing").."!")
		end
		if hasRedactedHub then
			local storemoney = RS:GetStoreMoney() or 0
			if amt <= storemoney then
				ply:AddMoney( amt )
				RS:SubStoreMoney( amt )
				ply:DeathrunChatPrint("You were given "..tostring( amt ).." points for "..(reason or "playing").."!")
			else
				ply:DeathrunChatPrint("Unfortunately the store does not have enough points to reward you.")
			end			
		end
		if hasPointshop2 then
			ply:PS2_AddStandardPoints( amt, "You were given "..tostring( amt ).." points for "..(reason or "playing").."!", true)
		end
	end


	hook.Add("DeathrunPlayerFinishMap", "PointshopRewards", function( ply, zname, z, place )
		DR:RewardPlayer( ply, PointshopFinishReward:GetInt(), "finishing the map")
	end)

	hook.Add("PlayerDeath", "PointshopRewards", function( ply, inflictor, attacker )
		if attacker:IsPlayer() then
			if ply:Team() ~= attacker:Team() then
				DR:RewardPlayer( attacker, PointshopKillReward:GetInt(), "killing "..ply:Nick())
			end
		end
	end)

	hook.Add("DeathrunRoundWin", "PointshopRewards", function( winner )
		for k,v in ipairs( player.GetAllPlaying() ) do
			if v:Team() == winner then
				DR:RewardPlayer( v, PointshopWinReward:GetInt(), "winning the round")
			end
		end
	end)
end