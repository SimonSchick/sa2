local PLUGIN = Plugin("Systimer")

function PLUGIN:CreateTimer(indentifier, reps, interval, func)
	self.timer[indentifier] = {reps, interval, SysTime()+interval, func}
end

function PLUGIN:RemoveTimer(indentifier)
	self.timer[indentifier] = nil
end

function PLUGIN:OnEnable()
	hook.Add("Think", "SASysTimer", function()
		local t = SysTime()
		local isok, res
		for indentifier, tbl in next, self.timer do
			if(tbl[3] <= t) then
				tbl[1] = tbl[1] - 1
				isok, res = pcall(tbl[4], tbl[1])
				if(not isok) then
					self:Error(
						"Timer '%s' failed with error %s",
						tostring(indentifier),
						res
					)
				end
				if(tbl[1] == 0) then
					self.timer[indentifier] = nil
					continue
				end
				tbl[3] = t + tbl[2]
			end
		end
	end)
	self.timer = {}
end

function PLUGIN:OnDisable()
	self.timer = nil
	hook.Remove("Think", "SASysTimer")
end

SA:RegisterPlugin(PLUGIN)