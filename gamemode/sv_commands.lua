print("Loading sv_commands.lua")

local function FindPlayersByName( nick ) -- returns a table of players with name matching nick

	if not nick then return {} end

	if nick == "*" then return player.GetAll() end
	if nick == "^" then return {} end

	local foundplayers = {}

	for _,ply in ipairs(player.GetAll()) do
		if string.find( string.lower(ply:Nick()), string.lower(nick) ) then
			table.insert( foundplayers, ply )
		end
	end

	return foundplayers

end

local function AdminAccess( ply ) -- accounts for when ply = console
	--if true then return true end
	if IsValid(ply) then
		return ply:IsSuperAdmin()
	else
		return true
	end
end

local function DeathrunSafeChatPrint( ply, msg )
	if IsValid( ply ) then
		ply:DeathrunChatPrint( msg )
	else
		MsgC(DR.Colors.Turq, msg.."\n")
	end
end

--console commands
concommand.Add("deathrun_respawn",function(ply, cmd, args)

	if args[1] then
		local targets = FindPlayersByName( args[1] )
		local cont = false

		if AdminAccess( ply ) then
			local players = ""
			if #targets > 0 then
				for k,targ in ipairs( targets ) do
					targ:KillSilent()
					targ:Spawn()

					players = players..targ:Nick()..", "

				end
			end

			DeathrunSafeChatPrint( ply, "Respawned "..string.sub(players,1,-3)..".")
		else
			DeathrunSafeChatPrint( ply, "You are not allowed to do that.")
		end
	
	elseif not args[1] then
		if AdminAccess( ply ) or ROUND:GetCurrent() == ROUND_WAITING then
			ply:KillSilent()
			ply:Spawn()

			DeathrunSafeChatPrint( ply, "Respawned yourself.")
		else
			DeathrunSafeChatPrint( ply, "You can't do that right now.")
		end
	else
		DeathrunSafeChatPrint( ply, "Could not execute command.")
	end

end, nil, nil, FCVAR_SERVER_CAN_EXECUTE )

concommand.Add("deathrun_cleanup",function(ply, cmd, args)

	
		if AdminAccess( ply ) or ROUND:GetCurrent() == ROUND_WAITING then
			game.CleanUpMap()
			DeathrunSafeChatPrint( ply, "Cleaned up the map and reset entities.")
		else
			DeathrunSafeChatPrint( ply, "You are not allowed to do that.")
		end


end, nil, nil, FCVAR_SERVER_CAN_EXECUTE )



-- chat commands

DR.ChatCommands = {}

function DR:AddChatCommand(cmd, func)
	DR.ChatCommands[cmd] = func
	print("Deathrun - Added chat command "..cmd)
end

function DR:AddChatCommandAlias(cmd, cmd2)
	DR.ChatCommands[cmd2] = DR.ChatCommands[cmd]
	print("Deathrun - Added chat command alias "..cmd.." -> "..cmd2)
end

local function ProcessChat( ply, text, public )

	local args = string.Split(text, " ")
	local prefix = string.sub(args[1],1,1)
	local cmd = string.sub(args[1], 2,-1)

	if ((prefix == "!") or (prefix == "/")) and DR.ChatCommands[ cmd ] then
		local cmdfunc = DR.ChatCommands[ cmd ]
		local args2 = {}
		for i = 2, #args do
			args2[i-1] = args[i]
		end

		cmdfunc( ply, args2 )
		if prefix == "/" then return false end -- make it silent if you use /
	end

end
hook.Add("PlayerSay","ProcessDeathrunChat",ProcessChat)

DR:AddChatCommand("respawn", function(ply, args)
	ply:ConCommand("deathrun_respawn "..(args[1] or ""))
	PrintTable( args )
end)
DR:AddChatCommandAlias("respawn", "r")

DR:AddChatCommand("cleanup", function(ply)
	ply:ConCommand("deathrun_cleanup")
end)
