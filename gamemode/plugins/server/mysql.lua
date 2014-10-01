local PLUGIN = Plugin("MySQL", nil, {"mysqloo"})

PLUGIN._Connected = false
PLUGIN._Host = "localhost"
PLUGIN._User = "root"
PLUGIN._Pass = ""
PLUGIN._DB = "gmod"
PLUGIN._Port = 3306

local mysqloo

local type = type
local pcall = pcall

function PLUGIN:OnEnable(isDebug)
	self._debug = isDebug
	mysqloo = _G.mysqloo--No external usage
	_G.mysqloo = nil

	include(SA:GetConfigPath().."MySQLInfo.lua")
	local poll = hook.GetTable().Think["MySqlOO::Poll"]
	self._pollFunc = poll
	
	local t = -1
	hook.Add("Think", "MySQLOOPoll", function()
		t = (t + 1) % 5
		if(t == 0) then
			poll()
		end
	end)
	hook.Remove("Think", "MySqlOO::Poll")
	
	self:Connect()
	timer.Create("SAMySQLReconnect", 5, 0, function() self:AutoReconnect() end)
end

function PLUGIN:OnDisable()
	_G.mysqloo = mysqloo
	if(self.Connection) then
		self.Connection = nil
	end
	hook.Add("Think", "MySqlOO::Poll")
	hook.Remove("Think", "MySQLOOPoll")
	timer.Remove("SAMySQLReconnect")
end

function PLUGIN:SetConnectionData(host, user, pass, db, port)
	self._Host = host
	self._User = user
	self._Pass = pass
	self._DB = db
	self._Port = port or 3306
end

function PLUGIN:GetConnectionData()
	return self._Host, self._User, self._Pass, self._DB, self._Port
end

local function connectCallback(db)
	if type(PLUGIN.ConnectCallback) == "function" then
		local s, err = pcall(PLUGIN.ConnectCallback, true)
		if not s and PLUGIN._debug then
			PLUGIN:Print("Connection callback failed: "..err)
		end
		PLUGIN.ConnectCallback = nil
	end
	if(PLUGIN._debug) then
		PLUGIN:Print(
			"Successfuly connected to %s@%s:%u",
			PLUGIN._User,
			PLUGIN._Host,
			PLUGIN._Port
		)
	end
	SA:CallEvent("DatabaseConnect")
end

local function failedCallback(db, err)
	PLUGIN.wasConnected = true
	if(PLUGIN._debug) then
		SA:Warning(
			"Failed to connect to %s@%s:%u:%s",
			PLUGIN._User,
			PLUGIN._Host,
			PLUGIN._Port,
			tostring(err)
		)
	end
	if type(PLUGIN.ConnectCallback) == "function" then
		local s, err = pcall(PLUGIN.ConnectCallback, false, err)
		if not s and PLUGIN._debug then
			PLUGIN:Warning("Connection callback failed: "..err)
		end
		PLUGIN.ConnectCallback = nil
	end
end

--- Connect MySQL. Self explanatory.
function PLUGIN:Connect()
	self.should_Connected = true
	
	local db = mysqloo.connect(self._Host, self._User, self._Pass, self._DB, self._Port)
	db.onConnected = connectCallback
	db.onConnectionFailed = failedCallback
	db:wait()
	db:connect()

	self.Connection = db
	if(self._debug) then
		self:Print(
			"Initializing connection to %s@%s:%u",
			self._User,
			self._Host,
			self._Port
		)
	end
end

function PLUGIN:QueryFormat(query, callback, args, ...)
	if(type(callback) ~= "function") then
		if(self._debug) then
			SA:Warning("Using default callback for MySQL query.")
		end
		callback = self.DefaultCallback
	end
	local res, q = pcall(
		self.Connection.query,
		self.Connection, 
		string.format(
			query,
			...
		)
	)
	if(not res or type(q) == "string" or q == nil) then
		self:Error("Not connected to database")
	end
	
	q.onSuccess = function(query)
		callback(true, query:getData(), args)
	end
	
	q.onError = function(query, err)
		if(self._debug) then
			self:Error("Query failed with error: %s")
		end
		callback(false, err, args) 
	end
	
	--[[q.onAborted = function(query) we are not gonna abort a query any time soon!
		callback(false, "Aborted", unpack(varArgs)) 
	end]]
	q:start()
	return true
