---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com --
-- Authenticated by Gurg  --
---------------------------- 

include('shared.lua')

/*---------------------------------------------------------
Draw
---------------------------------------------------------*/
function ENT:Draw()
	self.Entity:DrawModel()
end


/*---------------------------------------------------------
IsTranslucent
---------------------------------------------------------*/
function ENT:IsTranslucent()
	return true
end


