#Deathrun

##TODO
* Bind !help to F1
* Bind !settings to F2

##Planned Features:
* Map start and end zones - To allow for timing and rewards. Specify two corners of a cuboid.
* Death Avoidance Penalty - Force players to spectator for 3 rounds when they attempt to death-avoid.
* Pointshop support.
* RTD - convar to enable/disable, or even release as a separate addon.
* ReDie - Allow players to spawn as ghosts so that they can practice the map instead of being forced to spectate.
* ULX + Evolve support for scoreboard (kick, ban, slay, gag)
* Celebration screen when one team wins - List the team and the names of the winning players.

##Separate stuff
* RTD
* Leveling/XP (hooks into starts/ends)

##Currently Implemented
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

<video style="min-width: 20px; min-height: 20px; border: 1px solid #fff; box-shadow: 0 0 4px rgba( 0, 0, 0, 0.4 );" src="https://d.maxfile.ro/ipmzgxrrom.webm" controls="controls">Your browser doesn't support HTML 5 videos!</video>