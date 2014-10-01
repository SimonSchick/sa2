local PLUGIN = Plugin("SAAdmin", {
	"MySQL",
	"Playerdata",
	"Topbar"
})

function PLUGIN:AddChatCommand(cmd, callback)
	self._chatCommands[cmd] = callback
end

local function _onGroupIDReceived(isok, data, callback, name, immunity)
	if(isok) then
		PLUGIN._groups[data[1].insertid] = {name = name, immunity = immunity}
		if(callback) then
			callback(data[1].insertid)
		end
		return
	end
	if(callback) then
		callback(false)
	end
end

local function _onGroupAdded(isok, data, callback, name, immunity)
	if(isok) then
		SA.Plugins.MySQL:Query(
			"SELECT LAST_INSERT_ID() AS `insertid` FROM `saa_group`;",
			_onGroupIDReceived,
			callback,
			name,
			immunity
		)
		return
	end
	if(callback) then
		callback(false)
	end
end

function PLUGIN:AddGroup(name, immunity, callback)
	if(self._groups[name]) then
		return false
	end
	SA.Plugins.MySQL:Query(
		string.format(
			"INSERT INTO `saa_group` (`name`, `immunity`) VALUES('%s', '%u');",
			name,
			immunity
		),
		_onGroupAdded,
		callback,
		name,
		immunity
	)
end

function PLUGIN:RemoveGroup(groupID)
	SA.Plugins.MySQL:Query(
		string.format(
			"DELETE FROM `saa_group` WHERE `groupid` = '%u';",
			groupID
		)
	)
	self._groups[groupID] = nil
	--TODO: DELETE PLAYER STUFF
end

function PLUGIN:SetGroupImmunity(groupID, immunity)
	SA.Plugins.MySQL:Query(
		string.format(
			"UPDATE `saa_group` SET `immunity` = '%u' WHERE `groupid` = '%u'",
			immunity,
			groupID
		)
	)
end

