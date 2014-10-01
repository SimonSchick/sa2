local PLUGIN = Plugin("Config", {})
PLUGIN._internal = {}

function PLUGIN:Get(name)
	return self._internal[name]
end

function PLUGIN:Set(key, value)
	local old = self._internal[key] 
	self._internal[key] = value
	sql.Query(
		string.format(
			"REPLACE INTO `spaceage2_config` (setting_name, value) VALUES ('%s', '%s');",
			key,
			tostring(value)
		)
	)
	SA:CallEvent("SettingChanged", key, old, value) 
end

function PLUGIN:OnEnable()
	sql.Query(
[[CREATE TABLE IF NOT EXISTS `spaceage2_config` 
(`setting_name` VARBINARY(64) NOT NULL PRIMARY KEY, `value` VARBINARY(16));]]
	)

	self._configPanel = vgui.Create("DSAConfigPanel")
	self._configPanel:SetVisible(false)
	local qry = sql.Query("SELECT * FROM `spaceage2_config`")
	if(qry) then
		for k, v in next, qry do
			self._internal[k] = v
		end
	end
end

function PLUGIN:OnDisable()
	self._internal = nil
end

function PLUGIN:Clear()
	sql.Query("DROP TABLE `spaceage2_config`")
	if(sql.Query(
[[CREATE TABLE IF NOT EXISTS `spaceage2_config` 
(`setting_name` VARBINARY(64) NOT NULL PRIMARY KEY, `value` VARBINARY(16));]]
	) == false) then
		return false
	end
	self._internal = {}
end
concommand.Add("sa_clear_client_config", function() config:Clear() end, nil, "Clears the client config table. Use with caution!")

function PLUGIN:Import(method, name)
	local data = file.Read("spaceage2/configs/"..name..".txt")
	if(!data) then
		return false
	end
	if(method == "keyvalues") then
		data = util.KeyValuesToTable(data)
	elseif(method == "glon") then
		data = glon.decode(data)
	elseif(methode == "ini") then
		--todo
		return false
	end
	self:Clear()
	sql.Begin()
		for k, v in next, data do
			sql.Query("INSERT INTO `spaceage2_config` (setting_name, value) VALUES ('"..key.."', '"..tostring(val).."');")
		end
	sql.Commit()
	self._internal = data
end

function PLUGIN:Export(method, name)
	local data
	if(method == "keyvalues") then
		data = util.KeyValuesToTable(self._internal)
	elseif(method == "glon") then
		data = glon.decode(self._internal)
	elseif(methode == "ini") then
		--todo
		return false
	end
	file.Write("spaceage2/configs/"..name..".txt", data)
end

SA:RegisterPlugin(PLUGIN)