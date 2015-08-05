#Deathrun

##TODO

##Planned Features:

* ReDie - Allow players to spawn as ghosts so that they can practice the map instead of being forced to spectate.
* Evolve support for scoreboard (kick, ban, slay, gag)
* MORE HOOKS

##Separate stuff
* RTD
* Leveling/XP (hooks into starts/ends)

##Currently Implemented
* AFK / Idle kicker - configurable with convar ***deathrun_idle_kick_time <0-999>***
* Death Avoid Penalty - players who disconnect while on the Death team will be forced to play 1 extra rounds in a row as Death (configurable)
* Pointshop 1 & 2 support and RedactedHub support for map endings. Players are awarded a certain amount of points when finishing the map (map end is set up with !zones). Configure with **deathrun_pointshop_reward <0-9999>**
* Map start and end zones - To allow for timing and rewards. Specify two corners of a cuboid.
* ULX support for scoreboard
* F1 and F2 bound to Help and Settings
* Sound cues for round starts and round ends
* Many hooks
* Celebration screen when one team wins - List the team and the names of the winning players.
* Mapvote - Players can nominate maps to be voted for through the nomination menu. Players can rock the vote with !rtv if they don't like the current map. Ratio of votes:players can be customized with **mapvote_rtv_ratio <0-1>**. Players use the keys 1-9 to vote for maps.
* Weapons - CS:S Weapons are included by default and require no configuration (CS:S must be mounted on the server). They have predictable spray patterns so that experienced players can express their skill. 
* HUD - HUD Displays Health, Velocity, team and time left. HUD can be positions to one of 9 spots on the screen using **deathrun_hud_position <0-8>**, or through the !settings menu.
* Crosshairs - Customize your crosshair using the Crosshair Creator. Type !crosshair to open the crosshair creator menu.
* Singleplayer support - Open the gamemode up on a listen server or join an empty server, and you will be able to practice the map in godmode. The commands !respawn and !cleanup will allow you to respawn and reset the map, respectively.
* Chat commands - Developers can easily add chat commands as functions which are passed the variables ply (player who ran the command) and args (the arguments specified by the player).
* Autojump - Hold spacebar to automatically jump when you hit the ground. Toggleable through !settings. Players using autojump will experience a velocity cap of 450u/s. Bunnyhopping without autojump (disabling autojump) will bypass this restriction. Enable and disable autojump with !settings.
* Copy SteamID and mute players from within the scoreboard.
* Settings menu - change convars to your liking using !settings
* Help menu - type !help if you get stuck. Currently links to the github page, but this URL can be changed through a serverside convar.
* Button claiming - Walk up to a button to claim it, then nobody else will be able to press the button. Walk away and it will become unclaimed. Prevents button-stealing.
* Helpful announcements - The server will give tips to players online. Players can disable these or change how frequently they appear through the !settings menu.
* ULX Support on Scoreboard.

<video style="min-width: 20px; min-height: 20px; border: 1px solid #fff; box-shadow: 0 0 4px rgba( 0, 0, 0, 0.4 );" src="https://d.maxfile.ro/ipmzgxrrom.webm" controls="controls">Your browser doesn't support HTML 5 videos!</video>

#Grenade stuff from george
<pre>
george.: self:PhysicsInit( SOLID_VPHYSICS )
self:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE )
self:SetMoveType( MOVETYPE_VPHYSICS )
self:SetSolid( SOLID_VPHYSICS )
self:DrawShadow( false )
self:SetGravity( 0.4 )
self:SetElasticity( 0.45 )
self:SetFriction(0.2)

george.: for far throws im using
george.: phys:ApplyForceCenter(self.Owner:GetAimVector() * 750 + Vector(0,0,500))
george.: mainly from testing
george.: i was trying to get it to throw like css
george.: phys:ApplyForceCenter(self.Owner:GetAimVector() * 50)
george.: for shorter throws
</pre>
