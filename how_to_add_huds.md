#How to add your own HUDs

1. Create a clientside lua file (e.g. lua/autorun/client/custom_hud.lua)
2. Inside that lua file, create two functions which take an X and a Y value as the first 2 arguments.
3. The first function should draw the HUD elements on the LEFT side of the screen. The second function should draw the HUD elements on the RIGHT side of the screen.
4. Now, after you have defined these functions, call the function: <pre>DR:AddCustomHUD( index, leftfunction, rightfunction )</pre>
*(Where index is an integer for the HUD's index (for use in the F2 menu, leftfunction is your left-hand function, rightfunction is your right-hand function)*


5. Use an index between 3 and 12 inclusive, otherwise you will overwrite the default 3 HUD options.
6. Enjoy - the players can now select the HUD from the F2 menu when they set their **HUD Theme** setting to your *index* value. 

**NOTE:** If you used the X and Y value as the top-left corner of both your left and right HUDs, then players will be able to customise the position of your HUD on the screen. In order for this to work properly, please contain your left and right-hand HUDs to a box of dimensions 228x108 - this ensures there is no clipping with the sides of the screen.

*Example:*
<pre>

-- lua/autorun/client/custom_hud_example.lua
hook.Add("InitPostEntity", "CustomHUDAdd", function()
	local function leftSideHUD(x,y)
		draw.SimpleText("HP: "..tostring(LocalPlayer():Health()), "deathrun_hud_Large", x,y, Color(255,255,255))
		draw.SimpleText("VEL: "..tostring(LocalPlayer():GetVelocity():Length2D()), "deathrun_hud_Large", x,y+55, Color(255,255,255))
	end

	local function rightSideHUD(x,y)
		-- nothing here because we have infinite ammo enabled anyways
	end

	DR:AddCustomHUD( 4,  leftsideHUD, rightSideHUD )
end)
-- done!
</pre>