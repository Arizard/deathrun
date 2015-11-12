#Arizard's Deathrun

Yet another Deathrun gamemode for Garrysmod. 

However!

This gamemode aims to create a new standard for deathrun gamemodes to improve every player's experience overall.

This means I'm taking suggestions for what should be standard in Deathrun (i.e. Button Claiming). In fact, I'm begging for suggestions here. I hope to make this *the Deathrun gamemode* one day.

Also, if you see any horriffic, eye-meltingly bad code anywhere in this repository, feel free to spam my steam or github messages about it and I will try and fix it as soon as possible.

##Currently Implemented Features

###Menus
######Help
Typing !help or pressing F1 will open the Help menu. This window displays a webpage from the github repository listing a bunch of useful commands to help the player get started. It also includes information about how to play deathrun.

######Settings
Typing !settings or pressing F2 will open the Settings menu. This lets players easily customise all their clientside convars.

###Zones and Rewards
Server admins can add customisable ending zones to each map, specifying their dimensions, color, and behavior. A number of presets for zones are included in the gamemode - notably, the "end" preset. Selecting this preset will register the zone as a map ending, and any players passing through the zone will be considered to have finished the map.

To open the zones menu, type !zones .

End zones call the hook:
<pre>DeathrunPlayerFinishMap (PLAYER ply, STRING name, TABLE zone, INT place)
-- Where ply is the player finishing the map
-- name is the name of the zone
-- zone is the zone's table storing all it's data (positions, color, type)
-- place is the player's finishing place, e.g. 1, 2, 3 for 1st, 2nd, 3rd place
</pre>

In this hook, you can hand out rewards, ranks, or whatever you'd like to implement through lua.

######Pointshop 1 and RedactedHub
Pointshop 1 and RedactedHub support is included by default. When a player reaches and end zone, the gamemode checks if you have either of these installed, and will reward the player with a specific amount of points. This amount is customised using the **deathrun_pointshop_support <0-9999>** convar.

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

######Customization
You can add custom HUDs which work with the HUD configs in the F2 menu! Please refer to [THIS DOCUMENT](https://github.com/Arizard/deathrun/blob/master/how_to_add_huds.md).

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

######Customization
You can change the announcer's name and the color of the announcer's name using the following two CLIENTSIDE functions:
<pre>
	DR:SetAnnouncerName( STRING name ) -- sets the name, default is "HELP"
	DR:SetAnnouncerColor( COLOR col ) -- sets the color of the announcer name, default is DR.Colors.Alizarin
	DR:SetAnnouncerTable( TABLE tbl ) -- sets the table of messages that the announcer broadcasts into player's chats.
	DR:GetAnnouncerTable( ) -- returns the table of messages that gets broadcasted so that you can make changes to it.
	DR:AddAnnouncement( STRING announcement ) -- Adds an announcement to the table of announcements that are broadcast by the announcer.
</pre>

###MOTD
This gamemode includes a simple MOTD by default. To customise it's behaviour, use the following CLIENTSIDE functions:
<pre>
	DR:SetMOTDEnabled( BOOLEAN enabled ) -- False to disable globally, True to enable globally (clients can still disable for themselves using F2 menu )
	DR:SetMOTDTitle( STRING title ) -- Title of the MOTD Window
	DR:SetMOTDSize( NUMBER w, NUMBER h ) -- Size of the MOTD window
	DR:SetMOTDPage( STRING url ) -- the URL to open in the MOTD window, e.h. http://www.MyCommunityIsCool.com
</pre>

###AFK Timers
If a player has been AFK for at least 35 seconds since the start of the round, they will be forced to spectator. This will open a menu for them which provides information on why they were moved to spectator, and how to get out of spectator.



##Images
Help Menu

![](http://i.imgur.com/DBhgaVb.jpg)

Settings Menu

![](http://i.imgur.com/GgcCbBn.jpg)

Weapon recoil pattern

![](http://i.imgur.com/qoUp7qb.png)

Crosshair Creator

![](http://i.imgur.com/pdx6iFl.jpg)

Scoreboard

![](http://i.imgur.com/l5qpgBH.jpg)

Nomination window

![](http://i.imgur.com/w3I5WA6.jpg)

Mapvote window

![](http://i.imgur.com/al5IQ4E.png)

Autojump Velocity Cap (at 450 u/s)

![](http://i.imgur.com/P2u4KrJ.png)

Start and End zones with Zone Editor

![](http://i.imgur.com/VacPaV3.png)
![](http://i.imgur.com/mB561X1.png)