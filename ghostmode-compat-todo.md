##check if ghostmode installed
* GhostMode ~= nil
* if it's not installed then GhostMode == nil

##meta functions
ply:IsGhostMode() returns boolean isGhost
ply:SetGhostMode( boolean ghost ) returns nil

##team
TEAM_GHOST = 5

##issues
* does not seem to set players to TEAM_GHOST when they type the command
  * solution - possibly add a conditional around the contents of the PlayerSpawn hook which checks ply:IsGhostMode() == true to avoid doing anything if the player is ghost - the addon will switch the player's team and THEN call the PlayerSpawn hook again, which means it will run normally since ply:IsGhostMode() will be false.


