local PLUGIN = Plugin("Playerbackpack", {"MySQL", "Playerdata"})


function PLUGIN:OnEnable()
	local function _backPackLoaded(isok, data, ply)
		if(not isok) then
			return
		end
		local ref = ply.__SABackPack.contents
		for _, row in next, data do
			ref[tonumber(data.resourceid)] = tonumber(data.amount)
		end
		SA:CallEvent("PlayerBackPackLoaded", ply)
	end
	SA:AddEventListener("PlayerLoaded", "PlayerBackPack", function(ply)
		SA.Plugins.MySQL:Query(
			string.format(
				"SELECT `resourceid`, `amount` FROM `sa_resource_backpack` WHERE `playerid` = '%u';",
				ply.__SAPID
			),
			_backPackLoaded,
			ply
		)
	end)
	SA.Plugins.Playerdata:RegisterCallback("backpack_capacity", 
		function(ply, val)
			ply.__SABackPack = {
				maxWeight = tonumber(val),
				contents = {}
			}
		end,
		function(ply)
			return tostring(ply.__SABackPack.maxWeight)
		end
	)
	
	local meta = _R.Player
	
	function meta:SAAddBackPackResource(resID, amount)
		amount = math.min(
			(self.__SABackPack.contents[resID] or 0) + amount,
			self.__SABackPack.maxWeight
		)
		SA.Plugins.MySQL:Query(
			string.format(
				[[INSERT INTO `sa_resource_backpack` (`playerid`, `resourceid`, `amount`)
				VALUES ('%u', '%u', '%u') ON DUPLICATE KEY UPDATE `amount`= VALUES(`amount`);]],
				self.__SAPID,
				resID,
				amount 
			)
		)
		self.__SABackPack.contents[resID] = amount
	end
	
	function meta:SASetBackPackResource(resID, amount)
		amount = math.min(amount, self.__SABackPack.maxWeight)
		SA.Plugins.MySQL:Query(
			string.format(
				[[INSERT INTO `sa_resource_backpack` (`playerid`, `resourceid`, `amount`)
				VALUES ('%u', '%u', '%u') ON DUPLICATE KEY UPDATE `amount` = VALUES(`amount`);]],
				self.__SAPID,
				resID,
				amount 
			)
		)
		self.__SABackPack.contents[resID] = amount
	end
	
	function meta:SARemoveBackPackResource(resID, amount)
		local currAmount = self.__SABackPack.contents[resID]
		if(not currAmount or amount > currAmount) then
			return false
		end
		SA.Plugins.MySQL:Query(
			string.format(
				[[INSERT INTO `sa_resource_backpack` (`playerid`, `resourceid`, `amount`)
				VALUES ('%u', '%u', '%u') ON DUPLICATE KEY UPDATE `amount`= VALUES(`amount`);]],
				self.__SAPID,
				resID,
				currAmount - amount 
			)
		)
		self.__SABackPack.contents[resID] = currAmount - amount
	end
	
	function meta:SAHasBackPackResource(resID, amount)
		local currAmount = self.__SABackPack.contents[resID]
		return (not currAmount) or (currAmount < amount)
	end
	
	
	
	function meta:AddBackPackCapacity(amount)
		local new = self.__SABackPack.maxWeight + amount
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `backpack_capacity` = '%u' WHERE `playerid` = '%u';",
				self.__SAPID,
				new
			)
		)
		self.__SABackPack.maxWeight = new
	end
	
	function meta:RemoveBackPackCapacity(amount)
		local new = math.max(self.__SABackPack.maxWeight + amount, 0)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `backpack_capacity` = '%u' WHERE `playerid` = '%u';",
				self.__SAPID,
				new
			)
		)
		self.__SABackPack.maxWeight = new
	end
	
	function meta:SetBackPackCapacity(amount)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `backpack_capacity` = '%u' WHERE `playerid` = '%u';",
				self.__SAPID,
				amount
			)
		)
		self.__SABackPack.maxWeight = amount
	end
end

function PLUGIN:OnDisable()
	SA:RemoveEventListener("PlayerLoaded", "PlayerBackPack")
	SA.Plugins.Playerdata:RemoveCallback("backpack_capacity")
	
	for _, ply in next, player.GetAll() do
		ply.__SABackPack = nil
	end
end

SA:RegisterPlugin(PLUGIN)