include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/terminal.mdl")
	
	self:SetUseType(ONOFF_USE)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	self.range = 1024
	self._entityTable = {}
	self._resources = {}
	self._maxResources = {}
	self._dirtyMaxResources = {}
	self._oldResources = {}
	self._dirtyResources = {}
	self._isDirty = false
	SA.Plugins.Resources:RegisterNode(self)
end

function ENT:Link(device)
	if (device.OnLinked) then
		device:OnLinked(self)
	end
	table.insert(self._entityTable, device)
	device.node = self
end

function ENT:Unlink(device)
	for i=1, #self._entityTable do
		if (self._entityTable[i] == device) then
			if (device.OnUnlink) then
				device:OnUnlink(self)
			end
			table.remove(self._entityTable,i)
			device.node = nil
			return true
		end
	end
	return false
end

function ENT:IsLinked(device)
	return table.HasValue(self._entityTable, device)
end

function ENT:RDTick()
	local entity
	for i=1, #self._entityTable do
		entity = self._entityTable[i]
		if (entity.RDTick) then
			entity:RDTick()
		end
	end
	for resID, value in next, self._resources do
		if(self._oldResources[resID] ~= value) then
			self._dirtyResources[resID] = true
			self._isDirty = true
		end
	end
end

function ENT:AddResource(res, amnt)
	local max = self:GetMaxResource(res)
	local cur = self:GetResource(res)
	local diff = max - cur
	if amnt >= diff then
		self:SetResource(res, max)
		return
	end
	
	self._resources[res] = (self._resources[res] or 0) + amnt
end

function ENT:SetResource(res, amnt)
	self._resources[res] = amnt
end

function ENT:GetResource(res)
	return self._resources[res] or 0
end

function ENT:AddMaxResource(res, amnt)
	self._maxResources[res] = self._maxResources[res] + amnt
end

function ENT:SetMaxResource(res, amnt)
	self._maxResources[res] = amnt
end

function ENT:GetMaxResource(res)
	return self._maxResources[res] or 0
end

function ENT:GetResources()
	return self._resources
end

--[[
function ENT:LoadConfig(name)
	name = SA.Config.Load("_resources/nodes/"..name)
	self.Range = tonumber(name.main.range)
	self.PrintName = name.main.name
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Range = 1024
	self.StorageTable = {}
	self._entityTable = {}
end

function ENT:AddResource(res,capacity,nonetworking)
	res = SA._resources.GetResID(res)
	self.ResourceTable[res] = self.ResourceTable[res] or 0
	self.ResourceTableMax[res] = (self.ResourceTableMax[res] or 0) + capacity
	if nonetworking ~= true then self:UM_Resource_Max(res) end
	return true
end

function ENT:Link(device)
	if device.IsGenerator then
		return device:Link(self)
	end

	if ValidEntity(device.Node) then
		local node = device.Node
		if node == self then return end
		node:Unlink(device)
	end
	for id,val in pairs(device.ResourceTable) do
		self:AddResource(id,device.ResourceTableMax[id],true)
		self:SupplyResource(id,val,true)
		device.ResourceTable[id] = 0
		
		self:UM_Resource_All(id)
	end
	device:SetNode(self)
	self._entityTable[device] = device
	self.StorageTable[device] = device 
end

function ENT:Unlink(device)
	if device.IsGenerator then
		return device:Unlink(self)
	end

	if not self.StorageTable[device] then return end
	self.StorageTable[device] = nil
	self._entityTable[device] = nil
	device:SetNode(NULL)
	local amt
	for id,val in pairs(ent.ResourceTableMax) do
		amt = self.ResourceTable[id] * (val / self.ResourceTableMax[id])
		device:SupplyResource(id,amt,true)
		self:ConsumeResource(id,amt,true)
		self.ResourceTableMax[id] = self.ResourceTableMax[id] - val
		self.ResourceTable[id] = math.min(self.ResourceTable[id], self.ResourceTableMax[id])
		
		self:UM_Resource_All(id)
	end	
end

function ENT:SetNode(node)
	error("Nodes cannot be assigned nodes!")
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	local nd = table.Count(self.StorageTable)
	for _,ent in pairs(self.StorageTable) do
		ent:SetNode(NULL)
	end
	for id,val in pairs(self.ResourceTable) do
		for _ent in pairs(self.StorageTable) do
			ent:SupplyResource(val * (ent.ResourceTableMax[id] / self.ResourceTableMax[id]))
		end
	end
end

function ENT:ResourceTick()
	local selfPos = self:GetPos()
	for _,ent in pairs(self._entityTable) do
		if ent:GetPos():Distance(selfPos) > self.Range then ent:Unlink() end
	end
end
]]