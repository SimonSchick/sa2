include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self._produces = {}
	self._running = false
end

function ENT:SetProduce(res, amnt)
	self._produces[res] = amnt
end

function ENT:GetProduce(res)
	return self._produces[res]
end

function ENT:Link(node)
	node:Link(self)
end

function ENT:UnLink()
	node:UnLink(self)
end

function ENT:RDTick()
	local node = self._node
	for	k, v in next, self._produces do
		node:AddResource(k, v)
	end
end