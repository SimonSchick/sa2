local PLUGIN = Plugin("Sourcebans", {
	"MySQL"
	}, {
	"gatekeeper"
	}
)

PLUGIN.PlayerStatus = {}
PLUGIN.ServerID = -1
PLUGIN.Phrases = {
	["Banned Check Site"] = {
		en = "You have been banned by this server, check %s for more info"
	},
	["DB Connect Fail"] = {
		en = "Database connection failed. Please contact server operator."
	},
	["Not In Game"] = {
		en = "The player is not in game, please visit the web panel to ban them."
	},
	["Ban Not Verified"] = {
		en = "This player has not been verified. Please wait thirty seconds before retrying."
	},
	["Can Not Unban"] = {
		en = "You can not unban from in the server, visit %s to unban."
	},
	["Can Not Add Ban"] = {
		en = "You can not add a ban from in the server, visit %s to add a ban."
	},
	["Check Menu"] = {
		en = "Please check the menu to select a reason for ban."
	},
	["Include Reason"] = {
		en = "Please include a reason for banning the client."
	},
	["Ban Fail"] = {
		en = "Failed to ban player, please try again."
	},
	["Chat Reason"] = {
		en = "Please type the reason for ban in chat and press enter. Type '!noreason' to abort."
	},
	["Chat Reason Aborted"] = {
		en = "The ban procedure has been stopped successfully."
	}
}

local function localize(str, ...)
	str:format(PLUGIN.Phrases[str], ...)
end

PLUGIN.WebAddress = "http://example.com/"
function PLUGIN.LongToDotted(long)
	long = tonumber(long)
	return table.concat(
		{
			math.floor(long/math.pow(256,3)),
			math.floor((long%math.pow(256,3))/math.pow(256,2)),
			math.floor(((long%math.pow(256,3))%math.pow(256,2))/math.pow(256,1)),
			math.floor((((long%math.pow(256,3))%math.pow(256,2))%math.pow(256,1))/math.pow(256,0))
		},
		"."
	)
end

PLUGIN.ServerIP = PLUGIN.LongToDotted(GetConVar("hostip"):GetString())
PLUGIN.ServerPort = tonumber(GetConVar("hostport"):GetString())
PLUGIN.BanCache = {}
PLUGIN.BanCache.SteamID = {}
PLUGIN.BanCache.IP = {}
PLUGIN.ServerSteam = "STEAM_0:0:SERVER"

function _R.Entity:SteamID()
	return PLUGIN.ServerSteam
end

function PLUGIN.SteamID(steamid, t)
	if type(steamid) == "Player" or type(steamid) == "Entity" then
		if not steamid:IsValid() then
			steamid = PLUGIN.ServerSteam
		else
			steamid = steamid:SteamID()
		end
	elseif(not steamid) then
		steamid = PLUGIN.ServerSteam
	end
	return (t and steamid or string.sub(steamid, 9))
end

function PLUGIN.IP(ply)
	if (type(ply) == "Entity" or type(ply) == "Player") then
		if not IsValid(ply) then return PLUGIN.ServerIP end
		local ip = ply:IPAddress()
		return ip:sub(1, ip:find(":", 1, true)-1)
	elseif(not ply) then
		return PLUGIN.ServerIP
	end
	return ply:sub(1, ply:find(":", 1, true)-1)
end

function PLUGIN:DebugPrint(...)
	if not self.Debug then return end
	print("[PLUGIN]", ...)
end

local function RecievedAuthCheck(isok, data, ply, steamid)
	if not ply:IsValid() then return end
	if not isok then
		print("Failed to check authorization for "..ply:Name()..": "..tostring(err))
				timer.Create("AuthRecheck"..steamid, 15, 1, function() PLUGIN.PlayerAuthed(ply, steamid) end)
		return
	end
	if #data > 0 then
		PLUGIN:AddBlock(ply, ply, steamid)
		RunConsoleCommand("banid", 5, steamid)
		if gatekeeper then
			gatekeeper.Drop(ply:UserID(), localize("Banned Check Site", PLUGIN.WebAddress))
		else
			RunConsoleCommand("kickid", ply:UserID(), localize("Banned Check Site", PLUGIN.WebAddress))
		end
		return
	end
	PLUGIN.PlayerStatus[ply] = true
