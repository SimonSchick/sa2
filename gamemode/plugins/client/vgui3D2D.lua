--[[
	Purpose:
		Rendering VGUI in 3D-Space

	USAGE:
	
	PANEL:Set3D2D(bool)
	PANEL:Set3D2DScale(float)
	PANEL:	
	PANEL:Set3D2DAng(angle)
	PANEL:Set3D2DParent(entity)
]]--

local PLUGIN = Plugin("VGUI3D2D", {})
PLUGIN._detours = {--add libs which are used for detours here
	gui = {},
	vgui = {},
	_R = {
		Panel = {}
	},
},
PLUGIN._fadeDistance = 1000^2,--maximum render distance^2
PLUGIN._detoursActive = (PLUGIN and PLUGIN._detoursActive),

--FIXME:
--Fix Event handling
--Inline rayPlaneIntersection into update function

--FIXME GM13 CHILD SYSTEMS

local GMOD_VERSION = 12--halo and 13 or 12

local function makeExamplePanel()
	local PANEL = {}

	function PANEL:Init()
		self.LastWheel = 0
		self.LastExit = 0
		self.LastEnter = 0
		self.LastMove = 0
		self.LastClick = 0
		self.LastKeyPress = 0
		
		self.textField = vgui.Create("DTextEntry", self)
		self.textField:SetPos(60, 60)
	end

	function PANEL:Paint()
		local w, h = self:GetSize()
		surface.SetDrawColor(100,100,100,100)
		surface.DrawRect(0, 0, w, h)
		
		if(self.__hovered) then
			surface.SetDrawColor(255,0,0,255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
		if((RealTime() - self.LastEnter) < 0.5) then
			surface.SetDrawColor(0, 255, 0, 255)
			surface.DrawOutlinedRect(1, 1, w-2, h-2)
		end
		if((RealTime() - self.LastExit) < 0.5) then
			surface.SetDrawColor(255, 255, 0, 255)
			surface.DrawOutlinedRect(2, 2, w-4, h-4)
		end
		if((RealTime() - self.LastWheel) < 0.5) then
			surface.SetDrawColor(255, 0, 255, 255)
			surface.DrawOutlinedRect(3, 3, w-6, h-6)
		end
		if((RealTime() - self.LastMove) < 0.5) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawOutlinedRect(4, 4, w-8, h-8)
		end
		if((RealTime() - self.LastClick) < 0.5) then
			surface.SetDrawColor(0, 0, 255, 255)
			surface.DrawOutlinedRect(5, 5, w-10, h-10)
		end
		if((RealTime() - self.LastKeyPress) < 0.5) then
			surface.SetDrawColor(0, 255, 255, 255)
			surface.DrawOutlinedRect(6, 6, w-12, h-12)
		end
		surface.SetDrawColor(255, 0, 0, 255)
		surface.DrawRect(11, 11, (w-22)/2, (h-22)/2)
		
		surface.SetDrawColor(0, 0, 255, 255)
		surface.DrawRect(w/2, 11, (w-22)/2, (h-22)/2)
		
		surface.SetDrawColor(0, 255, 0, 255)
		surface.DrawRect(11, h/2, w-22, (h-22)/2)
		
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(gui.MouseX()-self.x, gui.MouseY()-self.y, 1, 1)
	end

	function PANEL:OnCursorEntered()
		self.LastEnter = RealTime()
	end

	function PANEL:OnCursorExited()
		self.LastExit = RealTime()
	end

	function PANEL:OnMouseWheeled()
		self.LastWheel = RealTime()
	end

	function PANEL:OnCursorMoved()
		self.LastMove = RealTime()
	end

	function PANEL:OnMousePressed()
		self.LastClick = RealTime()
	end

	function PANEL:OnKeyCodePressed(k)
		self.LastKeyPress = RealTime()
	end

	vgui.Register("3d2dTestPanel", PANEL, "EditablePanel")

	if(TESTPNL2) then
		TESTPNL2:Remove()
	end
	
	TESTPNL2 = vgui.Create("3d2dTestPanel")
	TESTPNL2:SetSize(200, 200)
	
	TESTBTN2 = vgui.Create("DButton", TESTPNL2)
	TESTBTN2:SetPos(20, 20)
	TESTBTN2:SetSize(20, 20)

	TESTPNL2:Set3D2D(true)
	TESTPNL2:Set3D2DScale(0.2)
	TESTPNL2:Set3D2DPos(Vector(0, 1120, 170))
	TESTPNL2:Set3D2DAng(Angle(20,5,25))
end

function PLUGIN:OnEnable(debugging)
	if(self._isActive) then
		return
	end
	self._isActive = true
	--We use globals for performence and for general use

	local NULL_ANG = Angle(0, 0, 0)--default values
	local NULL_VEC = Vector(0, 0, 0)

	local ACTIVE_PANELS = self._ACTIVE_PANELS or {}
	local IN_RANGE_PANELS = {}
	
	self._ACTIVE_PANELS = ACTIVE_PANELS

	local CURSOR_POS_X = 0
	local CURSOR_POS_Y = 0

	local VIEW_ORIGIN = NULL_VEC--The players cam pos
	local VIEW_VECTOR = NULL_VEC--normal
	local VIEW_ANGLES = NULL_ANG

	local CURR_PANEL--Current Panel
	local CURR_PANEL_POS = NULL_VEC
	local CURR_PANEL_ANG = NULL_ANG
	local CURR_PANEL_SCALE = 1

	--Needed to allow text input
	local CURR_TEXT_ENTRY

	local FAKE_TEXT_ENTRY_WRAPPER = vgui.Create("EditablePanel")--needed for focusing the TextEntry

	local FAKE_TEXT_ENTRY = vgui.Create("DTextEntry", FAKE_TEXT_ENTRY_WRAPPER)

	self._FAKE_TEXT_ENTRY_WRAPPER = FAKE_TEXT_ENTRY_WRAPPER

	FAKE_TEXT_ENTRY.OnChange = function(self)
		CURR_TEXT_ENTRY:SetValue(self:GetValue())
	end

	local func = FAKE_TEXT_ENTRY.OnLoseFocus
	FAKE_TEXT_ENTRY.OnLoseFocus = function(self)
		FAKE_TEXT_ENTRY_WRAPPER:SetVisible(false)
		self:SetText("")
		func(self)
	end
	
	

	FAKE_TEXT_ENTRY_WRAPPER:SetSize(100, 20)
	FAKE_TEXT_ENTRY_WRAPPER:SetPos(-100, -100)
	FAKE_TEXT_ENTRY_WRAPPER:SetVisible(true)
	--end text input
	--UTILS

	--ray trace intersection
	local function rayPlaneIntersect(planeOrigin, planeNormal, rayOrigin, rayDirection)
		local denominator = rayDirection:Dot(planeNormal)
		if(denominator == 0) then
			return false--parallel
		end
		local ret = Vector()
		ret:Set(rayDirection)
		ret:Mul(((planeOrigin - rayOrigin):Dot(planeNormal)/denominator))
		ret:Add(rayOrigin)
		return ret
	end

	--Called to set all the globals to the panel specific values
	local function setPanelInfo(pnl)
		CURR_PANEL = pnl
		CURR_PANEL_POS = pnl.__3d2dPos
		CURR_PANEL_ANG = pnl.__3d2dAng
		CURR_PANEL_SCALE = pnl.__3d2dScale
	end

	--Updates CURSOR_POS_X and CURSOR_POS_Y for CURR_PANEL
	local WorldToLocal = WorldToLocal
	local mfloor = math.floor
	
	--Inline ray trace intersection
	local function updateCurrent3D2DCursorPos()
		local collisionPoint = rayPlaneIntersect(
			CURR_PANEL_POS,
			CURR_PANEL_ANG:Up(),
			VIEW_ORIGIN,
			VIEW_VECTOR
		)
		if(not collisionPoint) then
			return
		end
		
		local projectedPos = WorldToLocal(collisionPoint, NULL_ANG, CURR_PANEL_POS, CURR_PANEL_ANG)
		projectedPos:Mul(1/CURR_PANEL_SCALE)
		
		CURSOR_POS_X = mfloor(projectedPos.x)
		CURSOR_POS_Y = mfloor(-projectedPos.y)
	endno


	local function handlePanelEvent(pnl, event, ...)
		local handled = false
		local posX, posY = pnl:LocalToScreen(0, 0)
		local cx, cy
		local x, y
		local w, h
		if(pnl.__childs) then
			for child in next, pnl.__childs do
				cx, cy = child:GetPos()
				
				w, h = child:GetSize()
				
				x = posX + cx
				y = posY + cy
				
				if(not (
					(CURSOR_POS_X < x) or
					(CURSOR_POS_X > x + w - 1) or
					(CURSOR_POS_Y < y) or
					(CURSOR_POS_Y > y + h - 1)
					)) then
					local hVal = handlePanelEvent(child, event, ...)
					if (hVal) then
						handled = true
						break
					end
				end
			end
		end
		if (!handled and pnl[event]) then
			if(event == "OnMousePressed") then
				if(pnl:GetClassName() == "TextEntry") then--special handling of text entries to allow focus
					FAKE_TEXT_ENTRY:SetValue(pnl:GetValue())
					FAKE_TEXT_ENTRY:SetCaretPos(pnl:GetValue():len())
				
					CURR_TEXT_ENTRY = pnl
					
					FAKE_TEXT_ENTRY_WRAPPER:SetVisible(true)--Needs to be visible
					FAKE_TEXT_ENTRY_WRAPPER:MakePopup()--GAIN DAT FOCUS
					FAKE_TEXT_ENTRY:RequestFocus()
				end
			end
			pnl[event](pnl, ...)
			if(pnl:GetClassName() == "Label") then
				return false
			end
			return true--FIXME: SPECIAL CASE FOR DFRAMES!!
		else
			return false
		end
	end

	--Updates the hover status of the panel
	local function updateHoverState()
		local x, y = CURR_PANEL:LocalToScreen()
		local w, h = CURR_PANEL:GetSize()
		CURR_PANEL.__hovered = not ((CURSOR_POS_X < x) or
									(CURSOR_POS_X > x + w - 1) or
									(CURSOR_POS_Y < y) or
									(CURSOR_POS_Y > y + h - 1))
	end

	--DETOURS
	local shouldDetourGuiPos--set when any panel action is required

	if(!self._detoursActive) then--Don't detour multiple times >.>
		self._detoursActive = true
		
		local oldGuiMouseX = gui.MouseX
		self._detours.gui.MouseX = oldGuiMouseX
		
		function gui.MouseX()
			if(shouldDetourGuiPos) then
				return CURSOR_POS_X
			end
			return oldGuiMouseX()
		end
		
		local oldGuiMouseY = gui.MouseY
		self._detours.gui.MouseY = oldGuiMouseY
		
		function gui.MouseY()
			if(shouldDetourGuiPos) then
				return CURSOR_POS_Y
			end
			return oldGuiMouseY()
		end
		
		local oldGuiMousePos = gui.MousePos
		self._detours.gui.MousePos = oldGuiMousePos
		
		function gui.MousePos()
			if(shouldDetourGuiPos) then
				return CURSOR_POS_X, CURSOR_POS_Y
			end
			return oldGuiMousePos()
		end
		--Detouring panel parenting
		
		--TODO: Panel.CursorPos
		
		--Tracking of childs
		--delete some time 
		local oldVguiCreate = vgui.Create
		self._detours.vgui.Create = oldVguiCreate
		
		function vgui.Create(class, parent)
			local pnl = oldVguiCreate(class, parent)
			if(not pnl) then
				debug.Trace()
			end
			pnl.__parent = parent
			if (parent) then
				if not parent.__childs then 
					parent.__childs = {}
				end
				parent.__childs[pnl] = true
			end
			return pnl
		end

		local oldPanelParent = _R.Panel.SetParent
		self._detours._R.Panel.SetParent = oldPanelParent
		
		function _R.Panel:SetParent(parent)
			self.__parent = parent
			if(parent) then
				if not parent.__childs then 
					parent.__childs = {}
				end
				parent.__childs[self] = true
			end
			oldPanelParent(self, parent)
		end
		
		local oldSetCursor = _R.Panel.SetCursor
		self._detours._R.Panel.SetCursor = oldSetCursor
		function _R.Panel:SetCursor(cur)
			self.__cursor = cur
			oldSetCursor(self, cur)
		end
	end
	--EVENT HOOKING

	--MOUSE CAPTURE
	local lastHoverState
	local panel
	local tremove = table.remove
	local maxDist
	local doBreak = false
	local x, y, w, h
	
	local cursorMats = {
		user = Material("cursor_user.png"),
		arrow = Material("cursor_arrow.png"),
		beam = Material("cursor_beam.png"),
		hourglass = Material("cursor_hourglass.png"),
		waitarrow = Material("cursor_waitarrow.png"),
		crosshair = Material("cursor_crosshair.png"),
		up = Material("cursor_up.png"),
		sizenwse = Material("cursor_sizewse.png"),
		sizenesw = Material("cursor_sizenesw.png"),
		sizewe = Material("cursor_sizewe.png"),
		sizens = Material("cursor_sizes.png"),
		sizeall = Material("cursor_sizeall.png"),
		no = Material("cursor_no.png"),
		hand = Material("cursor_hand.png")
	}
	hook.Add("CalcView", "3D2DVGUI", function(_, pos, ang)
		if(#ACTIVE_PANELS != 0) then
			if((VIEW_ORIGIN != pos) or (VIEW_ANGLES != ang)) then--only update if the player changed their orientation
				shouldDetourGuiPos = true
				VIEW_ORIGIN = pos
				VIEW_ANGLES = ang
				VIEW_VECTOR = ang:Forward()--EyeVector() doesn't work here
				
				for i = 1, #ACTIVE_PANELS do
					panel = ACTIVE_PANELS[i]
					maxDist = self._fadeDistance
					if(((pos.x - panel.__3d2dPos.x) ^ 2 +
						(pos.y - panel.__3d2dPos.y) ^ 2 +
						(pos.z - panel.__3d2dPos.z) ^ 2
						) > maxDist) then
						IN_RANGE_PANELS[panel] = false
						continue
					end
					IN_RANGE_PANELS[panel] = true
					
					if (!panel:IsValid()) then
						tremove(ACTIVE_PANELS, i)--drop invalid panel
					end
					setPanelInfo(panel)
					updateCurrent3D2DCursorPos()
					
					local x, y = panel:LocalToScreen(0, 0)
					local w, h = panel:GetSize()
					
					lastHoverState = panel.__hovered
					updateHoverState(panel)
					if(panel.__hovered) then
						handlePanelEvent(panel, "OnCursorMoved", CURSOR_POS_X-x, CURSOR_POS_Y-y)
					elseif(panel.__3d2dExitEventCalled) then
						continue
					end
					if(lastHoverState != panel.__hovered) then
						if(lastHoverState) then
							handlePanelEvent(panel, "OnCursorExited")
							panel.__3d2dExitEventCalled = true
						else
							handlePanelEvent(panel, "OnCursorEntered")
							panel.__3d2dExitEventCalled = false
						end
					end
					if(panel.__hovered) then
						break
					end
				end
				shouldDetourGuiPos = false
			end
		else
			CURR_PANEL = false
		end
	end)

	--DRAWING
	local cStart3D2D = cam.Start3D2D
	local cEnd3D2D = cam.End3D2D
	local rGetToneMappingScaleLinear = render.GetToneMappingScaleLinear
	local rSetToneMappingScaleLinear = render.SetToneMappingScaleLinear
	
	local targetScale = Vector(0.66, 0 , 0)
	local oldScale
	hook.Add("PostDrawOpaqueRenderables", "3D2DVGUI", function()
		shouldDetourGuiPos = true
		for i = 1, #ACTIVE_PANELS do
			panel = ACTIVE_PANELS[i]
			if(not IN_RANGE_PANELS[panel]) then
				continue
			end
			if(not panel:IsValid()) then
				continue
			end
			oldScale = rGetToneMappingScaleLinear()
			
			rSetToneMappingScaleLinear(targetScale)
			
			cStart3D2D(panel.__3d2dPos, panel.__3d2dAng, panel.__3d2dScale)
			
				panel:SetPaintedManually(false)
				panel:PaintManual()
				panel:SetPaintedManually(true)
				
				if(panel.__hovered and not(panel.__cursor ~= "none" or panel.__cursor ~= "last" or
				panel.__cursor ~= "blank")) then
					surface.SetMaterial(cursorMats[panel.__cursor])
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(CURSOR_POS_X, CURSOR_POS_Y, 16, 16)
				end
			cEnd3D2D()
			
			rSetToneMappingScaleLinear(oldScale)
		end
		shouldDetourGuiPos = false
	end)

	--KEY CAPTURE
	local IN_USE = IN_USE
	local IN_RELOAD = IN_RELOAD
	local MOUSE_LEFT = MOUSE_LEFT
	local MOUSE_RIGHT = MOUSE_RIGHT
	
	local hCall = hook.Call
	hook.Add("KeyPress", "3D2DVGUI", function(_, key)
		if(#ACTIVE_PANELS != 0) then
			if ((key == IN_USE) or (key == IN_RELOAD)) then
				shouldDetourGuiPos = true
				for i = 1, #ACTIVE_PANELS do
					panel = ACTIVE_PANELS[i]
					if(not IN_RANGE_PANELS[panel]) then
						continue
					end
					if(panel.__hovered) then
						if(key == IN_USE) then
							handlePanelEvent(panel, "OnMousePressed", MOUSE_LEFT)
							hCall("VGUIMousePressed", GM,  pnl, MOUSE_LEFT)
						else
							handlePanelEvent(panel, "OnMousePressed", MOUSE_RIGHT)
							hCall("VGUIMousePressed", GM, pnl, MOUSE_RIGHT)
						end
					end
				end
				shouldDetourGuiPos = false
			end
		end
	end)			

	hook.Add("KeyRelease", "3D2DVGUI", function(_, key)
		if(#ACTIVE_PANELS != 0) then
			if ((key == IN_USE) or (key == IN_RELOAD)) then
				shouldDetourGuiPos = true
				for i = 1, #ACTIVE_PANELS do
					panel = ACTIVE_PANELS[i]
					if(not IN_RANGE_PANELS[panel]) then
						continue
					end
					
					if(panel.__hovered) then
						if(key == IN_USE) then
							handlePanelEvent(panel, "OnMouseReleased", MOUSE_LEFT)
						else
							handlePanelEvent(panel, "OnMouseReleased", MOUSE_RIGHT)
						end
					end
				end
				shouldDetourGuiPos = false
			end
		end
	end)
	
	--Scroll capture
	hook.Add("PlayerBindPress", "3D2DVGUI", function(_, bind, _)
		if(#ACTIVE_PANELS != 0) then
			if ((bind == "invprev") or (bind == "invnext")) then
				shouldDetourGuiPos = true
				for i = 1, #ACTIVE_PANELS do
					panel = ACTIVE_PANELS[i]
					if(not IN_RANGE_PANELS[panel]) then
						continue
					end
					if(panel.__hovered) then
						if(bind == "invprev") then
							handlePanelEvent(panel, "OnMouseWheeled", -0.5)
						else
							handlePanelEvent(panel, "OnMouseWheeled", 0.5)
						end
					end
				end
				shouldDetourGuiPos = false
			end
		end
	end)
	
	
	local keyCache = {}
	for k, v in next, _G do--CACHE DAT TABLE
		if(k:sub(0, 4) == "KEY_") then
			keyCache[v] = false
		end
	end

	local iIsKeyDown = input.IsKeyDown
	local keyState
	hook.Add("Think", "3D2DVGUI", function()
		if(#ACTIVE_PANELS != 0) then
			for i = 1, 159 do--159 is highest key
				keyState = iIsKeyDown(i)
				if(keyState ~= keyCache[i]) then
					if(keyState) then
						for i = 1, #ACTIVE_PANELS do
							panel = ACTIVE_PANELS[i]
							if(not IN_RANGE_PANELS[panel]) then
								continue
							end
							if(panel.__hovered) then
								handlePanelEvent(panel, "OnKeyCodePressed", i)
							end
						end
					else
						for i = 1, #ACTIVE_PANELS do
							panel = ACTIVE_PANELS[i]
							if(not IN_RANGE_PANELS[panel]) then
								continue
							end
							if(panel.__hovered) then
								handlePanelEvent(panel, "OnKeyCodeReleased", i)
							end
						end
					end
					keyCache[i] = keyState
				end
			end
		end
	end)
	
	--DEBUG
	if(debugging and false) then
		hook.Add("HUDPaint", "3D2DVGUI", function()
			surface.SetFont("default")
			surface.SetTextColor(255, 255, 255, 255)
			
			surface.SetTextPos(20, 20)
			surface.DrawText("VIEW_ORIGIN: " .. tostring(VIEW_ORIGIN))
			surface.SetTextPos(20, 40)
			surface.DrawText("VIEW_VECTOR: " .. tostring(VIEW_VECTOR))
			surface.SetTextPos(20, 60)
			surface.DrawText("VIEW_ANGLES: " .. tostring(VIEW_ANGLES))
			surface.SetTextPos(20, 80)
			surface.DrawText("CURR_PANEL: " .. tostring(CURR_PANEL))
			surface.SetTextPos(20, 100)
			surface.DrawText("CURR_PANEL_POS: " .. tostring(CURR_PANEL_POS))
			surface.SetTextPos(20, 120)
			surface.DrawText("CURR_PANEL_ANG: " .. tostring(CURR_PANEL_ANG))
			surface.SetTextPos(20, 140)
			surface.DrawText("CURR_PANEL_SCALE: " .. tostring(CURR_PANEL_SCALE))
			surface.SetTextPos(20, 160)
			surface.DrawText("CURSOR_POS_X: " .. tostring(CURSOR_POS_X))
			surface.SetTextPos(20, 180)
			surface.DrawText("CURSOR_POS_Y: " .. tostring(CURSOR_POS_Y))
		end)
	end

	--Panel Think detour to maintain functionality
	local function thinkOverride(self)
		shouldDetourGuiPos = true
		if(self.__oldThin) then
			self:__oldThink()
		end
		shouldDetourGuiPos = false
	end

	local function tableHasValue(val)
		for i = 1, #ACTIVE_PANELS do
			if(val == ACTIVE_PANELS[i]) then
				return i
			end
		end
		return false
	end


	--methodes
	local tremove = table.remove
	local tinsert = table.insert
	function _R.Panel:Set3D2D(b)
		if(b) then
			self.__3d2dPos = NULL_VEC
			self.__3d2dAng = NULL_ANG
			self.__3d2dScale = 1
			self.__3d2dExitEventCalled = false
		else
			self.__3d2dPos = nil
			self.__3d2dAng = nil
			self.__3d2dScale = nil
			self.__3d2dExitEventCalled = nil
		end
		
		self:SetPaintedManually(b)--prevent 2d drawing
		
		local idx = false
		for i = 1, #ACTIVE_PANELS do
			if(val == ACTIVE_PANELS[i]) then
				idx = i
			end
		end
		
		if(idx and not b) then
			tremove(ACTIVE_PANELS, idx)
			if(self.__oldThink) then
				self.Think = self.__oldThink
				self.__oldThink = nil
			end
		elseif(not idx and b) then
			tinsert(ACTIVE_PANELS, self)
			if(self.Think) then
				self.__oldThink = self.Think
				self.Think = thinkOverride
			else
				self.Think = thinkOverride
				self.__oldThink = false
			end
		end
	end

	function _R.Panel:Set3D2DPos(vec)
		self.__3d2dPos = vec
	end

	function _R.Panel:Set3D2DAng(ang)
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), 90)
		self.__3d2dAng = ang
	end

	function _R.Panel:Set3D2DScale(s)
		self.__3d2dScale = s
	end
	
	local function entParentOverride(ent)
		local ang = ent:GetAngles()
		local pos = ent:GetPos()
		if(ent.__last3d2dPos ~= pos or ent.__last3d2dAng ~= ang) then--only update when we need to!
			ent.__last3d2dPos = pos--POTENTIAL PROBLEM!
			ent.__last3d2dAng = ang--POTENTIAL PROBLEM!
			ang = Angle(ang.p, ang.y, ang.r)--to prevent a BIG fuckup
			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Right(), 90)
			
			
			ang = ang + ent.__3d2dPanel.__3d2dRelParentAng--add relative angle
			pos = pos + ent.__3d2dPanel.__3d2dRelParentPos--add relative positon
			
			ent.__3d2dPanel.__3d2dAng = ang--store coordinates
			ent.__3d2dPanel.__3d2dPos = pos
		end
		if(ent.Draw) then--for SEnt's
			ent:Draw()
		else
			ent:DrawModel()
		end
		
		shouldDetourGuiPos = true
		
		oldScale = rGetToneMappingScaleLinear()
		
		rSetToneMappingScaleLinear(targetScale)--disabling HDR 
		
		cStart3D2D(pos, ang, panel.__3d2dScale)
		
			panel:SetPaintedManually(false)--allow drawing
			panel:PaintManual()
			panel:SetPaintedManually(true)
			
		cEnd3D2D()
		
		rSetToneMappingScaleLinear(oldScale)--resetting HDR
		
		shouldDetourGuiPos = false

	end

	function _R.Panel:Set3D2DParent(ent)--TODO: Add support for multiple panels
		if(ent == nil or ent == NULL) then
			self.__3d2dParent.RenderOverride = nil
			self.__3d2dParent = nil
			self.__3d2dRelParentPos = nil
			self.__3d2dRelParentAng = nil
		end
		self.__3d2dParent = ent
		self.__3d2dRelParentPos = self.__3d2dPos - ent:GetPos()
		self.__3d2dRelParentAng = self.__3d2dAng - ent:GetAngles()--TODO: Fix up angles
		
		ent.__last3d2dPos = ent:GetPos()
		ent.__last3d2dAng = ent:GetAngles()
		
		ent.RenderOverride = entParentOverride
		ent.__3d2dPanel = self
	end
	makeExamplePanel()
end

--recursive function to replace functions within cascading tables
local function removeDetours(tbl, base)
	local t
	for k, v in next, tbl do
		t = type(v)
		if(t == "table") then
			removeDetours(v, base[k])
		elseif(t == "function") then
			base[k] = v
		end
	end
end

function PLUGIN:OnDisable(removePanels)
	if(not self._isActive) then
		return
	end
	self._isActive = false
	
	self._FAKE_TEXT_ENTRY_WRAPPER:Remove()
	
	local panel
	if(removePanels) then
		while #self._ACTIVE_PANELS ~= 0 do
			table.remove(self._ACTIVE_PANELS):Remove()
		end
	else
		while #self._ACTIVE_PANELS ~= 0 do--unset all 3d2d vars
			panel = table.remove(self._ACTIVE_PANELS)
			if(self.__oldThink) then
				self.Think = self.__oldThink
				self.__oldThink = nil
			end
			panel.__3d2dPos = nil
			panel.__3d2dAng = nil
			panel.__3d2dScale = nil
			panel.__3d2dExitEventCalled = nil
		end
	end
	
	--unsetting methodes
	_R.Panel.Set3D2D = nil
	_R.Panel.Set3D2DPos = nil
	_R.Panel.Set3D2DAng = nil
	_R.Panel.Set3D2DScale = nil
	_R.Panel.Set3D2DParent = nil
	
	--removing hooks
	hook.Remove("CalcView", "3D2DVGUI")
	hook.Remove("PostDrawOpaqueRenderables", "3D2DVGUI")
	hook.Remove("KeyPress", "3D2DVGUI")
	hook.Remove("KeyRelease", "3D2DVGUI")
	hook.Remove("PlayerBindPress", "3D2DVGUI")
	hook.Remove("Think", "3D2DVGUI")
	hook.Remove("HUDPaint", "3D2DVGUI")
	
	removeDetours(self._detours, _G)
	
	self._detoursActive = false
end

SA:RegisterPlugin(PLUGIN)