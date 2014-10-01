include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self._storage = {}
	self._maxStorage = {}
	self._node = nil
end

function ENT:OnLink(node)
	node.storageDevices = node.storageDevices + 1
	for k, v in next, self._maxStorage do
		node:AddMaxResource(k, v)
	end
	
	for k, v in next, self._storage do
		node:AddResource(k, v)
		self._storage[k] = 0
	end
end

function ENT:OnUnlink(node)
	for k, _ in next, self._maxStorage do
		local fill = (self._maxStorage[k]/node:GetMaxResource(k))*node:GetResource(k)
		node:RemoveResource(k, fill)
		node:RemoveMaxResource(k, self._maxStorage[k])
		self._storage[k] = fill
	end
end
