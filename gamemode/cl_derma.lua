local fontstandard = "Verdana"

-- modified version of my derma thingzzzz

surface.CreateFont("deathrun_derma_Large", {
	font = fontstandard,
	size = 32,
	antialias = true,
	weight = 800
})
surface.CreateFont("deathrun_derma_Medium", {
	font = fontstandard,
	size = 28,
	antialias = true,
	weight = 800
})

surface.CreateFont("deathrun_derma_Small", {
	font = fontstandard,
	size = 20,
	antialias = true,
	weight = 800
})
surface.CreateFont("deathrun_derma_Tiny", {
	font = fontstandard,
	size = 12,
	antialias = true,
	weight = 800
})

local COLORS = {}
COLORS.Bad = HexColor("#e74c3c")
COLORS.BadDark = HexColor("#c0392b")
COLORS.Good = HexColor("#2ecc71")
COLORS.GoodDark = HexColor("#27ae60")
COLORS.NeutralHigh = HexColor("#ecf0f1")
COLORS.NeutralMed = HexColor("#bdc3c7")
COLORS.NeutralLow = HexColor("#95a5a6")
COLORS.NeutralDark = HexColor("#7f8c8d")
COLORS.Turq = DR.Colors.Turq
COLORS.TurqDark = HexColor("#d35400")

function deathrunShadowText( text, font, x, y, col, ax, ay , d)
	if d ~= 0 then
		draw.DrawText( text, font, x+d, y+d, Color(0,0,0,col.a), ax, ay )
	end
	draw.DrawText( text, font, x, y, col, ax, ay)
end

local blur = Material("pp/blurscreen")
local function deathrunDrawBlur(panel, amount)

	local x, y = panel:LocalToScreen(0,0)
	local w, h = ScrW(), ScrH()

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)

	for i = 1, 3 do -- 3 pass blur i guess?
		blur:SetFloat("$blur", (i/3) * (amount or 7))
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect(x*-1,y*-1,w,h)
	end
end

function DR:DrawPanelBlur( panel, amt )
	deathrunDrawBlur( panel, amt )
end


local MAIN = {}

function MAIN:OnClose() end-- stub

