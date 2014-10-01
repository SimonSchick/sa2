include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self._produces = {}
	self._consumes = {}
	self._running = false
end

function ENT:TurnOn()
	self._running = true
end

function ENT:TurnOff()
	self._running = false
end

function ENT:ToggleRunning()
	self._running = not self._running
end

function ENT:SetProduce(res, amnt)
	self._produces[res] = amnt
end

function ENT:GetProduce(res)
	return self._produces[res]
end

function ENT:SetConsume(res, amnt)
	self._consumes[res] = amnt
end

function ENT:GetConsume(res)
	return self._consumes[res]
end

function ENT:Link(node)
	node:Link(self)
end

function ENT:UnLink()
	node:UnLink(self)
end

function ENT:RDTick()
	local node = self._node
	for k, v in next, self._consumes do
		if (node:GetResource(k) < v) then
			self:TurnOff()
			return
		end
	end
	for	k, v in next, self._produces do
		node:AddResource(k, v)
	end
end