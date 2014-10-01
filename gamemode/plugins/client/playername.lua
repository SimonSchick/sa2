local PLUGIN = Plugin("Playername", {"Playerdata"})

function PLUGIN:OnEnable()
	local meta = _R.Player
	
	net.Receive("SAPlayername", function()
		net.ReadEntity().__SACleanName = net.ReadString()
	end)
	
	net.Receive("SAPlayernameUpdate", function(len)
		for i = 1, net.ReadUInt(8) do
			net.ReadEntity().__SACleanName = net.ReadString()
		end
	end)
	
	function meta:SAGetCleanName()
		return self.__SACleanName
	end
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)