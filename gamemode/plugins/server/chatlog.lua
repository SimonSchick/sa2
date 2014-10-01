local PLUGIN = Plugin("Chatlog", {"MySQL", "Playerdata"})

function PLUGIN:SetUseBuffer(b)
	self._useBuffer = true
end

function PLUGIN:SetBufferSize(val)
	self._bufferSize = val
end

function PLUGIN:OnEnable()
	self._useBuffer = false
	self._legacyLogging = false
	self._bufferSize = 5

	local lastDay
	hook.Add("PlayerSay", "SAChatLog", function(ply, text, isPublic)
		if(self._legacyLogging) then
			if(not self._logFile) then
				self._logFile = file.Open(os.date("!SALogs/%m-%d-%y.txt"), "wb", "DATA")
			end
			if(lastDay ~= os.date("!%d")) then
				self._logFile:Close()
				self._logFile = file.Open(os.date("!SALogs/%m-%d-%y.txt"), "wb", "DATA")
				lastDay = os.date("!%d")
			end
			self._logFile:Write(
				string.format("[%s] (%u;%s)%s: %s\n",
				os.date("%H:%M:%S"),
				ply.__SAPID,
				ply:SteamID(),
				ply:Name(),
				text)
			)
			self._logFile:Flush()
		end
		if(self._useBuffer) then
			return
		end
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_chatlog` (`playerid`, `serverid`, `text`, `timestamp`)
VALUES('%u', '%u', '%s', UNIX_TIMESTAMP());]],
				ply.__SAPID,
				SA:GetServerID(),
				SA.Plugins.MySQL:Escape(text)
			)
		)
	end)
	local fileName = os.date("!SALogs/%m-%d-%y.txt")
	if(file.Exists(fileName, "DATA")) then
		self._logFile = file.Open(fileName, "ab", "DATA")
	else
		self._logFile = file.Open(fileName, "rb", "DATA")
	end
	lastDay = os.date("!%d")
end

function PLUGIN:OnDisable()
	hook.Remove("PlayerSay", "SAChatLog")
end

SA:RegisterPlugin(PLUGIN)