GM.Name 	= "Deathrun"
GM.Author 	= "Arizard"
GM.Email 	= ""
GM.Website 	= "arizard.github.io"

function GM:Initialize()

	self.BaseClass.Initialize( self )
	
end

TEAM_RUNNER = 3
TEAM_DEATH = 2

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
			if ( ply:ShouldStaySpectating() == false ) then
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

			local block = hook.Call("DeathrunPreventPreptimeMovement") or true

			if block == true then
				mv:SetSideSpeed( 0 )
				mv:SetUpSpeed( 0 )
				mv:SetForwardSpeed( 0 )
			end
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

local function intToBool( i )
	if tonumber(i) == 0 then
		return false
	else
		return true
	end
end

if SERVER then
	concommand.Add("deathrun_internal_set_autojump", function(ply, cmd, args)
		if args[1] then
			ply.AutoJumpEnabled = intToBool( args[1] )
			--print("Player "..ply:Nick().." set their autojump convar to "..tostring(ply.AutoJumpEnabled))
		end
	end)
end

CreateConVar("deathrun_autojump_velocity_cap", 450, FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY, "The amount to limit players speed to when they use autojump. For game balance. 0 = unlimited")

if CLIENT then
	CreateClientConVar("deathrun_autojump", 1, true, false)
	cvars.AddChangeCallback("deathrun_autojump", function( name, old, new )
		RunConsoleCommand("deathrun_internal_set_autojump", tonumber(new))
		LocalPlayer().AutoJumpEnabled = intToBool( new )
	end, "DeathrunAutoJumpConVarChange")
	
	RunConsoleCommand("deathrun_internal_set_autojump", GetConVar("deathrun_autojump"):GetInt())
	timer.Create("DeathrunAutojumpSendToServer", 5, 0, function()
		RunConsoleCommand("deathrun_internal_set_autojump", GetConVar("deathrun_autojump"):GetInt()) -- in case some trickery happens on the client we'll sync this right up. They can probably destroy the timer but whatever
	end)
end

if CLIENT then
	CreateClientConVar("deathrun_spectate_only", 0, false, false)
	cvars.AddChangeCallback( "deathrun_spectate_only", function( name, old, new )
		RunConsoleCommand( "deathrun_set_spectate", new )
	end)
end

-- I uh... "borrowed" this from Gravious. I need it but I don't know why.

local lp, ft, ct, cap = LocalPlayer, FrameTime, CurTime
local mc, mr, bn, ba, bo = math.Clamp, math.Round, bit.bnot, bit.band, bit.bor
function GM:Move( ply, data )

	if not IsValid( ply ) then return end
	if lp and ply ~= lp() then return end
	
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

	if ply.AutoJumpEnabled == true and GetConVar("deathrun_allow_autojump"):GetBool() == true and GetConVar("deathrun_autojump_velocity_cap"):GetFloat() ~= 0 then
		ply.SpeedCap = GetConVar("deathrun_autojump_velocity_cap"):GetFloat()
	else
		ply.SpeedCap = 99999
	end

	
	if ply.SpeedCap and vel:Length2D() > ply.SpeedCap then
		local diff = vel:Length2D() - ply.SpeedCap
		vel:Sub( Vector( vel.x > 0 and diff or -diff, vel.y > 0 and diff or -diff, 0 ) )
	end
	
	data:SetVelocity( vel )
	return false
end

CreateConVar("deathrun_allow_autojump", 1, FCVAR_REPLICATED, "Allows players to use autojump.")

local function AutoHop( ply, data )
	
	if CLIENT then
		LocalPlayer().AutoJumpEnabled = intToBool( GetConVar("deathrun_autojump"):GetInt() )
	end

	if lp and ply ~= lp() then return end
	if ply.AutoJumpEnabled == false or GetConVar("deathrun_allow_autojump"):GetBool() == false then return end
	--print(ply.AutoJumpEnabled)
	
	local ButtonData = data:GetButtons()
	if ba( ButtonData, IN_JUMP ) > 0 then
		if ply:WaterLevel() < 2 and ply:GetMoveType() ~= MOVETYPE_LADDER and not ply:IsOnGround() then
			data:SetButtons( ba( ButtonData, bn( IN_JUMP ) ) )
		end
	end
end
hook.Add( "SetupMove", "AutoHop", AutoHop )

CreateConVar("deathrun_help_url", "https://github.com/Arizard/deathrun/blob/master/help.md", FCVAR_REPLICATED, "The URL to open when the player types !help.")