end

function PLUGIN.PlayerAuthed(ply, steamid)
	PLUGIN.PlayerStatus[ply] = false
	local query = string.format(
[[SELECT `bid` FROM `sb_bans` WHERE ((`type` = 0 AND `authid` REGEXP '^STEAM_[0-9]:%s$') OR
(`type` = 1 AND `ip` = '%s')) AND ( `length`  = '0' OR `ends` > UNIX_TIMESTAMP())
AND `RemoveType` IS NULL]],
		PLUGIN.SteamID(steamid),
		PLUGIN.IP(ply)
	)
	local status, err = SA.Plugins.MySQL:Query(query, RecievedAuthCheck, ply, steamid)
	if not status then
		print("Failed to check authorization for "..ply:Name()..": "..tostring(err))
		timer.Create("AuthRecheck"..steamid, 15, 1, function() PLUGIN.PlayerAuthed(ply, steamid) end)
	end
end


function PLUGIN.VerifyInsert(isok, data, query, try)
	print("Done", isok, data)
	if not isok then
		print("Query failed:", data)
		print("Query:", query)
		if try <= 3 then
			SA.Plugins.MySQL:Query(query, PLUGIN.VerifyInsert, query, try+1)
		end
	end
end
function PLUGIN:InsertBan(time, target, admin, reason)
	local query
	if self.ServerID == -1 then
		query = string.format(
[[INSERT INTO `sb_bans` (ip, `authid`, name, `created`, `ends`,  `length`,  `reason`, `aid`, `adminIp`, `sid`, `country`) VALUES
('%s', '%s', '%s', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + %d, %d, '%s', IFNULL((SELECT `aid` FROM `sb_admins` WHERE `authid` = '%s' OR `authid` REGEXP '^STEAM_[0-9]:%s$'),'0'), '%s',
(SELECT `sid` FROM `sb_servers` WHERE `ip` = '%s' AND port = '%s' LIMIT 0,1), ' ')]],
			self.IP(target),
			target:SteamID(),
			SA.Plugins.MySQL:Escape(target:Name()),
			time*60,
			time*60,
			SA.Plugins.MySQL:Escape(reason),
			self.SteamID(admin),
			self.SteamID(admin, true),
			self.IP(admin),
			self.ServerIP,
			self.ServerPort
		)
	else
		query = string.format(
[[INSERT INTO `sb_bans` (`ip`, `authid`, name``, `created, `ends`, `length`,  `reason`, `aid`, `adminIp`, `sid`, `country`)
VALUES('%s', '%s', '%s', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + %d, %d, '%s', 
IFNULL((SELECT `aid` FROM `sb_admins` WHERE `authid` = '%s' OR `authid` REGEXP '^STEAM_[0-9]:%s$'),'0'), '%s',
%d, ' ')]],
			self.IP(target),
			target:SteamID(),
			SA.Plugins.MySQL:Escape(target:Name()),
			time*60,
			time*60,
			SA.Plugins.MySQL:Escape(reason),
			admin:SteamID(),
			self.SteamID(admin),
			self.IP(admin),
			self.ServerID
		)
	end
	SA.Plugins.MySQL:Query(query, PLUGIN.VerifyInsert, query, 1)
end
function PLUGIN:AddBlock(name, ip, steamid)
	if type(name) == "Entity" or type(name) == "Player" then
		if not name:IsValid() then
			name = "CONSOLE"
		elseif type(name.Name) ~= "function" then
			name = "Unknown"
		else
			name = name:Name()
		end
	end
	local ip = self.IP(ip)
	local name = name
	local query
	if self.ServerID == -1 then
		query = string.format(
[[INSERT INTO `sb_banlog` (`sid`, `time`, `name`, `bid`) VALUES
((SELECT `sid` FROM `sb_servers` WHERE `ip` = '%s' AND `port` = '%s' LIMIT 0,1), UNIX_TIMESTAMP(), '%s',
(SELECT `bid` FROM `sb_bans` WHERE ((`type` = 0 AND `authid` REGEXP '^STEAM_[0-9]:%s$') OR
(`type` = 1 AND `ip` = '%s')) AND `RemoveType` IS NULL LIMIT 0,1))]],
			self.ServerIP,
			self.ServerPort,
			SA.Plugins.MySQL:Escape(name),
			self.SteamID(steamid, true),
			ip
		)
	else
		query = string.format(
[[INSERT INTO `sb_banlog` (`sid`, `time`, `name`, `bid`) VALUES
(%d, UNIX_TIMESTAMP(), '%s',
(SELECT `bid` FROM `sb_bans` WHERE ((`type` = 0 AND `authid` REGEXP '^STEAM_[0-9]:%s$') OR
(`type` = 1 AND `ip` = '%s')) AND `RemoveType` IS NULL LIMIT 0,1))]],
			self.ServerID,
			SA.Plugins.MySQL:Escape(name),
			self.SteamID(steamid),
			ip
		)
	end
	local isok, err = SA.Plugins.MySQL:Query(query, self.ErrorCheckCallback, query)
	if not isok then
		Msg("Failed to add to block log: "..tostring(err).."\n")
	end
end

function PLUGIN:BanPlayer(target, time, reason, admin)
	local adminSteamID, adminIP
	if not ValidEntity(admin) then
		adminSteamID, adminIP = self.ServerSteam, self.ServerIP
	else
		adminSteamId, adminIP = admin:SteamID(), self.IP(admin)
	end
	self:InsertBan(
		time or 0,
		target,
		admin,
		reason or "No Reason Specified"
	)
end

local function _getBans(isok, data)
	if isok then
		PLUGIN.BanCache.SteamID = {}
		PLUGIN.BanCache.IP = {}
		for k, v in next, data do
			if v.type == 0 then -- It's a SteamID ban
				PLUGIN.BanCache.SteamID[v.authid] = true
			elseif v.type == 1 then -- It's an IP ban
				PLUGIN.BanCache.IP[v.ip] = true
			end
		end
	else
		Msg("Error refreshing ban cache: "..tostring(data).."\n")
	end
end

local function _recacheBans()
	local query = string.format(
[[SELECT `type`, `authid`, `ip` FROM `sb_bans` WHERE (`type` = 0 OR `type` = 1) AND ( `length`  = '0' OR
`ends` > UNIX_TIMESTAMP()) AND `RemoveType` IS NULL]]
	)
	local isok, err = SA.Plugins.MySQL:Query(query, _getBans)
	if not isok then
		CacheError(err)
	end
end

function PLUGIN:OnEnable(isDebug)
	include(SA:GetConfigPath().."SourceBans.lua")
	
	timer.Create("SARecacheSourceBans", 120, 0, _recacheBans)
	local function GKCheck(name, pass, sid, ip)
		if PLUGIN.BanCache.SteamID[sid] == true or PLUGIN.BanCache.IP[ip] == true then
			PLUGIN:AddBlock(name, ip, sid)
			return {false, localize("Banned Check Site", PLUGIN.WebAddress)}
		end
	end
	hook.Add("PlayerPasswordAuth", "SASourceBans", GKCheck)
	hook.Add("PlayerAuthed", "SASourceBans", PLUGIN.PlayerAuthed)
	for k, v in next, player.GetAll() do
		PLUGIN.PlayerAuthed(v, v:SteamID())
	end
end

function PLUGIN:OnDisable(isDebug)
	timer.Remove("SARecacheSourceBans")
	hook.Remove("PlayerPasswordAuth", "SASourceBans")
	hook.Remove("PlayerAuthed", "SASourceBans")
end

SA:RegisterPlugin(PLUGIN)