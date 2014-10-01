local PANEL = {}

function PANEL:Init()
	self._font = "default"
	self._textColor = Color(0, 0, 0, 255)
	self._drawTimeStamps = true
	self._dirty = true
	
	self._formText = nil
	self._formColors = nil
	
	self._text = nil
	self._colors = nil
	self._segposx = nil
	self._segposy = nil
	self._segcount = 0
	self._lineheight = 0
end

function PANEL:SetShowTimeStamps(b)
	self._drawTimeStamps = b
	self._dirty = true
	self:InvalidateLayout(true)
end

function PANEL:SetPlayer(ply)
	self._player = ply
	self._dirty = true
	self:InvalidateLayout(true)
end

function PANEL:SetTextColor(col)
	self._textColor = col
	self._dirty = true
	self:InvalidateLayout(true)
end

function PANEL:SetFont(font)
	self._font = font
	self._dirty = true
	self:InvalidateLayout(true)
end

function PANEL:SetText(...)
	self._rawtext = {...}
	self._dirty = true
	self:InvalidateLayout(true)
end

local tagFormatting = {}
tagFormatting.color = {
	function(param, baseFormatting, curFormatting)
		local r, g, b = param:match("^#?(%x%x)(%x%x)(%x%x)$")
		if(not r or r == "") then
			r, g, b = param:match("^#?(%x)(%x)(%x)$")
			if(not r or r == "") then
				r, g, b = param:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
				if(not r or r == "") then
					return baseFormatting.color
				end
				r = tonumber(r)
				g = tonumber(g)
				b = tonumber(b)
			else
				r = tonumber(r, 16)*16
				g = tonumber(g, 16)*16
				b = tonumber(b, 16)*16
			end
		else
			r = tonumber(r, 16)
			g = tonumber(g, 16)
			b = tonumber(b, 16)
		end
		curFormatting.color = Color(r, g, b, 255)
		return curFormatting.color
	end,
function(param, baseFormatting, curFormatting)
	return baseFormatting.color
end}
tagFormatting.c = tagFormatting.color
tagFormatting.bold = {function(param, baseFormatting, curFormatting)
	curFormatting.bold = true
	return "B_"..tostring(curFormatting.bold)
end, function(param, baseFormatting, curFormatting)
	return "B_"..tostring(baseFormatting.bold)
end}
tagFormatting.b = tagFormatting.bold
tagFormatting.underline = {function(param, baseFormatting, curFormatting)
	curFormatting.underline = true
	return "U_"..tostring(curFormatting.underline)
end, function(param, baseFormatting, curFormatting)
	return "U_"..tostring(baseFormatting.underline)
end}
tagFormatting.u = tagFormatting.underline
tagFormatting.italic = {function(param, baseFormatting, curFormatting)
	curFormatting.italic = true
	return "I_"..tostring(curFormatting.italic)
end, function(param, baseFormatting, curFormatting)
	return "I_"..tostring(baseFormatting.italic)
end}
tagFormatting.i = tagFormatting.italic

local function __walkBBTree(tbl, tree, baseFormatting)
	local cf = tagFormatting[tree.tag]
	local curFormatting = table.Copy(baseFormatting)
	if cf then
		table.insert(tbl, cf[1](tree.param, baseFormatting, curFormatting))
	end
	for _,v in next, tree.children do
		if type(v) == "string" then
			table.insert(tbl, v)
		else
			__walkBBTree(tbl, v, curFormatting)
		end
	end
	if cf then
		table.insert(tbl, cf[2](tree.param, baseFormatting, curFormatting))
	end
end

local function __parseBBText(tbl, str, baseFormatting)
	local mainStack = {
		tag = "[ROOT]",
		children = {},
		parent = nil
	}
	local curStack = mainStack
	
	local imax, i = string.len(str), 1
	local s, e, t, tp
	while i <= imax do
		s = string.find(str, "[", i, true)
		if not s then break end
		
		if i < s then
			table.insert(curStack.children, string.sub(str, i, s - 1))
		end
		
		s = s + 1
		e = string.find(str, "]", s, true)
		if not e then break end
		e = e - 1
		if string.sub(str, s, s) == "/" then
			t = string.sub(str, s + 1, e)
			if t == curStack.tag then
				curStack = curStack.parent
			else
				table.insert(curStack.children, "[/"..t.."]")
			end
		else
			t = string.sub(str, s, e)
			s = string.find(t, "=", 1, true)
			if s then
				tp = string.sub(t, s + 1)
				t = string.sub(t, 1, s - 1)
			end
			local newStack = {
				tag = t,
				param = tp,
				children = {},
				parent = curStack
			}
			table.insert(curStack.children, newStack)
			curStack = newStack
		end
		
		i = e + 2
	end
	
	if curStack ~= mainStack then
		table.insert(tbl, str)
		return
	end
	
	if i < string.len(str) then
		table.insert(curStack.children, string.sub(str, i))
	end
	
	__walkBBTree(tbl, mainStack, baseFormatting)
