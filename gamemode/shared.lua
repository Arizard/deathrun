GM.Name 	= "Deathrun"
GM.Author 	= "Arizard"
GM.Email 	= ""
GM.Website 	= "arizard.github.io"

function GM:Initialize()

	self.BaseClass.Initialize( self )
	
end

TEAM_RUNNER = 2
TEAM_DEATH = 3

function GM:CreateTeams()
	team.SetUp(TEAM_RUNNER, "Runners", DR.Colors.RunnerTeam, false)
	team.SetUp(TEAM_DEATH, "Deaths", DR.Colors.DeathTeam, false)

	team.SetSpawnPoint( TEAM_DEATH, "info_player_terrorist" )
	team.SetSpawnPoint( TEAM_RUNNER, "info_player_counterterrorist" )

	team.SetColor( TEAM_SPECTATOR, DR.Colors.Silver )
end

function player.GetAllPlaying()
	local pool = {}
	for k,ply in ipairs(player.GetAll()) do
		if ply then
			if not ply:ShouldStaySpectating() then
				table.insert(pool, ply)
			end
		end
	end
	return pool
end

hook.Add("SetupMove", "DeathrunDisableSpectatorSpacebar", function( ply, mv, cmd )
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )
	end

	if ply:Alive() then
		if ROUND:GetCurrent() == ROUND_PREP then
			--mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )
			mv:SetSideSpeed( 0 )
			mv:SetUpSpeed( 0 )
			mv:SetForwardSpeed( 0 )
		end
	end
end)

function QuadLerp( frac, p1, p2 )

    local y = (p1-p2) * (frac -1)^2 + p2
    return y

end

function InverseLerp( pos, p1, p2 )

	local range = 0
	range = p2-p1

	if range == 0 then return 1 end

	return ((pos - p1)/range)

end

-- I uh... borrowed this from Gravious. I need it but I don't know why.

local lp, ft, ct, cap = LocalPlayer, FrameTime, CurTime
local mc, mr, bn, ba, bo = math.Clamp, math.Round, bit.bnot, bit.band, bit.bor
function GM:Move( ply, data )
	if not IsValid( ply ) then return end
	if lp and ply != lp() then return end
	
	if ply:IsOnGround() or not ply:Alive() then return end
	
	local aim = data:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fmove = data:GetForwardSpeed()
	local smove = data:GetSideSpeed()
	
	if data:KeyDown( IN_MOVERIGHT ) then smove = smove + 500 end
	if data:KeyDown( IN_MOVELEFT ) then smove = smove - 500 end
	
	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()

	local wishvel = forward * fmove + right * smove
	wishvel.z = 0

	local wishspeed = wishvel:Length()
	if wishspeed > data:GetMaxSpeed() then
		wishvel = wishvel * (data:GetMaxSpeed() / wishspeed)
		wishspeed = data:GetMaxSpeed()
	end

	local wishspd = wishspeed
	wishspd = mc( wishspd, 0, 30 )

	local wishdir = wishvel:GetNormal()
	local current = data:GetVelocity():Dot( wishdir )

	local addspeed = wishspd - current
	if addspeed <= 0 then return end

	local accelspeed = 50 * ft() * wishspeed
	if accelspeed > addspeed then
		accelspeed = addspeed
	end
	
	local vel = data:GetVelocity()
	vel = vel + (wishdir * accelspeed)
	
	if ply.SpeedCap and vel:Length2D() > ply.SpeedCap then
		local diff = vel:Length2D() - ply.SpeedCap
		vel:Sub( Vector( vel.x > 0 and diff or -diff, vel.y > 0 and diff or -diff, 0 ) )
	end
	
	data:SetVelocity( vel )
	return false
end

local function AutoHop( ply, data )
	if lp and ply != lp() then return end
	
	local ButtonData = data:GetButtons()
	if ba( ButtonData, IN_JUMP ) > 0 then
		if ply:WaterLevel() < 2 and ply:GetMoveType() != MOVETYPE_LADDER and not ply:IsOnGround() then
			data:SetButtons( ba( ButtonData, bn( IN_JUMP ) ) )
		end
	end
end
hook.Add( "SetupMove", "AutoHop", AutoHop )