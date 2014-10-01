local PLUGIN = Plugin("Factions", {"MySQL", "Playerdata"})

function PLUGIN:OnEnable()
	util.AddNetworkString("SAFactionList")
	
	local function _factionMemberCountLoaded(isok, data)
		if not isok then
			return
		end
		for _, row in next, data do
			self._factions[row.factionid].count = row.count
		end
	end
	
	local function _factionsLoaded(isok, data)
		if not isok then
			return
		end
		local c = 0
		self._factions = {}
		for _, row in next, data do
			team.SetUp(row.id, row.name, Color(row.red, row.green, row.blue,255))
			row.count = 0
			self._factions[row.id] = row
			row.id = nil
			c = c + 1
		end
		self._factionCount = c
		SA.Plugins.MySQL:Query(
[[SELECT `current_faction` as `factionid`, COUNT(`playerid`) AS `count` FROM `sa_player`
GROUP BY `current_faction`;]],
			_factionMemberCountLoaded
		)
	end
	
	SA:AddEventListener("DatabaseConnect", "Factions", function()
		SA.Plugins.MySQL:Query(
			"SELECT `factionid` as `id`, `name`, `description`, `red`, `green`, `blue` FROM `sa_faction`;",
			_factionsLoaded
		)

		local function _playerFactionLoaded(ply, val)
			if(val ~= 0) then
				ply:SetTeam(val)
				return
			end
			SA.Plugins.MySQL:Query(
				string.format(
[[INSERT INTO `sa_faction_membership` (`factionid`, `playerid`, `join_time`)
VALUES('3', '%u', UNIX_TIMESTAMP());]],
					ply.__SAPID
				)
			)
			
			SA.Plugins.MySQL:Query(
				string.format(
					"UPDATE `sa_player` SET `current_faction` = '%u' WHERE `playerid` = '%u';",
					3,
					ply.__SAPID
				)
			)
			
			ply:SetTeam(3)
		end
		
		SA.Plugins.Playerdata:RegisterCallback("current_faction", _playerFactionLoaded, function(ply)
			return tostring(ply:Team())
		end)
			
		SA:AddEventListener("PlayerLoaded", "Factions", function(ply)
			SA.Plugins.MySQL:Poll()
			net.Start("SAFactionList")
				net.WriteUInt(self._factionCount, 8)
				for factionID, tbl in next, self._factions do
					net.WriteUInt(factionID, 8)
					net.WriteString(tbl.name)
					net.WriteString(tbl.description)
					net.WriteUInt(tbl.red, 8)
					net.WriteUInt(tbl.green, 8)
					net.WriteUInt(tbl.blue, 8)
					net.WriteUInt(tbl.count, 16)
				end
			net.Send(ply)
		end)
	end)
	
	util.AddNetworkString("SAFactionMemberQuery")
	util.AddNetworkString("SAFactionMemberResponse")
	local function _onMembersGet(isok, data, ply, indentifier)
		if(not isok) then
			return
		end
		net.Start("SAFactionMemberResponse")
			net.WriteUInt(indentifier, 16)
			
		net.Send(ply)
	end
	
	SA.Plugins.Clientquery:RegisterQuery("FactionMembers", {
		interval = 5,
		receiver = function(len, ply, sender, token)
			SA.Plugins.MySQL:Query(
				string.format(
[[SELECT `sa_player`.`playerid`, `name`, `join_time` FROM `sa_player` LEFT JOIN `sa_faction_membership`
ON `sa_player`.`playerid` = `sa_faction_membership`.`playerid`
WHERE`current_faction` = '%u' ORDER BY `join_time` DESC;]],
					net.ReadUInt(8)
				),
				function(...) sender(token, ...) end,
				ply,
				net.ReadUInt(16)
			)
		end,
		sender = function(token)
			net.WriteUInt(#data, 16)
			for _, row in next, data do
				net.WriteUInt(row.playerid, 32)
				net.WriteString(row.name)
				net.WriteUInt(row.join_time or 0, 32)
				net.WriteUInt(row.rank or 0, 8)
			end
		end}
	)
	
	local meta = _R.Player
	
	function meta:SASetFaction(id)
		if(self:Team() == id) then
			return
		end
		self:SetTeam(id)
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_faction_membership` (`playerid`, `factionid`, `join_time`)
VALUES('%u', '%u', UNIX_TIMESTAMP());]],
				self.__SAPID,
				id
			)
		)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `current_faction` = '%u' WHERE `playerid` = '%u';",
				id,
				ply.__SAPID
			)
		)
	end
	
	function meta:SAQueryGroupHistory(callback)
	end
	
	util.AddNetworkString("SAFactionMenu")
	hook.Add("ShowTeam", "SAFactionMenu", function(ply)
		net.Start("SAFactionMenu")
		net.Send(ply)
		return true
	end)
end

function PLUGIN:OnDisable()
	SA.Plugins.Playerdata:RemoveCallback("current_faction")
	SA:RemoveEventListener("DatabaseConnect", "Factions")
	SA:RemoveEventListener("PlayerLoaded", "Factions")
	hook.Remove("ShowTeam", "SAFactionMenu")
end

function PLUGIN:GetFactions()
	return self._factions
end

function PLUGIN:GetFaction(id)
	return self._factions[id]
end

SA:RegisterPlugin(PLUGIN)