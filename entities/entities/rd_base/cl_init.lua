include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	SA.Resources.EntityTable[self] = self
end

function ENT:OnRemove()
	SA.Resources.EntityTable[self] = nil
	if ValidEntity(self.Node) then self.Node.EntityTable[self] = nil end
end

net.Receive("sa_resources_ent_max",function()
	local self = net.ReadEntity()
	local res = net.ReadLong()
	self.ResourceTable[res] = self.ResourceTable[res] or 0
	self.ResourceTableMax[res] = net.ReadLong()
	if self.ResourceTable[res] > self.ResourceTableMax[res] then
		self.ResourceTable[res] = self.ResourceTableMax[res]
	end
end)

net.Receive("sa_resources_ent_val",function()
	local self = net.ReadEntity()
	local res = net.ReadLong()
	self.ResourceTable[res] = net.ReadLong()
end)

net.Receive("sa_resources_ent_all",function()
	local self = net.ReadEntity()
	local res = net.ReadLong()
	self.ResourceTable[res] = net.ReadLong()
	self.ResourceTableMax[res] = net.ReadLong()
end)

net.Receive("sa_resource_setnode",function()
	local self = net.ReadEntity()
	if ValidEntity(self.Node) then self.Node.EntityTable[self] = nil end
	self.Node = net.ReadEntity()
	if ValidEntity(self.Node) then self.Node.EntityTable[self] = self end
end)