function MAIN:Init()  
	
	self.bgalpha = 25
	self.bgcolor = HexColor("#ffffff", 100)
	self.fgcolor = DR.Colors.Turq
	self.title = "deathrun Window"
   
	self.cb = vgui.Create("DButton", self)      
	function self.cb:DoClick()
		self:GetParent():OnClose()
		self:GetParent():Close()
	end
	function self.cb:PaintOver(w,h)
		draw.RoundedBox(0,0,0,w,h, COLORS.Bad)
		--draw.DrawText("✖","deathrun_derma_Medium",w/2,-3,COLORS.NeutralHigh, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end	

	self.inner = vgui.Create("DPanel", self)
	function self.inner:Paint() end

	self:SetSize(384,512+28+8)
	self:Center()
	self:ShowCloseButton( false )
	self.lblTitle:SetVisible(false)

	

end

function MAIN:PerformLayout()

	
	self.cb:SetSize(20,20)
	self.cb:SetPos(self:GetWide()-20-4, 4)

	self.inner:SetSize( self:GetWide(), self:GetTall() - 28 - 8 )
	self.inner:SetPos(0,28)


end

function MAIN:Paint(w,h)
	local inner = {x = 0,y = 28, w = self:GetWide(), h = self:GetTall() - 28 - 8}

	surface.SetDrawColor(COLORS.NeutralHigh)
	deathrunDrawBlur(self, 4)

	local bgcol = self:GetSecondaryColor()
	local fgcol = self:GetPrimaryColor()

	surface.SetDrawColor( bgcol )
	surface.DrawRect(inner.x, inner.y, inner.w, inner.h)

	surface.SetDrawColor( fgcol)
	draw.RoundedBox(0,0,0,w,16, fgcol)
	surface.DrawRect(0,8,w,20)

	draw.RoundedBox(0,0,h-8,w,8, fgcol)
	surface.DrawRect(0,h-8,w,4)

	--title
	deathrunShadowText( self.title ,"deathrun_derma_Small",w/2,4, DR.Colors.Clouds , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 0)
end

function MAIN:SetPrimaryColor( col )
	self.fgcolor = table.Copy(col)
end

function MAIN:SetSecondaryColor( col )
	self.bgcolor = table.Copy(col)
end

function MAIN:GetPrimaryColor( )
	return self.fgcolor
end

function MAIN:GetSecondaryColor( )

	return self.bgcolor
end

function MAIN:SetTitle( str )
	self.title = str
end

vgui.Register("deathrun_window", MAIN, "DFrame")

local BUTTN = {} -- custom buttons

function BUTTN:Init()
	self.w, self.h = 64,24
	
	self.textcol = Color(255,255,255)

	self.color = {}
	self.color.up = COLORS.NeutralDark
	self.color.hover = COLORS.NeutralLow
	self.hover = false
	self.active = false

	self.font = "deathrun_derma_Small"
	self.offsets = {0,-11}

	self.text = "Label"

	self.b = vgui.Create("DButton", self)

	self.b.OnCursorEntered = function()
		self.hover = true
	end

	self.b.OnCursorExited = function()
		self.hover = false
	end

	self.b.OnMousePressed = function( self2, mkey )

		self:OnMousePressed(mkey)
	end

	function self.b:Paint() end
	self.b:SetText("")
	self.disabled = false
end

function BUTTN:PerformLayout()
	self.b:SetSize(self:GetWide(),self:GetTall())
end
function BUTTN:Paint() end
function BUTTN:PaintOver(w,h)
	if self.hover == true or self.active == true then
		surface.SetDrawColor(self.color.hover)
		draw.RoundedBox(0,0,0,w,h, self.color.hover)
	elseif self.hover == false then
		surface.SetDrawColor(self.color.up)
		draw.RoundedBox(0,0,0,w,h, self.color.up)
	end
	

	deathrunShadowText(self.text,self.font,self:GetWide()/2 + self.offsets[1], self:GetTall()/2 +self.offsets[2], self.textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0)
end

function BUTTN:SetTextColor( col )
	self.textcol = col 
end

function BUTTN:SetFont(fo)
	self.font = fo
end

function BUTTN:SetOffsets(x,y)
	self.offsets = {x,y}
end

function BUTTN:SetSelected( bool )

	self.active = bool

end

function BUTTN:SetText( text )

	self.text = text

end

function BUTTN:SetColors(upcol, hovercol)
	self.color.up = upcol
	self.color.hover = hovercol
end

function BUTTN:DoClick()

end

function BUTTN:DoRightClick()
end

function BUTTN:OnMousePressed( mkey )

	if not self.disabled then
		if mkey == MOUSE_LEFT then
			self:DoClick()
		end

		if mkey == MOUSE_RIGHT then
			self:DoRightClick()
		end
	end

end

function BUTTN:IsDown()

	if self.hover == true then
		if input.IsMouseDown( MOUSE_LEFT ) then
			return true
		end
	end

	return false
end

function BUTTN:SetDisabled( bool )
	self.disabled = bool
end


vgui.Register("deathrun_button",BUTTN)


--hub multi panels

local MPANEL = {}

function MPANEL:Init()

	self.buttonoffset = 0

	self:SetSize(640,320)
	self.panels = {}
	self.buttons = {}
	self.tabs = {}

	self.color = {
		HexColor("#c0392b"),
		HexColor("#e74c3c")
	}

	self:PerformLayout()

	self.activetab = 0

	self.spacer = vgui.Create("DPanel",self)

	function self.spacer:Paint()
		surface.SetDrawColor(COLORS.NeutralLow)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	self.spacer:SetPos(0,24)
	 -- Color(46, 204, 113)
	  -- Color(39, 174, 96)
	self.navleft = vgui.Create("deathrun_button", self)
	self.navleft:SetColors( Color(39, 174, 96), Color(46, 204, 113))
	self.navleft:SetText( "<" )
	self.navleft:SetSize(24,24)

	function self.navleft:Think()
		if self:IsDown() then
			self:GetParent().buttonoffset = self:GetParent().buttonoffset + 2 * (FrameTime()/(1/100))
			self:GetParent():PerformLayout()
		end
	end

	self.navright = vgui.Create("deathrun_button", self)
	self.navright:SetColors( Color(39, 174, 96), Color(46, 204, 113))
	self.navright:SetText( ">" )
	self.navright:SetSize(24,24)

	function self.navright:Think()
		if self:IsDown() then
			print("moving right")
			self:GetParent().buttonoffset = self:GetParent().buttonoffset - 2 * (FrameTime()/(1/100))
			self:GetParent():PerformLayout()
		end
	end

	self.navleft:SetZPos(99)
	self.navright:SetZPos(98)


	self.arrowsvisible = true
end

function MPANEL:ArrowsVisible( bool )

	self.navleft:SetVisible( bool )
	self.navright:SetVisible( bool )

end

function MPANEL:SetTab( idx )

	for i = 1, #self.tabs do
		
		self.buttons[self.tabs[i]]:SetSelected( false )
		self.panels[self.tabs[i]]:SetVisible( false )

	end

	self.buttons[self.tabs[idx]]:SetSelected( true )
	self.panels[self.tabs[idx]]:SetVisible( true )

end

function MPANEL:SetTabDisabled( idx, bool )

	self.buttons[self.tabs[idx]]:SetDisabled( bool )

end

function MPANEL:SetColors(c1, c2)
	self.color[1] = c1
	self.color[2] = c2

end

function MPANEL:AddTab(str_name)

	self.buttons[str_name] = vgui.Create("deathrun_button", self)
	self.buttons[str_name]:SetSize(92,24)
	self.buttons[str_name]:SetText(str_name)
	self.buttons[str_name]:SetColors(COLORS.GoodDark, COLORS.Good)

	self.tabs[#self.tabs+1] = str_name

	self.activetab = #self.tabs
	self.buttons[str_name].idx = #self.tabs

	

	local temp = self.buttons[str_name]

	function temp:DoClick()
		local parent = self:GetParent()
		parent:SetTab( self.idx )
	end


	temp.PaintOver = function(self, w, h)
		if self.hover == true or self.active == true then
			surface.SetDrawColor(self.color.hover)
			draw.RoundedBox(4,0,0,self:GetWide(),12, self.color.hover)
		elseif self.hover == false then
			surface.SetDrawColor(self.color.up)
			draw.RoundedBox(4,0,0,self:GetWide(),12,self.color.up)
		end

		surface.DrawRect(0,8,self:GetWide(),self:GetTall()-8)

		deathrunShadowText(self.text,self.font,self:GetWide()/2 + self.offsets[1], self:GetTall()/2 +self.offsets[2], Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
	end

	self.panels[str_name] = vgui.Create("DPanel", self)
	self.panels[str_name]:SetSize(self:GetWide(),self:GetTall()-28)
	self.panels[str_name]:SetPos(0,28)
	self.panels[str_name]:SetVisible(false)

	self.panels[str_name].Paint = function(self, w, h)
		surface.SetDrawColor(Color(225,225,225))
		surface.DrawRect(0,0,w, h) -- meh
	end

	self:PerformLayout()

	self:SetTab( self.activetab )

	return self.panels[str_name]

end

function MPANEL:PerformLayout()

	
	local maxoff = -((#self.tabs * 92) - self:GetWide()) -24*2 -8
	if self.buttonoffset > 8 then self.buttonoffset = 8 end
	if self.buttonoffset < maxoff then self.buttonoffset = maxoff end

	if maxoff > 0 then self.buttonoffset = 8 end
	
	if self.navright then
		self.navright:SetPos(self:GetWide() - 24)
	end

	if self.spacer then
		self.spacer:SetSize(self:GetWide(), 4)
	end
	for i = 1,#self.tabs do
		self.buttons[self.tabs[i]]:SetPos(24+(i-1)*92+self.buttonoffset,0)
		self.buttons[self.tabs[i]].OriginalX = 8+(i-1)*92
		self.panels[self.tabs[i]]:SetSize(self:GetWide(),self:GetTall()-28)

	end

end
vgui.Register("deathrun_multipanel", MPANEL)

concommand.Add("deathrun_test_derma", function()
	vgui.Create("deathrun_window")
end)