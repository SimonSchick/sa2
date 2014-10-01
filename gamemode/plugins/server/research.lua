local PLUGIN = Plugin("Research", {"MySQL", "Playerdata"}, {"gatekeeper"})


--POLLING ALL RESEARCHES
local function _pollCallback(isok, data)
	if(not status) then
		return
	end
	local row
	for i = 1, #data do
		row = data[i]
		PLUGIN._available[tonumber(row.researchid)] = {
			category = row.category,
			name = row.name,
			runtime = tonumber(row.runtime),
			description = row.description,
			maxLevel = tonumber(row.max_level),
			baseCost = tonumber(row.basecost),
			dependencies = {}
		}
	end
end

local function _pollDepedenciesCallback(isok, data)
	if(not status) then
		return
	end
	for i = 1, #data do
		table.insert(
			_available[tonumber(data[i].researchid)].dependencies,
			tonumber(data[i].depedenceid)
		)
	end
end

function PLUGIN:_pollResearches()
	--WAIT QUERY NEEDED IN ORDER TO MAKE ABSOLUTELY SURE THE DEPENDENCIES ARE LOADED AFTER!
	SA.Plugins.MySQL:QueryWait(
[[SELECT `researchid`, `subcategoryid`, `name`, `runtime`, `description`, `max_level`, `basecost`
FROM `sa_research`]],
		_pollCallback
	)
	SA.Plugins.MySQL:Query(
		"SELECT `researchid`, `dependenceid`  FROM `sa_research_dependency`",
		_pollDepedenciesCallback
	)
end
--END POLLING ALL RESEARCHES



--ALL PLAYER POLLING

--POLLING RUNNING RESEARCHES
local function _pollAllRunningCallback()
	SA:CallEvent("PlayerResearchesUpdated")
end

function PLUGIN:_pollRunningResearches()
	local tbl = player.GetAll()
	local len = #tbl
	
	local buildString = {
[[SELECT `playerid`, `researchid`, `paid_credits`, `level`, `start_time`, `end_time` 
FROM `sa_playerxresearchrunning` WHERE ]]
	}
	for i = 1, #len do
		table.insert(buildString, "`pid` = '")
		table.insert(buildString, tostring(v.__SAPID))
		if(i ~= len) then
			table.insert(buildString, "' OR")
		else
			table.insert(buildString, "';")
		end
	end
	SA.Plugins.MySQL:Query(table.concat(buildString), _pollAllRunningCallback)
end
--END RUNNING RESEARCHES

--END ALL PLAYER POLLING

--PER PLAYER POLLING

--POLLING DONE RESEARCHES
util.AddNetworkString("SASendResearches")
local function _sendResearches(ply)
	ply.__SAResearch._doneLoaded = nil
	ply.__SAResearch._runningLoaded = nil
	ply.__SAResearch._pausedLoaded = nil
	local packets = table.Count(PLUGIN._available)/11
	if(packets == 0) then
		return
	end
	local cur = 1
	local avail = PLUGIN._available
	timer.Create("SASendResearches"..tostring(ply.__SAPID), 2, packets, function()
		net.Start("SASendResearches")
			net.WriteUInt(math.min(packets-curr), 8)
			for i = cur, math.min(cur + 11, packets) do
				net.WriteUInt(i, 32)
				net.WriteUInt(avail[i].category, 32)
				net.WriteString(avail[i].name)
				net.WriteUInt(avail[i].runtime, 32)
				net.WriteString(avail[i].description)
				net.WriteUInt(avail[i].maxLevel, 32)
				net.WriteUInt(avail[i].baseCost, 32)
			end
			cur = cur + 11
		net.Send(ply)
	end)
end

