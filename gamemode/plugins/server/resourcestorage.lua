local PLUGIN = Plugin("Resourcestorage", {"MySQL", "Playerdata", "Resources"})


function PLUGIN:OnEnable()
	SA.Plugins.Playerdata:RegisterCallback("storage_capacity", 
		function(ply, val)
			ply.__SAStorage = {
				capacity = tonumber(val),
				contents = {}
			}
		end,
		function(ply)
			return tostring(ply.__SAStorage.capacity)
		end
	)
	
	local function _resourceStorageLoaded(isok, data, ply)
		if(not isok) then
			return
		end
		local ref = ply.__SAStorage.contents
		for _, row in next, data do
			ref[tonumber(row.resourceid)] = tonumber(row.amount)
		end
	end
	
	SA:AddEventListener("PlayerLoaded", "ResourceStorage", function(ply)
		SA.Plugins.MySQL:Query(
			string.format(
				"SELECT `resourceid`, `amount` FROM `sa_resource_storage` WHERE `playerid` = '%u';",
				ply.__SAPID
			),
			_resourceStorageLoaded,
			ply
		)
	end)
	
	local meta = _R.Player
	
	local function trimStorageTo(ply, stor)
		local resCount = 0
		local total = 0
		local ref = ply.__SAStorage.contents
		for _, val in next, ref do	
			total = total + val
			resCount = resCount + 1
		end
		if(resCount <= stor) then
			return
		end
		local avg = total/resCount
		for k, v in next, ref do
			ref[k] = math.min(v, avg)
		end
		SA.Plugins.MySQL:Query(
			string.format(
[[UPDATE `sa_resource_storage` SET `amount` = LEAST('%u', `amount`) WHERE `playerid` = '%u';]],
				avg,
				ply.__SAPID
			)
		)
	end
	
	function meta:SASetStorageCapacity(cap)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `storage_capacity` = '%u' WHERE `playerid` = '%u';",
				cap,
				self.__SAPID
			)
		)
		trimStorageTo(self, cap)
	end
	
	function meta:SAAddStorageCapacity(cap)
		local new = self.__SAStorage.Capacity+cap
		self.__SAStorage.Capacity = new
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `storage_capacity` = '%u' WHERE `playerid` = '%u';",
				new,
				ply.__SAPID
			)
		)
	end
	
	function meta:SARemoveStorageCapacity(cap)
		local new = self.__SAStorage.Capacity-cap
		self.__SAStorage.Capacity = new
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `storage_capacity` = '%u' WHERE `playerid` = '%u';",
				new,
				ply.__SAPID
			)
		)
		trimStorageTo(self, cap)
	end
	
	function meta:SAAddResourceToStorage(resID, amount)
		self.__SAStorage.contents[resID] = self.__SAStorage.contents[resID] + new
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_resource_storage` (`playerid`, `resourceid`, `amount`)
VALUES ('%u', '%u', '%u') ON DUPLICATE KEY UPDATE `amount`= VALUES(`amount`);]],
				self.__SAPID,
				resID,
				currAmount - amount 
			)
		)
	end
end

function PLUGIN:OnDisable()
	SA.Plugins.Playerdata:RemoveCallback("storage_capacity")
end

SA:RegisterPlugin(PLUGIN)