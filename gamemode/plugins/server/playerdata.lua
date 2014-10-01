local PLUGIN = Plugin("Playerdata", {"MySQL"})


util.AddNetworkString("SAPlayerDataStatus")
local function _sendPlayerMessage(ply)
	net.Start("SAPlayerDataStatus")
		net.WriteUInt(ply.__SAPID, 32)
		net.WriteString(ply.__SAUniqueToken)
	net.Send(ply)
end

local _playerLoadComplete

local function _createdDatabaseEntry(isok, data, ply)
	SA:Print("Created entry for player "..ply:Name().." !")
	SA.Plugins.MySQL:Query(
		string.format(
			"SELECT * FROM `sa_player` WHERE `steamid` = SteamToInt('%s');",
			SA.Plugins.MySQL:Escape(ply:SteamID())
		),
		_playerLoadComplete, ply
	)
end

local function _hex(str)
	return string.gsub(str, ".", function(s)
		return string.format("%02x", s:byte())
	end)
end

function _playerLoadComplete(isok, data, ply)
	if not ValidEntity(ply) then return end
	if isok and data and data[1] then
		data = data[1]
		ply.__SAPID = tonumber(data.playerid)
		ply.__SAUniqueToken = _hex(data.unique_token)
		for k, v in next, data do
			if(PLUGIN._columnLoadCallbacks[k]) then
				PLUGIN._columnLoadCallbacks[k](ply, v)
			end
		end
		_sendPlayerMessage(ply)
		ply.__SAIsLoaded = true
		SA:CallEvent("PlayerLoaded", ply)
	else
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_player` (`steamid`, `unique_token`)
VALUES(SteamToInt('%s'), UNHEX(SHA2('%s', 256)));]],
				SA.Plugins.MySQL:Escape(ply:SteamID()),
				SA.Plugins.MySQL:Escape(
					tostring(SysTime()+os.time()) .. 
					ply:SteamID() .. 
					ply:IPAddress() ..
					tostring(ply:Ping()*ply:PacketLoss()*math.random()) ..
					tostring(ply:TimeConnected() + ply:UserID()) .. 
					ply:Name()
				)
			),
			_createdDatabaseEntry,
			ply
		)
	end
end

function PLUGIN:GetLoadedPlayers()
	local ret = {}
	for k, v in next, player.GetAll() do
		if(not v.__SAIsLoaded) then
			continue
		end
		ret[#ret] = v
	end
	return ret
end
	
function PLUGIN:RegisterCallback(columnName, loadCallback, saveCallback)
	self._columnLoadCallbacks[columnName] = loadCallback
	self._columnSaveCallbacks[columnName] = saveCallback
end

function PLUGIN:RemoveCallback(columnName)
	self._columnLoadCallbacks[columnName] = nil
	self._columnSaveCallbacks[columnName] = nil
end

function PLUGIN:OnEnable()
	self._columnLoadCallbacks = {}
	self._columnSaveCallbacks = {}
	hook.Add("PlayerInitialSpawn", "SAPlayerData", function(ply)
		timer.Simple(2, function()
			ply.__SAIsLoaded = false
			SA.Plugins.MySQL:Query(
				string.format(
					"SELECT * FROM `sa_player` WHERE `steamid` = SteamToInt('%s');",
					SA.Plugins.MySQL:Escape(ply:SteamID())
				),
				_playerLoadComplete, ply
			)
		end)
	end)

	util.AddNetworkString("SAPlayerDataSaved")
	local function _savePlayer(ply)
		if not ply.__SAIsLoaded then
			return
		end
		
		SA:CallEvent("PrePlayerSave", ply)
		
		local len = table.Count(self._columnSaveCallbacks)
		local i = 0
		local queryString = {}
		local res
		for k, v in next, self._columnSaveCallbacks do
			i = i + 1
			res = v(ply)
			if(not res) then
				continue
			end
			if(i ~= len) then
				table.insert(queryString, string.format("`%s` = '%s', ", k, v(ply)))
			else
				table.insert(queryString, string.format("`%s` = '%s'", k, v(ply)))
			end
		end
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET %s WHERE `playerid` = '%u';",
				table.concat(queryString),
				ply.__SAPID
			)
		)
		net.Start("SAPlayerDataSaved")
		net.Send(ply)
		SA:CallEvent("PostPlayerSave", ply)
	end
	
	_R.Player.SASave = _savePlayer
	
	hook.Add("PlayerDisconnect", "SAPlayerData", _savePlayer)

	local function _saveAllPlayers()
		local plys = player.GetAll()
		if(#plys ~= 0) then
			SA:CallEvent("PreAllPlayerSave")
			for k, v in next, plys do
				_savePlayer(v)
			end
			SA:CallEvent("PostAllPlayerSave")
		end
	end
	timer.Create("SAPlayerSaving", 60, 0, _saveAllPlayers)
	
	hook.Add("ShutDown", "SAPlayerData", _saveAllPlayers)
end

function PLUGIN:OnDisable()
	timer.Remove("SAPlayerSaving")
	
	hook.Remove("PlayerInitialSpawn", "SAPlayerData")
	
	hook.Remove("ShutDown", "SAPlayerData")
	
	_R.Player.SASave = nil
end

SA:RegisterPlugin(PLUGIN)