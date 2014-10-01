include("shared.lua")

function ENT:Initialize()
	self.range = 1024
	self._entityTable = {}
	self._resources = {}
	self._maxResources = {}
	SA.Plugins.Resources:RegisterNode(self)
end

function ENT:RDTick()
	local entity
	self._isDirty = false
	for i=1, #self._entityTable do
		entity = self._entityTable[i]
		if (entity.RDTick) then
			entity:RDTick()
		end
	end
end

function ENT:Draw()
	self:DrawModel()
end