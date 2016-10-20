print("Loading Scoreboard tags...")

DR.ScoreboardSpecialRanks = {}

function DR:SetScoreboardRankDisplay( rank, _icon, _col, _tag, _tag2 ) -- leave nil to use defaults
	DR.ScoreboardSpecialRanks[ rank ] = {
		icon = _icon or nil,
		col = _col or nil, 
		tag = _tag or nil,
		tag2 = _tag2 or rank,
	}
end

DR.ScoreboardSpecials = {}

function DR:SetScoreboardDisplay( sid, _icon, _col, _tag, _rank ) -- leave nil to use defaults
	DR.ScoreboardSpecials[ sid ] = {
		icon = _icon or nil,
		col = _col or nil, 
		tag = _tag or nil,
		rank = _rank or nil,
	}
end

-----------------------------------------------------------------
------------------------------CONFIG-----------------------------
-----------------------------------------------------------------

--For setting up a rank:
--DR:SetScoreboardRankDisplay( string rank, string icon, color, string tag1, string tag2 )

--Example:
DR:SetScoreboardRankDisplay( "user",          nil,           nil,           nil,           "User")



--For setting up a player:
--DR:SetScoreboardDisplay( string steamid, string icon, color, string title, string rank)

DR:SetScoreboardDisplay( "STEAM_0:1:30288855", 	"icon16/cup.png", 						Color(50,200,0), 		"Author", 										nil ) -- arizard
DR:SetScoreboardDisplay( "STEAM_0:0:29351088", 	"icon16/rainbow.png", 					Color( 200, 0, 0 ), 	"Worst Player", 								nil ) -- zelpa
DR:SetScoreboardDisplay( "STEAM_0:1:128126755", "icon16/drink.png",						Color(255,200,255), 	"Confirmed Grill",								nil ) -- krystal
DR:SetScoreboardDisplay( "STEAM_0:0:90710956",	"icon16/sport_shuttlecock.png",			HexColor( "#ef5682" ),	"CREEEEEEEEEED", 	                            nil ) -- tarkus
DR:SetScoreboardDisplay( "STEAM_0:1:147138529", "icon16/anchor.png",					HexColor( "#a66bbe" ),	"MEME MASTER",									nil ) -- kaay
DR:SetScoreboardDisplay( "STEAM_0:1:64432636",	"icon16/control_fastforward_blue.png",	HexColor( "#99ff33" ),	"Playboy Bunny",								nil ) -- gamefresh
DR:SetScoreboardDisplay( "STEAM_0:1:89220979",	"icon16/joystick.png",					HexColor( "#8cfaef" ),	"Neko Nation",									nil ) -- fich
DR:SetScoreboardDisplay( "STEAM_0:0:71992617",	"icon16/tux.png",						HexColor( "#8cfaef" ),	tostring( math.random(100) ).."% Unstable",		nil ) -- haina










--Don't touch anything beyond this point unless you wanna screw something up

--By Rank
hook.Add("GetScoreboardNameColor","ranks", function( ply )
	
	local rank = ply:GetUserGroup()
	local data = nil

	if DR.ScoreboardSpecialRanks[ rank ] then
		data = DR.ScoreboardSpecialRanks[ rank ]
	end

	if data then
		if data.col then
			return data.col
		end
	end

end)

hook.Add("GetScoreboardIcon","ranks 2: electric dootaloo", function( ply )
	
	local rank = ply:GetUserGroup()
	local data = nil

	if DR.ScoreboardSpecialRanks[ rank ] then
		data = DR.ScoreboardSpecialRanks[ rank ]
	end

	if data then
		if data.tag then
			return data.icon
		end
	end

end)

hook.Add("GetScoreboardTag", "ranks 3: this time it's personal", function( ply )
	
	local rank = ply:GetUserGroup()
	local data = nil

	if DR.ScoreboardSpecialRanks[ rank ] then
		data = DR.ScoreboardSpecialRanks[ rank ]
	end

	if data then
		if data.tag then
			return data.tag
		end
	end

end)

hook.Add("GetScoreboardRank", "ranks 4: a good day to meme hard", function( ply )
	
	local rank = ply:GetUserGroup()
	local data = nil

	if DR.ScoreboardSpecialRanks[ rank ] then
		data = DR.ScoreboardSpecialRanks[ rank ]
	end

	if data then
		if data.tag2 then
			return data.tag2
		end
	end

end)

--By Player

hook.Add("GetScoreboardNameColor","memes", function( ply ) -- do not remove or i kill u

	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end

	if data then
		if data.col then
			return data.col
		end
	end
end)

hook.Add("GetScoreboardIcon","memes 2: electric dootaloo", function( ply )

	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end

	if data then
		if data.icon then
			return data.icon
		end
	end

	if ply:IsAdmin() or ply:IsSuperAdmin() then
		return "icon16/shield.png"
	end
end)

hook.Add("GetScoreboardTag", "memes 3: this time it's personal", function( ply )

	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end

	if data then
		if data.tag then
			return data.tag
		end
	end
end)

hook.Add("GetScoreboardRank", "memes 4: a good day to meme hard", function( ply )
	local sid = ply:SteamID()
	local sid64 = ply:SteamID64()
	local data = nil

	if DR.ScoreboardSpecials[ sid ] then
		data = DR.ScoreboardSpecials[ sid ]
	elseif DR.ScoreboardSpecials[ sid64 ] then
		data = DR.ScoreboardSpecials[ sid64 ]
	end

	if data then
		if data.rank then
			return data.rank
		end
	end
end)
