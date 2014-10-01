local PLUGIN = Plugin("Research", {""})
PLUGIN._available = {}
PLUGIN._done = {}
PLUGIN._running = {}
PLUGIN._paused = {}

function PLUGIN:GetAll()
	return {}
end

function PLUGIN:OnEnable()
	local receivedPackets = 0
	net.Receive("SASendResearches", function(len)
		for i = 1, net.ReadUInt(8) do
			self._available[net.ReadUInt(i, 32)] = {
				category = net.WriteUInt(32),
				name = net.WriteString(),
				runtime = net.WriteUInt(32),
				description = net.WriteString(),
				maxLevel = net.WriteUInt(32),
				baseCost = net.WriteUInt(32)
			}
		end
	end)

	net.Receive("SASendPlayerResearches", function()
		for i = 1, net.ReadUInt(16) do
			self._done[net.ReadUInt(32)] = {
				level = net.ReadUInt(32),
				paidCredits = net.ReadUInt(32),
				completionTime = net.ReadUInt(32)
			}
		end
		for i = 1, net.ReadUInt(16) do
			self._running[net.ReadUInt(32)] = {
				level = net.ReadUInt(32),
				paidCredits = net.ReadUInt(32),
				completionTime = net.ReadUInt(32),
				startTime = net.ReadUInt(32),
				endTime = net.ReadUInt(32)
			}
		end
		for i = 1, net.ReadUInt(16) do
			self._paused[net.ReadUInt(32)] = {
				level = net.ReadUInt(32),
				paidCredits = net.ReadUInt(32),
				completionTime = net.ReadUInt(32),
				startTime = net.ReadUInt(32),
				pauseTime = net.ReadUInt(32),
				endTime = net.ReadUInt(32)
			}
		end
	end)
	
	net.Receive("SASendResearchDependencies", function()
		local total = net.ReadUInt(16)
		for i = 1, total do
			local researchID = net.ReadUInt(32)
			local dependenceCount = net.ReadUInt(8)
			for j = 1, dependenceCount do
				local dependenceID = net.ReadUInt(32)
			end
		end
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SASendResearches", nil)
	net.Receive("SASendPlayerResearches", nil)
	net.Receive("SASendResearchDependencies", nil)
end
SA:RegisterPlugin(PLUGIN)