--this is suppose to be FASTER than then hook module

local events = {}


function SA:AddEventListener(event, handlerName, handlerFunc)
	if(type(handlerFunc) ~= "function") then
		self:Error("Attempted to add non handler function (%s) for event '%s' with the name '%s'.", type(handlerFunc), event, handlerName)
		return
	end
	if(not events[event]) then
		events[event] = {[handlerName] = handlerFunc}
		return
	end
	events[event][handlerName] = handlerFunc
end

function SA:RemoveEventListener(event, handlerName)
	if(not events[event] or not events[event][eventhandler]) then
		return
	end
	events[event][eventhandler] = nil
end

function SA:GetListenerTable()
	return events
end

local eventTbl
local succ
local res1, res2, res3, res4, res5, res6
local next = next
function SA:CallEvent(event, ...)
	if(not events[event]) then
		self:Warning("No event listener for event: %s", event)
		return
	end
	for name, func in next, events[event] do
		succ, res1, res2, res3, res4, res5, res6 = pcall(func, ...)
		if(not succ) then
			self:Error(
				"Failed to call event handler function '%s' for event '%s' with the error: '%s'.",
				event,
				name,
				res1
			)
		elseif(res1 ~= nil) then
			return res1, res2, res3, res4, res5, res6
		end
	end
end