local PLUGIN = {
	Name="Credits",
	Dependencies = {
		"MySQL",
		"Playerdata",
		"Systimer"
	}
}

function PLUGIN:OnEnable()
	SA.Plugins.Playerdata:RegisterCallback("credits",
		function(ply, credits)
			ply.__SACredits = tonumber(credits)
		end,
		function(ply)
			return tostring(ply.__SACredits)
		end
	)
	
	SA.Plugins.Playerdata:RegisterCallback("score",
		function(ply, score)
			ply.__SAScore = tonumber(score)
		end,
		function(ply)
			return tostring(ply.__SAScore)
		end
	)

	util.AddNetworkString("SACreditsUpdate")
	util.AddNetworkString("SAScoreUpdate")

	local function _updateCreditsScore(ply)
		net.Start("SACreditsUpdate")
			net.WriteDouble(ply.__SACredits)
		net.Send(ply)
		net.Start("SAScoreUpdate")
			net.WriteEntity(ply)
			net.WriteDouble(ply.__SAScore)
		net.Broadcast()
	end
	
	SA:AddEventListener("PlayerLoaded", "SendCredits", _updateCreditsScore)
	
	local plyMeta = _R.Player

	function plyMeta:SAAddScore(num)
		if num < 0 then return end
		self.__SAScore = self.__SAScore + math.floor(num)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `score` = '%u' WHERE `playerid` = '%u';",
				self.__SAScore,
				self.__SAPID
			)
		)
		_updateCreditsScore(self)
	end

	function plyMeta:SAAddCredits(num)
		if num < 0 then return end
		self.__SACredits = self.__SACredits + math.floor(num)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `credits` = '%u' WHERE `playerid` = '%u';",
				self.__SACredits,
				self.__SAPID
			)
		)
		_updateCreditsScore(self)
	end

	function plyMeta:SAGetScore()
		return self.__SAScore
	end

	function plyMeta:SAGetCredits()
		return self.__SACredits
	end

	function plyMeta:SATakeCredits(num)
		if num < 0 then return end
		if self.Credits < num then return false end
		self.__SACredits = self.__SACredits - math.floor(num)
		SA.Plugins.MySQL:Query(
			string.format(
				"UPDATE `sa_player` SET `credits` = '%u' WHERE `playerid` = '%u';",
				self.__SACredits,
				self.__SAPID
			)
		)
		_updateCreditsScore(self)	
		return true
	end

	function plyMeta:SAHasCredits(num)
		return self.__SACredits >= num
	end
	
	function plyMeta:SASendCredits(ply, num)
		if(self.__SACredits < num) then
			return false
		end
		self.__SACredits = self.__SACredits - num
		ply.__SACredits = SACredits + num
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_credit_transfer` `serverid`, `receiverid`, `amount`, `timestamp`
VALUES('%u', '%u', '%u', UNIX_TIMESTAMP();
UPDATE `sa_player` SET `credits` = '%u' WHERE `playerid` = '%u';
UPDATE `sa_player` SET `credits` = '%u' WHERE `playerid` = '%u';
]],
				self.__SAPID,
				ply.__SAPID,
				num,
				self.__SACredits,
				self.__SAPID,
				ply.__SACredits,
				ply.__SAPID
			)
		)
		_updateCreditsScore(self)
		_updateCreditsScore(ply)
	end
	
	
end

function PLUGIN:OnDisable()
	SA.Plugins.Playerdata:RemoveCallback("credits")
	SA.Plugins.Playerdata:RemoveCallback("score")
	SA:RemoveEventListener("PlayerLoaded", "SendCredits")
	
	local plyMeta = _R.Player

	plyMeta.SAAddScore = nil
	plyMeta.SAAddCredits = nil
	plyMeta.SAGetScore = nil
	plyMeta.SAGetCredits = nil
	plyMeta.SATakeCredits = nil
	plyMeta.SAHasCredits = nil
	plyMeta.SASendCredits = nil
end

SA:RegisterPlugin(PLUGIN)