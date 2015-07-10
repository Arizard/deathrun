#Arizard's Deathrun
<table>
<tr>
<td>
 <p><b>GAMEMODE STATUS</b></p>

<td>
 <b><i>SOMEWHAT READY</i></b> - It's mostly stable but expect some bugs.
</td>
</tr>
</table>


Yet another Deathrun gamemode for Garrysmod. 

However!

This gamemode aims to create a new standard for deathrun gamemodes to improve every player's experience overall.

This means I'm taking suggestions for what should be standard in Deathrun (i.e. Button Claiming). In fact, I'm begging for suggestions here. I hope to make this *the Deathrun gamemode* one day.

Also, if you see any horriffic, eye-meltingly bad code anywhere in this repository, feel free to spam my steam or github messages about it and I will try and fix it as soon as possible.

###Planned Features:
* Map start and end zones - To allow for timing and rewards. Specify two corners of a cuboid.
* Death Avoidance Penalty - Force players to spectator for 3 rounds when they attempt to death-avoid.
* Pointshop support ????
* ReDie - Allow players to spawn as ghosts so that they can practice the map instead of being forced to spectate.
* Evolve support for scoreboard (kick, ban, slay, gag)
* MORE HOOKS

###Separate stuff
* RTD
* Leveling/XP (hooks into starts/ends)

##Currently Implemented Features

###Menus
######Help
Typing !help or pressing F1 will open the Help menu. This window displays a webpage from the github repository listing a bunch of useful commands to help the player get started. It also includes information about how to play deathrun.

######Settings
Typing !settings or pressing F2 will open the Settings menu. This lets players easily customise all their clientside convars.

###Button Claiming
This gamemode features automatic button claiming, inspired by BlackVoid's manual button claiming in his deathrun gamemode. Walk up to a button to claim it as yours. Once claimed, it is impossible for another player to press the button - thus it is impossible to button steal. Walk away from a button and it will become unclaimed, allowing other players to claim it. There is a subtle text indicator which will tell you if the button is claimed or unclaimed, and the name of the player who claims it.

###Weapons
Spray patterns for all weapons are somewhat predictable - an inverted triangle leaning to the right. Pull down and to the left to compensate! This aims to remove randomness from shooting, because nobody likes aiming directly onto another player, only for the random spread to miss the shot! Weapons also do extra damage for headshots.

###HUD
######Health and Velocity
HUD displays the Health, Velocity, round timer, round state and current team. The position of the HUD can be changed from the settings menu. Type !settings or press F2.

######Crosshair
You can customise your crosshair using a bunch of convars, similar to the ones used in CS:GO. Type !crosshair to open the crosshair creator. Choose color, gap, length and thickness.

######Scoreboard
From the scoreboard you can view the full list of players currently on the server, their living status (alive/dead), and you can copy their steam ID and mute the player by right-clicking to free the cursor, and then left-clicking on the player. Muted players show up with a muted icon on their avatar. Dead players will have a red X on their avatar and their scoreboard row will be washed out. The header changes to your server's Hostname. Supports scrolling for large player counts.

Scoreboard will support customization of columns through a series of gamemode hooks.

If you have ULX installed, the scoreboard allows you to gag, mute, slay, kick and ban players by clicking on their name.

######Celebration screen
When a team wins, a victory screen is displayed on the HUD, listing the winning team and it's MVPs.

######Sound Cues
There are sound cues at the start and end of each round. These can be disabled in the settings menu.

###Mapvote
The gamemode features a native mapvote with an included nomination system. The mapvote can be configured to display any number of maps to be voted for, though it is recommended to choose a value between 5 and 10.

######Nominations
Players can type !nominate or !maps to view a full list of maps on the server. They can click on a map to nominate it for the mapvote. Once nominated, the map will show up in the mapvote window.

######Mapvote window
The mapvote window is initialized by default on the end of the last round of the map, but it can also be initiated when enough players vote to RTV. The ratio of votes:players required can be customized with the convar **mapvote_rtv_ratio <0.0 - 1.0>**.

Players press the keys 1-9 to vote for maps, but they can also hold the scoreboard open and click on the mapvote with their mouse to vote for a map (e.g. if you display more than 9 maps).

###Idle Support
When there is nobody else on the server except for one player, they have access to godmode and the commands !respawn and !cleanup. This allows them to practice the map or mess around with traps until more players join, giving them something to do in the meantime, rather than be forced to fly around in spectate mode.

This will help servers fill up, rather than staff having to idle on the server until it has enough players to sustain itself.

###Chat Commands
The gamemode features a number of simple chat commands, but more importantly, the gamemode allows developers to easily attach console commands to chat commands using the sv_commands.lua API.

<pre>
-- Example adding a simple chat command linked to a console command
----------
--SERVER--
----------

-- ply is the player who issued the command
-- args is a table of string arguments specifed after the command 
-- (it does not include the command itself)

DR:AddChatCommand("help", function( ply, args ) 
	ply:ConCommand("deathrun_open_help")
end)

-- When a player types !help, it runs that console command on the player
-- When they type /help, it does the same, except the command does not 
-- show in chat (silent command).

----------
--CLIENT--
----------

concommand.Add("deathrun_open_help", function()
	DR:OpenHelp()
end)

</pre>

###Autojump
Yes, this gamemode includes Autojump by default. However - players using autojump will be capped at a maximum velocity of 450u/s (this can be customised by server owners with the convar **deathrun_autojump_velocity_cap <0-99999> ; 0 = unlimited**. Disabling autojump through the settings menu will remove this velocity cap and allow legitimate bhoppers to achieve any speed they like.

Players using autojump will see AUTO in capital letters displayed on their velocity bar.

*FAQ - Why velocity cap?*

*A:* Why should a scrollwheel bhopper lose to a player who holds spacebar? Autojump is viral in the deathrun scene because it makes the game really easy for anyone who knows how to hold a key down. Scrollwheel bhoppers take time to practice and become good at legitimate bhopping, so they should be rewarded for their skill - autojump is too easy and requires very little skill, so players should not be rewarded for completing a map with autojump on, and instead be handicapped.

###Helpful Announcements
Help messages are regularly printed to each player's chat. The frequency and visibility of these messages can be customised through the settings menu.

##Images
Help Menu
![](http://i.imgur.com/Ealwjha.png)

Settings Menu
![](http://i.imgur.com/DJtmTaw.png)

Weapon recoil pattern
![](http://i.imgur.com/qoUp7qb.png)

Health and Velocity HUD
![](http://i.imgur.com/RdleFGm.png)

Crosshair Creator
![](http://i.imgur.com/LB95Yko.png)

Scoreboard
![](http://i.imgur.com/WkyEzwd.png)

Nomination window

![](http://i.imgur.com/5w0oNpT.png)

Mapvote window
![](http://i.imgur.com/al5IQ4E.png)

Autojump Velocity Cap

![](http://i.imgur.com/sMcW33i.png)

Start and End zones with Zone Editor

![](http://i.imgur.com/mjJcrmH.png)