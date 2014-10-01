local PLUGIN = Plugin("Resources", {""})
PLUGIN._resources = {} -- id, name, basevalue
PLUGIN._nodes = {}
function PLUGIN:RegisterNode(node)
	table.insert(self._nodes, node)
end

function PLUGIN:OnEnable()
	net.Receive("SARDTick", function()
		for _, node in next, self._nodes do
			node:RDTick()
		end
		SA:CallEvent("SARDTick")
	end)
	net.Receive("SAResourceList", function(len)
		local count = net.ReadUInt(16)
		for i=1, count do
			self._resources[net.ReadUInt(16)] = {
				name = net.ReadString(),
				baseValue = net.ReadFloat(),
				weight = net.ReadFloat()
			}
		end
	end)
	
	net.Receive("SANodeUpdate", function(len)
		len = (len-16)/48
		if(len%48 ~= 0) then
			print("RECEIVED MALFORMED PACKET!")
			return
		end
		local node = net.ReadEntity()
		for i = 1, len do
			node._resources[net.ReadUInt(16)] = net.ReadUInt(32)
		end
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAResourceList", nil)
end

function PLUGIN:GetResource(resID)
	return self._resources[resID]
end

SA:RegisterPlugin(PLUGIN)