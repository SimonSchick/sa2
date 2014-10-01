local PLUGIN = Plugin("Storagebackup", {
	"Playerdata",
	"MySQL"
})

function PLUGIN:OnEnable()
	util.AddNetworkString("SAStorageBackupNotice")
	local function _storageBackupLoaded(isok, data, ply)
		if(not isok or not data or not data[1]) then
			net.Start("SAStorageBackupNotice")
				for i = 1, #data do
					net.WriteUInt(data[i].resourceid, 32)
					net.WriteUInt(data[i].value, 32)
				end
			net.Send(ply)
		end
	end

	SA:AddEventListener("PlayerLoaded", "StorageBackup", function(ply)
		SA.Plugins.MySQL:Query(
			string.format(
				"SELECT `resourceid`, `value` FROM `sa_storage_backup` WHERE `playerid` = '%u';",
				ply.__SAPID
			),
			_storageBackupLoaded
		)
	end)
	
	SA.Plugins.Systimer:CreateTimer("StorageBackup", 0, 60, function()
		local plyValues = {}
		for _, ent in next, SA.Plugins.Resources:GetNodes() do
			local plyTbl = {}
			for resID, val in next, ent:GetResources() do
				if(not plyTbl[resID]) then
					plyTbl[resID] = 0
				end
				plyTbl[resID] = plyTbl[resID] + val
			end
			plyValues[ent.__SAPP.owner] = plyTbl
		end
		local buildStr = {"DELETE FROM `sa_storage_backup` WHERE"}
		local isFirst = true
		for ply in next, plyValues do
			if(not isFirst) then
				buildStr[#buildStr+1] = " OR "
			end
			isFirst = false
			buildStr[#buildStr+1] = "`playerid` = '"..tostring(ply.__SAPID).."'"
		end
		buildStr[#buildStr+1] = ";"
		--SA.Plugins.MySQL:Query(table.concat(buildStr))
		--SA.Plugins.MySQL:Query("UPDATE `sa_storage_backup`
	end)
end

function PLUGIN:OnDisable()
	SA.Plugins.Systimer:RemoveTimer("StorageBackup")
end

SA:RegisterPlugin(PLUGIN)