local function _sendPlayerResearches(ply)
	net.Start("SASendPlayerResearches")
		local done = ply.__SAResearches.Done
		net.WriteUInt(table.Count(done), 16)
		for idx, tbl in next, done do
			net.WriteUInt(idx, 32)
			net.WriteUInt(tbl.level, 32)
			net.WriteUInt(tbl.paidCredits, 32)
			net.WriteUInt(tbl.completionTime, 32)
		end
		local running = ply.__SAResearches.Paused
		net.WriteUInt(#table.Count(running), 16)
		for idx, tbl in next, running do
			net.WriteUInt(idx, 32)
			net.WriteUInt(tbl.level, 32)
			net.WriteUInt(tbl.paidCredits, 32)
			net.WriteUInt(tbl.startTime, 32)
			net.WriteUInt(tbl.endTime, 32)
		end
		local paused = ply.__SAResearches.Done
		net.WriteUInt(#table.Count(paused), 16)
		for idx, tbl in next, paused do
			net.WriteUInt(idx, 32)
			net.WriteUInt(tbl.level, 32)
			net.WriteUInt(tbl.paidCredits, 32)
			net.WriteUInt(tbl.startTime, 32)
			net.WriteUInt(tbl.pauseTime, 32)
			net.WriteUInt(tbl.endTime, 32)
		end
	net.Send(ply)
end

util.AddNetworkString("SASendResearchDependencies")
local function _sendResearchDependencies(ply)
	net.Start("SASendResearchDependencies")
		for k, v in next, PLUGIN._available do
			--dependency count
			--research
			--depend1
			--depend2
		end
	net.Send(ply)
end

local function _pollPlayerCallback(isok, data, ply)
	for i = 1, #data do
		row = data[i]
		ply.__SAResearches.Done[tonumber(row.researchid)] = {
			currentLevel = tonumber(row.level),
			paidCredits = tonumber(row.paid_credits),
			completionTime = tonumber(row.completion_time)
		}
	end
	if(ply.__SAResearch._runningLoaded and ply.__SAResearch._pausedLoaded) then
		_sendPlayerResearches(ply)
	else
		ply.__SAResearch._doneLoaded = true
	end
end

function PLUGIN:_pollPlayerResearches(ply)
	SA.Plugins.MySQL:Query(
		string.format(
[[SELECT `researchid`, `paid_credits`, `level`, `completion_time`
FROM `sa_playerxresearch` WHERE `playerid` = '%u';]],
			ply.__SAPID
		),
		_pollPlayerCallback,
		ply
	)
end
--END POLLING DONE RESEARCHES

--POLLING RUNNING RESEARCHES
local function _pollPlayerRunningCallback(isok, data, ply)
	for i = 1, #data do
		row = data[i]
		ply.__SAResearches.Running[tonumber(row.researchid)] = {
			paidCredits = tonumber(row.paidcredits),
			currentLevel = tonumber(row.level),
			startTime = tonumber(row.start_time),
			endTime = tonumber(row.end_time)
		}
	end
	if(ply.__SAResearch._doneLoaded and ply.__SAResearch._pausedLoaded) then
		_sendPlayerResearches(ply)
	end
		ply.__SAResearch._RunningLoaded = true
end

function PLUGIN:_pollPlayerRunningResearches(ply)
	SA.Plugins.MySQL:Query(
		string.format(
[[SELECT `researchid`, `paid_credits`, `level`, `start_time`, `end_time`
FROM `sa_playerxresearchrunning` WHERE `playerid` = '%u';]],
			ply.__SAPID
		),
		_pollPlayerRunningCallback,
		ply
	)
end
--END POLLING RUNNING RESEARCHES

--POLLING PAUSED RESEARCHES
local function _pollPlayerPausedCallback(isok, data, ply)
	for i = 1, #data do
		row = data[i]
		ply.__SAResearches.Running[tonumber(row.researchid)] = {
			paidCredits = tonumber(row.paid_credits),
			currentLevel = tonumber(row.level),
			startTime = tonumber(row.start_time),
			pauseTime = tonumber(row.pause_time),
			endTime = tonumber(row.end_time)
		}
	end
	if(ply.__SAResearch._doneLoaded and ply.__SAResearch._runningLoaded) then
		_sendPlayerResearches(ply)
	end
	ply.__SAResearch._PausedLoaded = true
end

function PLUGIN:_pollPlayerPausedResearches(ply)
	SA.Plugins.MySQL:Query(
		string.format(
[[SELECT `researchid`, `paid_credits`, `level`, `start_time`, `pause_time`, `end_time`
FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u';]],
			ply.__SAPID
		),
		_pollPlayerPausedCallback,
		ply
	)
end
--END POLLING PAUSED RESEARCHES

--POLLING ALL KINDS OF RESEARCHES
function PLUGIN:_pollPlayerAllResearches(ply)
	SA.Plugins.MySQL:Query(
		string.format(
[[SELECT `researchid`, `paid_credits`, `level`, `start_time`, `pause_time`, `end_time`
FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u';]],
			ply.__SAPID
		),
		_pollPlayerPausedCallback,
		ply
	)
	SA.Plugins.MySQL:Query(
		string.format(
[[SELECT `researchid`, `paid_credits`, `level`, `start_time`, `pause_time`, `end_time`
FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u';]],
			ply.__SAPID
		),
		_pollPlayerPausedCallback,
		ply
	)
	SA.Plugins.MySQL:Query(
		string.format(
[[SELECT `researchid`, `paid_credits`, `level`, `start_time`, `end_time`
FROM `sa_playerxresearchrunning` WHERE `playerid` = '%u';]],
			ply.__SAPID
		),
		_pollPlayerRunningCallback,
		ply
	)
end
--END POLLING ALL KINDS OF RESEACHES

--END PER PLAYER POLLING
function PLUGIN:OnEnable()
	self._available = {}
	SA:AddEventListener("DatabaseConnect", "LoadResearches", function()
		self:_pollResearches()
	end)
	
	SA:AddEventListener("PlayerLoaded", "SAResearch", function(ply)
		ply.__SAResearch = {
			Done = {},
			Running = {},
			Paused = {}
		}
		ply.__SAResearch._doneLoaded = false
		ply.__SAResearch._runningLoaded = false
		ply.__SAResearch._pausedLoaded = false
		_sendResearches(ply)
		_sendResearchDependencies(ply)
		self:_pollPlayerAllResearches(ply)
	end)
	
	local time
	timer.Create("SAResearchTick", 1, 0, function()
		time = os.time()
		for _, ply in next, player.GetAll() do
			if(not ply.__SAResearch) then
				continue
			end
			for researchID, resTbl in next, ply.__SAResearch.Running do
				if(time >= resTbl.endTime) then
					resTbl.starTime = nil
					v.__SAResearches.Done = resTbl.Running
					v.__SAResearches.Running = nil
					
					SA.Plugins.MySQL:Query(--currTime + endTime - pausedTime
						string.format(
[[INSERT INTO `sa_playerxresearch` SELECT `playerid`, `researchid`, `paid_credits`, `level`,
UNIX_TIMESTAMP() AS `completion_time`,
FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u' AND `researchid` = '%u';
DELETE FROM `sa_playerxresearchrunning` WHERE `playerid` = '%u' AND `researchid` = '%u';]],
							ply.__SAPID,
							researchID,
							ply.__SAPID,
							researchID
						)
					)
					SA:CallEvent("PlayerResearchFinished", ply, researchID)
				end
			end
		end
	end)
	
	
	--PLAYER METHODES
	local plyMeta = _R.Player
	
	function plyMeta:SAPollResearches()
	
	end
	
	function plyMeta:SAGetCreditsForResearch(researchID)
		return 1
	end
	
	function plyMeta:SAGetResearchSpeedMultiplier(researchID)
		return 1
	end
	
	function plyMeta:SAGetResearchLevel(researchID)
		return self.__SAResearches[researchID].level
	end
	
	function plyMeta:SASetResearchLevel(researchID, newLevel)
		self.__SAResearch[researchID].newLevel = value
	end
	
	function plyMeta:SAStartResearch(researchID)
		local curUnixTime = os.time()
		local endUnixTime = curUnixTime+PLUGIN._available[researchID].runtime*
							ply:SAGetResearchSpeedMultiplier(researchID)
							
		local requiredCredits = self:SAGetCreditsForResearch(researchID)
		SA.Plugins.MySQL:Query(
			string.format([[
INSERT INTO `sa_playerxresearchrunning` 
(`playerid`, `researchid`, `paid_credits`, `level`, `start_time`, `end_time`) 
VALUES('%u', '%u', '%u', '%u', UNIX_TIME_STAMP(), '%u');]],
				self.__SAPID,
				researchID,
				self.__SAResearches[researchID].level+1,
				requiredCredits,
				endUnixTime
			)
		)
		self.__SAResearches.Running[researchID] = {
			researchID = researchID,
			paidCredits = requiredCredits,
			level = self.__SAResearches[researchID].level+1,
			startTime = curUnixTime,
			endTime = endUnixTime
		}
		
		SA:CallEvent("PlayerStartedResearch", self, researchID)
	end
	
	function plyMeta:SAPauseResearch(researchID)
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_playerxresearchpaused` 
SELECT `playerid`, `researchid`, `paid_credits`, `level`, `start_time`,
`end_time`, UNIX_TIMESTAMP() AS `pause_time`
FROM `sa_playerxresearchrunning` WHERE `playerid` = '%u' AND `researchid` = '%u';
DELETE FROM `sa_playerxresearchrunning`  WHERE `playerid` = '%u' AND `researchid` = '%u';]],
				self.__SAPID,
				researchID,
				self.__SAPID,
				researchID
			)
		)
		self.__SAResearches.Paused[researchID] = self.__SAResearches.Running[researchID] 
		self.__SAResearches.Paused[researchID].pauseTime = os.time()
		
		self.__SAResearches.Running[researchID] = nil
		
		SA:CallEvent("PlayerPausedResearch", self, researchID)
	end
	
	function plyMeta:SAContinueResearch(researchID)
		SA.Plugins.MySQL:Query(--currTime + endTime - pausedTime
			string.format(
[[INSERT INTO `sa_playerxresearchrunning` SELECT `playerid`, `researchid`, `paid_credits`, `level`, `start_time`,
UNIX_TIMESTAMP() + (`end_time` - `pause_time`) AS `end_time`
FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u' AND `researchid` = '%u';
DELETE FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u' AND `researchid` = '%u';]],
				self.__SAPID,
				researchID,
				self.__SAPID,
				researchID
			)
		)
		
		self.__SAResearches.Running[researchID] = self.__SAResearches.Paused[researchID] 
		self.__SAResearches.Running[researchID].pauseTime = nil
		
		self.__SAResearches.Paused[researchID] = nil
		
		SA:CallEvent("PlayerContinuedResearch", self, researchID)
	end
	
	function plyMeta:SAAbortResearch(researchID, refund)--refund 0-1 multiplicator
		SA.Plugins.MySQL:Query(--currTime + endTime - pausedTime
			string.format(
[[DELETE FROM `sa_playerxresearch` WHERE `playerid` = '%u' AND `researchid` = '%u';
DELETE FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u' AND `researchid` = '%u';]],
				self.__SAPID,
				researchID,
				self.__SAPID,
				researchID
			)
		)
		
		if(refund) then
			if(self.__SAResearches.Running[researchID]) then
				self:SAAddCredits(self.__SAResearches.Running[researchID].paidCredits*refund)
			else
				self:SAAddCredits(self.__SAResearches.Paused[researchID].paidCredits*refund)
			end
		end
		
		self.__SAResearches.Running[researchID] = nil
		
		SA:CallEvent("PlayerAbortedResearch", self, researchID)
	end
	
	function plyMeta:SACanResearch(researchID)
		for k, v in next, PLUGIN._available[researchID].dependencies do
			if(not self.__SAResearches.Done[v]) then
				return false
			end
		end
		return true
	end
	
	function plyMeta:SAHasResearch(researchID)
		return self.__SAResearches.Done[v] ~= nil
	end
	
	function plyMeta:SAGetDoneResearches()
		local retTbl = {}
		for k, v in next, self.__SAResearches.Done do
			table.insert(retTbl, k)
		end
		return retTbl
	end

	function plyMeta:SAGetRunningResearches()
		local retTbl = {}
		for k, v in next, self.__SAResearches.Running do
			table.insert(retTbl, k)
		end
		return retTbl
	end
	
	function plyMeta:SAGetPausedResearches()
		local retTbl = {}
		for k, v in next, self.__SAResearches.Paused do
			table.insert(retTbl, k)
		end
		return retTbl
	end
	
	function plyMeta:SAGetAvailableResearches()
		local retTbl = {}
		for k, v in next, PLUGIN._available do
			if(self.__SAResearches.Done[k]) then
				table.insert(retTbl, k)
			end
		end
	end
	
	function plyMeta:SAPauseAllResearches()
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_playerxresearchpaused` SELECT `playerid`, `researchid`, `paid_credits`, `level`, `start_time`,
`end_time`, UNIX_TIMESTAMP() AS `pause_time` FROM `sa_playerxresearchrunning` WHERE `playerid` = '%u';
DELETE FROM `sa_playerxresearchrunning` WHERE `playerid` = '%u';]],
				self.__SAPID,
				self.__SAPID
			)
		)
		for k, v in next, self.__SAResearches.Running do
			self.__SAResearches.Paused[k] = self.__SAResearches.Running[k] 
			self.__SAResearches.Paused[k].pauseTime = os.time()
			
			self.__SAResearches.Running[k] = nil
			
			SA:CallEvent("PlayerPausedResearch", self, k)
		end
	end
	function plyMeta:SAAbortAllResearches()
		SA.Plugins.MySQL:Query(--currTime + endTime - pausedTime
			string.format(
[[DELETE FROM `sa_playerxresearchrunning` WHERE `playerid` = '%u';
DELETE FROM `sa_playerxresearchpaused` WHERE `playerid` = '%u';]],
				self.__SAPID,
				self.__SAPID
			)
		)
		--for running
		for k, v in next, self.__SAResearches.Running do
			if(refund) then
				self:SAAddCredits(self.__SAResearches.Running[k].paidCredits*refund)
			end
			
			self.__SAResearches.Running[k] = nil
			
			SA:CallEvent("PlayerAbortedResearch", self, k)
		end
		
		--for paused
		for k, v in next, self.__SAResearches.Paused do
			if(refund) then
				self:SAAddCredits(self.__SAResearches.Paused[k].paidCredits*refund)
			end
			
			self.__SAResearches.Paused[k] = nil
			
			SA:CallEvent("PlayerAbortedResearch", self, k)
		end
	end
	--END PLAYER METHODES
end

function PLUGIN:OnDisable()
	timer.Remove("ResearchPoll")
	timer.Remove("RunningResearchPoll")
	for k, v in next, player.GetAll() do
		v.__SAResearch = nil
	end
	
	local plyMeta = _R.Player
	
	plyMeta.SAGetResearchLevel = nil
	plyMeta.SASetResearchLevel = nil
	plyMeta.SAStartResearch = nil
	plyMeta.SAPauseResearch = nil
	plyMeta.SAContinueResearch = nil
	plyMeta.SAAbortResearch = nil
	plyMeta.SACanResearch = nil
	plyMeta.SAHasResearch = nil
	plyMeta.SAGetDoneResearches = nil
	plyMeta.SAGetRunningResearches = nil
	plyMeta.SAGetPausedResearches = nil
	plyMeta.SAGetAvailableResearches = nil
	plyMeta.SAPauseAllResearches = nil
	plyMeta.SAAbortAllResearches = nil
end

SA:RegisterPlugin(PLUGIN)