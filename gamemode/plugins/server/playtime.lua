local PLUGIN = Plugin("Playtime", {"Playerdata"})


function PLUGIN:OnEnable()
	util.AddNetworkString("SAPlayTime")
	util.AddNetworkString("SAPlayTimeUpdate")
	SA.Plugins.Playerdata:RegisterCallback("playtime", 
		function(ply, playtime)
			ply.__SAPlayTime = playtime
			ply.__SAJoinTime = os.time()
			net.Start("SAPlayTime")
				net.WriteEntity(ply)
				net.WriteUInt(playtime, 32)
			net.Broadcast()
			
			local plys = player.GetAll()
			
			net.Start("SAPlayTimeUpdate")
				net.WriteUInt(#plys-1, 8)
				for _, otherPly in next, plys do
					if(otherPly == ply) then
						continue
					end
					net.WriteEntity(otherPly)
					net.WriteUInt(otherPly.__SAPlayTime, 32)
				end
			net.Send(ply)
		end,
		function(ply)
			return tostring(ply.__SAPlayTime + (os.time() - ply.__SAJoinTime))
		end
	)
	
	function _R.Player:SAGetPlayTime()
		return self.__SAPlayTime + (os.time() - self.__SAJoinTime)
	end
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)