end

function PLUGIN:Query(query, callback, ...)
	if(type(callback) ~= "function") then0
		if(self._debug) then
			self:Warning("Using default callback for MySQL query.")
		end
		callback = self.DefaultCallback
	end
	local res, q = pcall(self.Connection.query, self.Connection, query)
	if(not res or type(q) == "string" or q == nil) then
		error("")
		self:Error("Not connected to database")
	end
	
	local varArgs = {...}
	q.onSuccess = function(query)
		callback(true, query:getData(), unpack(varArgs))
	end
	
	q.onError = function(query, err)
		if(self._debug) then
			self:Error("Query failed with error: %s", err)
		end
		callback(false, err, unpack(varArgs)) 
	end
	
	--[[q.onAborted = function(query) we are not gonna abort a query any time soon!
		callback(false, "Aborted", unpack(varArgs)) 
	end]]
	q:start()
	return true
end

function PLUGIN:QueryWait(query, callback, ...)
	if(type(callback) ~= "function") then
		if(self._debug) then
			self:Warning("Using default callback for MySQL query.")
		end
		callback = self.DefaultCallback
	end
	local res, q = pcall(self.Connection.query, self.Connection, query)
	if(not res or type(q) == "string" or q == nil) then
		self:Error("Not connected to database")
	end
	
	local varArgs = {...}
	q.onSuccess = function(query)
		callback(true, query:getData(), unpack(varArgs))
	end
	
	q.onError = function(query, err) 
		if(self._debug) then
			self:Error("Query failed with error: %s", err)
		end
		callback(false, err, unpack(varArgs)) 
	end
	
	q.onAborted = function(query)
		callback(false, "Aborted", unpack(varArgs)) 
	end
	q:wait()
	q:start()
	return true
end

function PLUGIN:QueryRow(query, rowCallback, completionCallback, ...)
	if(type(completionCallback) ~= "function") then
		if(self._debug) then
			self:Warning("Using default callback for MySQL query.")
		end
		callback = self.DefaultCallback
	end
	local res, q = pcall(self.Connection.query, self.Connection, query)
	if(not res or type(q) == "string" or q == nil) then
		self:Error("Not connected to database")
	end
	
	local varArgs = {...}
	q.onSuccess = function(query)
		completionCallback(true, query:getData(), unpack(varArgs))
	end
	
	q.onData = function(query, row)
		rowCallback(row, unpack(varArgs))
	end
	
	q.onError = function(query, err) 
		completionCallback(false, err, unpack(varArgs)) 
	end
	
	q.onAborted = function(query)
		completionCallback(false, "Aborted", unpack(varArgs)) 
	end
	q:start()
	return true
end

function PLUGIN:Poll()
	self._pollFunc()
end

--- Escape a string for use in a query

function PLUGIN:Escape(str)
	return self.Connection:escape(str)
end

function PLUGIN.DefaultCallback(isok, data)
	if(PLUGIN._debug) then
		PLUGIN:Print("Default MySQL query:")
		PLUGIN:Print("\tStatus: "..(isok and "OK" or "FAILED"))
		if(isok and #data ~= 0) then
			PLUGIN:Print("\tResult:")
			PrintTable(data)
		elseif(not isok) then
			PLUGIN:Warning("\tError: "..tostring(data))
		end
	end
end


function PLUGIN:ConnectionCheck()
	return self.Connection ~= nil-- and self.Connection:status() == mysqloo.DATABASE_CONNECTED
end

function PLUGIN:AutoReconnect()
	if not self.should_Connected or not self.wasConnected then
		return
	end
	if not self:ConnectionCheck() then
		self:Connect()
	end
	local res, q = pcall(self.Connection.query, self.Connection, query)
	if(not res or type(q) == "string") then
		PLUGIN:Error("Not connected to database")
	end
end

SA:RegisterPlugin(PLUGIN)