#Arizard's Deathrun
<table>
<tr>
<td>
 <p><b>GAMEMODE STATUS</b></p>
</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td>
 <b>SOMEWHAT READY</b><br/>It definitely works, but main features will be missing.
</td>
</tr>
</table>


Yet another Deathrun gamemode for Garrysmod. 

However!

This gamemode aims to create a new standard for deathrun gamemodes to improve every player's experience overall.

This means I'm taking suggestions for what should be standard in Deathrun (i.e. Button Claiming). In fact, I'm begging for suggestions here. I hope to make this *the Deathrun gamemode* one day.

Also, if you see any horriffic, eye-meltingly bad code anywhere in this repository, feel free to spam my steam or github messages about it and I will try and fix it as soon as possible.

I plan to include features such as map start/end zones (with hooks for customization), button claiming, easy scoreboard customization, appealing HUD and a focus on graphical interfaces for admins and players (menus for *everything*). The gamemode will also include formatted gamemode chat messages and an easy way to add chat commands. Also features css weapons by default.

##Weapons
![](http://i.imgur.com/oR8DjMY.png, "Somewhat predictable recoil patterns for all weapons")

Spray patterns for all weapons are somewhat predictable - an inverted triangle leaning to the right. Pull down and to the left to compensate!
##HUD
###Health and Velocity
![](http://i.imgur.com/zeY8EcB.png "More HUD Positions!")

You can change the position of the HUD with the convar 
<pre>
deathrun_hud_position <0-8>

values:
	0 top left
	1 top center
	2 top right
	3 center left
	4 center center (?why?)
	5 center right
	6 bottom left
	7 bottom center
	8 bottom right
</pre>
###Crosshair
You can customise your crosshair using a bunch of convars, similar to the ones used in CS:GO. Type !crosshair to open the crosshair creator.

<pre>
Convars:
	deathrun_crosshair_gap <int> // the space inside the cross
	deathrun_crosshair_size <int> // the length of each line
	deathrun_crosshair_thickness <int> // the thickness of each line
	deathrun_crosshair_alpha <0-255> // transparency of the crosshair
	deathrun_crosshair_red
	deathrun_crosshair_green
	deathrun_crosshair_blue <0-255> // red, green, blue values for the color.
</pre>
![](http://i.imgur.com/WXhPeLV.png)
![](http://i.imgur.com/95pKGCK.png)
![](http://i.imgur.com/SPBUqLq.png)

###Scoreboard
From the scoreboard you can view the full list of players currently on the server, their living status (alive/dead), and you can (currently) copy their steam ID and mute the player by right-clicking to free the cursor, and then left-clicking on the player. Muted players show up with a muted icon on their avatar. Dead players will have a red X on their avatar and their scoreboard row will be washed out. The header changes to your server's Hostname. Supports scrolling for large player counts.

Scoreboard will support customization of columns through a series of gamemode hooks.

![](http://i.imgur.com/OagMUse.png)