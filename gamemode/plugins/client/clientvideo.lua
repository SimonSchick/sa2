local PLUGIN = Plugin("Clientvideo", {})

local vidConfig = {
	container = "webm",
	video = "vp8",
	audio = "vorbis",
	quality = 0,
	bitrate = 1000,
	fps = 10
}

local requestTbl = {
	url = "videos.spaceage.eu",
	method = "post",
	parameters = {
	}
}

local FrameTime = FrameTime
local SysTime = SysTime
function PLUGIN:StartVideo(time, scaleFactor, token)
	local name = string.format(
		"%x%x%x",
		util.CRC(os.time()),
		util.CRC(CurTime()),
		util.CRC(LocalPlayer():SteamID())
	)
	vidConfig.name = name
	vidConfig.width = ScrW()
	vidConfig.height = ScrH()
	local vid, err = video.Record(vidConfig)
	self._vid = vid
	local endTime = SysTime() + time
	local doFrame = false
	hook.Add("DrawOverlay", "SAClientVideo", function()
		doFrame = not doFrame
		if(doFrame) then
			vid:AddFrame(FrameTime(), false)
			if(SysTime() >= endTime) then
				vid:Finish()
				hook.Remove("DrawOverlay", "SAClientVideo")
				local fileHandle = file.Open("video/"..name..".webm", "rb", "GAME")
				requestTbl.parameters.token = token
				requestTbl.parameters.data = util.Base64(fileHandle:Read(fileHandle:Size()))
				fileHandle:Close()
				HTTP(requestTbl)
			end
		end
	end)
end



function PLUGIN:OnEnable()
	net.Receive("SAClientVideoHTTP", function()
		self:SendServerScreenshotHTTP(net.ReadUInt(8), net.ReadFloat(), net.ReadString())
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)