end

function PANEL:SetBBCodeText(...)
	local _rawtext = {...}
	self._rawtext = {}
	local ctype, cur
	local ccol = Color(255, 255, 255, 255)
	for i=1,#_rawtext,1 do
		cur = _rawtext[i]
		ctype = type(cur)
		if ctype == "string" then
			__parseBBText(self._rawtext, cur, {color=ccol})
		else
			if ctype == "table" and cur.a and cur.r and cur.g and cur.b then
				ccol = cur
			end
			table.insert(self._rawtext, cur)
		end
	end
	
	self._dirty = true
	self:InvalidateLayout(true)
end

function PANEL:PerformLayout(w, h)
	surface.SetFont(self._font)
	
	local imax, ctext, ccolor = #self._rawtext, "", self._textColor
	local cur, ctype
	local i = 1
	
	--Actual recomputation
	if self._dirty then
		if not self._rawtext then return end
		
		self._formText = {}
		self._formColors = {}
		
		while i <= imax do
			cur = self._rawtext[i]
			ctype = type(cur)
			if ctype == "string" then
				ctext = ctext .. cur
			elseif ctype == "Player" then
				table.remove(self._rawtext, i)
				table.insert(self._rawtext, i, cur:Name())
				table.insert(self._rawtext, i, team.GetColor(cur:Team()))
				i = i - 1
				imax = imax + 1
			elseif ctype == "table" and cur.r and cur.g and cur.b and cur.a then
				if ((ccolor.r ~= cur.r or
					ccolor.g ~= cur.g or
					ccolor.b ~= cur.b or
					ccolor.a ~= cur.a
					) and ctext ~= "") then
					table.insert(self._formText, ctext)
					table.insert(self._formColors, ccolor)
					
					ctext = ""
				end
				ccolor = cur
			end
			i = i + 1
		end
		
		if ctext ~= "" then
			table.insert(self._formText, ctext)
			table.insert(self._formColors, ccolor)
		end
		
		self._dirty = false
	end
	
	--Line-wrapping
	local _formText = table.Copy(self._formText)
	
	self._text = {}
	self._colors = {}
	self._segposx = {}
	self._segposy = {}
	
	local curx, cury = 0, 0
	local tmp, tmplh
	local curlineheight = 0
	i = 1
	while i <= #_formText do
		cur = _formText[i]
		tmp, tmplh = surface.GetTextSize(cur)
		ccolor = string.find(cur, " ")
		if curx + tmp > w and (curx > 0 or (ccolor and ccolor > 1)) then
			ctype = 0
			ccolor = ctype
			while true do
				ccolor = string.find(cur, " ", ctype + 1)
				if ccolor == nil or ccolor == 1 or ccolor == string.len(cur) then
					break
				end
				tmp, tmplh = surface.GetTextSize(string.sub(cur, 1, ccolor))
				if ctype > 0 and curx + tmp > w then
					break
				end
				if tmplh > curlineheight then
					curlineheight = tmplh
				end
				ctype = ccolor
			end
			
			if ctype > 1 then
				table.insert(self._text, string.sub(cur, 1, ctype))
				table.insert(self._colors, self._formColors[i])
				table.insert(self._segposx, curx)
				table.insert(self._segposy, cury)						
				
				_formText[i] = string.sub(cur, ctype + 1)
				i = i - 1
			end
			
			cury = cury + curlineheight
			curx = 0
			curlineheight = 0					
		else
			if tmplh > curlineheight then
				curlineheight = tmplh
			end
			table.insert(self._text, cur)
			table.insert(self._colors, self._formColors[i])
			table.insert(self._segposx, curx)
			table.insert(self._segposy, cury)
			curx = curx + tmp
		end
		i = i + 1
	end
	
	cury = cury + curlineheight
	
	self._segcount = #self._text
	
	if self._height ~= cury then
		self._height = cury
		self:SetTall(self._height)
	end
end

function PANEL:SetDrawBackground(b)
	self._drawBackground = b
end

function PANEL:OnMousePressed(mouseCode)
	if(mouseCode == MOUSE_RIGHT) then
		local menu = DermaMenu()
			menu:AddOption("copy", function() end)
			menu:AddOption("???", function() end)
			menu:Open()
	end
end

function PANEL:SetBackgroundColor(col)
	self._backgroundColor = col
	self._drawBackground = true
end

function PANEL:Paint(w, h)
	if not self._text then return end

	if(self._drawBackground) then
		surface.SetDrawColor(self._backgroundColor)
		surface.DrawRect(0, 0, w, h)
	end
	--timestamp
	surface.SetFont(self._font)
	for i=1,self._segcount,1 do
		surface.SetTextColor(self._colors[i])
		surface.SetTextPos(self._segposx[i], self._segposy[i])
		surface.DrawText(self._text[i])
	end
	--text
end

vgui.Register("DSAChatBoxLine", PANEL, "DPanel")