function PLUGIN:OnEnable()
	SAA = self
	
	local function _permissionsLoaded(isok, data)
		if(not isok) then
			return
		end
		self._permissions = {}
		for i = 1, #data do
			self._permissions[data[i].permissionid] = {
				name = data[i].name,
				description = data[i].description
			}
		end
	end
	
	local function _groupsLoaded(isok, data)
		if(not isok) then
			return
		end
		self._groups = {}
		for i = 1, #data do
			self._groups[data[i].groupid] = {
				name = data[i].name,
				immunity = data[i].immunity
			}
		end
	end
	
	local function _eventsLoaded(isok, data)
		if(not isok) then
			return
		end
		self._events = {}
		for i = 1, #data do
			self._events[data[i].eventid] = {
				name = data[i].event_name,
			}
		end
	end
	
	local function _groupPermissionsLoaded(isok, data)
		if(not isok) then
			return
		end
		for i = 1, #data do
			if(not self._groups[data[i].groupid]._permissions) then
				self._groups[data[i].groupid]._permissions = {}
			end
			table.insert(self._groups[data[i].groupid]._permissions, data[i].permissionid)
		end
	end
	SA:AddEventListener("DatabaseConnect", "LoadSAAPermissions", function()
		--permissions
		SA.Plugins.MySQL:Query(
			"SELECT `permissionid`, `name`, `description` FROM `saa_permission`;",
			_permissionsLoaded
		)
		--groups
		SA.Plugins.MySQL:Query(
			"SELECT `groupid`, `name`, `immunity` FROM `saa_group`;",
			_groupsLoaded
		)
		--events
		SA.Plugins.MySQL:Query(
			"SELECT `eventid`, `event_name` FROM `saa_event`;",
			_eventsLoaded
		)
		--group permissionss
		SA.Plugins.MySQL:Query(
			"SELECT `groupid`, `permissionid` FROM `saa_groupxpermission`;",
			_groupPermissionsLoaded
		)
	end)
	
	local function _playerGroupLoaded(isok, data, ply)
		if(not isok or #data == 0) then
			return
		end
		ply.__SAAdmin._groupID = data[1].groupid

		ply.__SAAGroupsLoaded = true
		if(ply.__SAAPermissionsLoaded) then
			SA:CallEvent("SAAPlayerLoaded", ply)
			ply.__SAAGroupsLoaded = nil
			ply.__SAAPermissionsLoaded = nil
		end
	end
	
	local function _playerPermissionsLoaded(isok, data, ply)
		if(not isok) then
			return
		end
		local perms = {}
		for i = 1, #data do
			perms[data[i]._permissionID] = true
		end
		ply.__SAAdmin._permissionIDs = perms
		
		ply.__SAAPermissionsLoaded = true
		if(ply.__SAAGroupsLoaded) then
			SA:CallEvent("SAAPlayerLoaded", ply)
			ply.__SAAGroupsLoaded = nil
			ply.__SAAPermissionsLoaded = nil
		end
	end
	
	SA:AddEventListener("PlayerLoaded", "LoadSAAPlayerPermissions", function(ply)
		ply.__SAAGroupsLoaded = false
		ply.__SAAPermissionsLoaded = false
		
		SA.Plugins.MySQL:Query(
			string.format(
[[SELECT `groupid` FROM `saa_playerxgroup` WHERE `playerid` = '%u'
ORDER BY `timestamp` DESC LIMIT 1;]],
				ply.__SAPID
			),
			_playerGroupLoaded,
			ply
		)
		
		SA.Plugins.MySQL:Query(
			string.format(
				"SELECT `permissionid` FROM `saa_playerxpermission` WHERE `playerid` = '%u';",
				ply.__SAPID
			),
			_playerPermissionsLoaded,
			ply
		)
	end)
	
	self._chatCommands = {}
	
	local chatCommandIdentifier = {
		["!"] = true,
		["~"] = true,
		["$"] = true
	}
	
	local args, len, c, findPos, i, lastStop
	hook.Add("PlayerSay", "SAAdmin", function(ply, txt, isPulbic)
		local identifier = txt:sub(1, 1)
		if(chatCommandIdentifier[identifier]) then
			txt = txt:sub(2):gsub("%s+", " ")
			args = {}
			len = txt:len()
			i = 1
			lastStop = 1
			while i <= len do
				c = txt:sub(i, i)
				if(c == '"' or c == "'") then
					findPos = txt:find(c, i+1, true)
					if(findPos) then
						table.insert(args, txt:sub(i+1, findPos-1))
						i = findPos+2
						lastStop = i
						continue
					end
				end
				if(i == len) then
					table.insert(args, txt:sub(lastStop, i))
					break
				end
				if(c == " ") then
					table.insert(args, txt:sub(lastStop, i-1))
					lastStop = i + 1
				end
				i = i + 1
			end
			local cmdTbl = self._chatCommands[table.remove(args, 1)]
			if(cmdTbl) then
				cmdTbl(ply, txt, args)
			end
			return ""
		end
	end)
	SA.Plugins.Playerdata:RegisterCallback("immunity", function(ply, level)
		ply.__SAAdmin = {immunity = level}
	end)
		
	
	
	--meta mods
	local meta = _R.Player
	
	function meta:SAAHasPermission(permID)
		return (self.__SAAdmin._permissionIDs[permID]) or
		(PLUGIN._groupPermissions[self.__SAAdmin._groupid][permID])
	end
	
	function meta:SAAAddPermission(permID)
		if(self.__SAAdmin._permissionIDs[permID]) then
			return
		end
		self.__SAAdmin._permissionIDs[permID] = true
		SA.Plugins.MySQL:Query(
			string.format(
				"INSERT INTO `saa_playerxpermission` (`playerid`, `permissionid`) VALUES('%u', '%u');",
				self.__SAPID,
				permID
			)
		)
	end
	
	function meta:SAARemovePermission(permID)
		if(not self.__SAAdmin._permissionIDs[permID]) then
			return
		end
		self.__SAAdmin._permissionIDs[permID] = nil
		SA.Plugins.MySQL:Query(
			string.format(
				"DELETE FROM `saa_playerxpermission` WHERE `playerid` = '%u' AND `permissionid` = '%u'",
				self.__SAPID,
				permID
			)
		)
	end
	
	function meta:SAAAddPermission(permID)
		if(self.__SAAdmin._permissionIDs[permID]) then
			return
		end
		self.__SAAdmin._permissionIDs[permID] = true
		SA.Plugins.MySQL:Query(
			string.format(
				"DELETE FROM `saa_playerxpermission` WHERE `playerid` = '%u' AND `permissionid` = '%u';",
				self.__SAPID,
				permID
			)
		)
	end
	
	function meta:SAASetImmunity(level)
		level = math.Clamp(level, 0, 100)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `immunity` = '%u' WHERE `playerid` = '%u';",
				level,
				self.__SAPID
			)
		)
		self.__SAAdmin.immunity = level
	end
	
	function meta:SAAGetImmunity(level)
		return math.max(
			self.__SAAdmin.immunity,
			PLUGIN._groups[self.__SAAdmin._groupid].immunity
		)
	end
	
	function meta:SAASetGroup(groupID)
		self.__SAAdmin.group = groupID
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `saa_playerxgroup` (`playerid`, `groupid`, `timestamp`) 
VALUES('%u', '%u', UNIX_TIMESTAMP());]],
				self.__SAPID,
				groupID
			)
		)
	end
	
	function meta:SAAGetGroup()
		return self.__SAAdmin.group
	end
	
	local function _onGroupHistoryGet(isok, data, ply, callback)
		if(isok) then
			callback(ply, data)
			return
		end
		callback(ply, false)
	end
	
	function meta:SAAGetGroupHistory(callback)
		SA.Plugins.MySQL:Query(
			string.format(
				"SELECT `groupid` AS `groupID`, `timestamp` FROM `saa_playerxgroup` WHERE `playerid` = '%u';",
				self.__SAPID
			),
			_onGroupHistoryGet,
			self,
			callback
		)
	end
	
	function meta:SAALogEvent(eventID)
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `saa_playerxevent` (`playerid`, `eventid`, `timestamp`) 
VALUES('%u', '%u', UNIX_TIMESTAMP());]],
				self.__SAPID,
				eventID
			)
		)
	end
end

function PLUGIN:OnDisable()
	hook.Remove("PlayerSay", "SAAdmin")
	SA:RemoveEventListener("PlayerLoaded", "LoadSAAPlayerPermissions")
	SA:RemoveEventListener("DatabaseConnect", "LoadSAAPermissions")
	
	SA.Plugins.Playerdata:RemoveCallback("immunity")
	
	for k, v in next, player.GetAll() do
		v.__SAAdmin = nil
	end
end

SA:RegisterPlugin(PLUGIN)