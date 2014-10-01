local PLUGIN = Plugin("Clientscreenshot", {})

function PLUGIN:SendServerScreenshot(id, token)
	local rReadPixels = render.ReadPixels
	local mfloor = math.floor
	local mceil = math.ceil
	local schar = string.char
	
	hook.Add("HUDPaint", "SAScreenShot", function()
		local r, g, b
		local r2, g2, b2
		local w, h = ScrW(), ScrH()
		local stor = {}
		render.CapturePixels()
		for x = 1, w do
			for y = 1, h do
				r, g, b = rReadPixels(w, h)
				stor[#stor+1] = mfloor((r+g+b)/6) | (mceil((r2+g2+b2)/6) << 4)
			end
		end
		stor = util.Compress(table.concat(stor))
		
		local len = stor:len()
		local packetCount = len/65500

		local curr = 1
		local nWriteData = net.WriteData
		net.Start("SAScreenshotSendStart")
			net.WriteUInt(ScrW(), 16)
			net.WriteUInt(ScrH(), 16)
			net.WriteUInt(len, 32)
			net.WriteString(token)
		net.SendToServer()
		timer.Create("SAScreenshotSend"..tostring(id), 3, packetCount, function()
			net.Start("SAScreenshotPacket")
				nWriteUInt(id, 8)
				nWriteData(stor:sub(curr, math.min(curr+65500), len))
			net.SendToServer()
			cur = cur + 65500
		end)
		hook.Remove("HUDPaint", "SAScreenShot")
	end)
end

local requestTbl = {
	url = "screenshots.spaceage.eu",
	method = "post",
	parameters = {
	}
}
function PLUGIN:SendServerScreenshotHTTP(id, token)
	local rReadPixels = render.ReadPixels
	local mfloor = math.floor
	local mceil = math.ceil
	local schar = string.char
	
	hook.Add("HUDPaint", "SAScreenShot", function()
		local w, h = ScrW(), ScrH()
		local stor = {}
		render.CapturePixels()
		for x = 1, w do
			for y = 1, h do
				stor[#stor+1], stor[#stor+2], stor[#stor+3] = rReadPixels(w, h)
			end
		end
		stor = util.Compress(table.concat(stor))
		
		local len = stor:len()
		local packetCount = len/65500

		--ENCODE TO BMP
		requestTbl.parameters.token = token
		requestTbl.parameters.data = util.Base64Encode(stor)
		HTTP(requestTbl)
		hook.Remove("HUDPaint", "SAScreenShot")
	end)
end

function PLUGIN:OnEnable()
	
	net.Receive("SAClientScreenshot", function()
		self:SendServerScreenshot(net.ReadUInt(8), net.ReadString())
	end)
	
	net.Receive("SAClientScreenshotHTTP", function()
		self:SendServerScreenshotHTTP(net.ReadUInt(8), net.ReadString())
	end)
	
	net.Receive("SAClientScreenshotAbort", function()
		timer.Remove("SAScreenshotSend"..tostring(net.ReadUInt(32)))
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAClientScreenShot", nil)
	net.Receive("SAClientScreenshotHTTP", nil)
	net.Receive("SAClientScreenshotAbort", nil)
end

SA:RegisterPlugin(PLUGIN)