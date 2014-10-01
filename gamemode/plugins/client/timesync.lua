local PLUGIN = Plugin("Timesync", {})

function PLUGIN:GetOffset()
	return self._offset
end

function PLUGIN:GetTime()
	return os.time() + self._offset
end

function PLUGIN:OnEnable()
	local serverTime
	local diffTime
	net.Receive("SATimeSync", function()
		local serverTime = net.ReadUInt(32)
		self._offset = serverTime - os.time()
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SATimeSync", nil)
end

SA:RegisterPlugin(PLUGIN)