include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self.node = nil
end

function ENT:Link(node)
	if (ValidEntity(node)) then
		node:Link(self)
	end
end

function ENT:Unlink()
	if (ValidEntity(self.node)) then
		self.node:Unlink(self)
	end
end

--[[
function ENT:UM_Resource_Val(res,ply)
	if self.IsNode == false then return end
	net.Start("sa_resources_ent_val")
		net.WriteEntity(self)
		net.WriteLong(res)
		net.WriteLong(self.ResourceTable[res])
	net.SendFilter(ply)
end

function ENT:UM_Resource_Max(res,ply)
	if self.IsNode == false then return end
	net.Start("sa_resources_ent_max")
		net.WriteEntity(self)
		net.WriteLong(res)
		net.WriteLong(self.ResourceTableMax[res])
	net.SendFilter(ply)
end

function ENT:UM_Resource_All(res,ply)
	if self.IsNode == false then return end
	net.Start("sa_resources_ent_all")
		net.WriteEntity(self)
		net.WriteLong(res)
		net.WriteLong(self.ResourceTable[res])
		net.WriteLong(self.ResourceTableMax[res])
	net.SendFilter(ply)
end

function ENT:UM_SetNode(ply)
	if self.IsNode == true then return end
	net.Start("sa_resource_setnode")
		net.WriteEntity(self)
		net.WriteEntity(self.Node)
	net.SendFilter(ply)
end

local function SA_Res_EntInitPly(ply)
	for k,ent in pairs(SA.Plugins.Resources._entityTable) do
		if not ValidEntity(ent) then
			SA.Resources.EntityTable[k] = nil
		else
			if ent.IsNode == true then
				for id,_ in pairs(ent.ResourceTableMax) do
					ent:UM_Resource_All(id,ply)
				end
			else
				self:UM_SetNode(ply)
			end
		end
	end
end
hook.Add("PlayerInitialSpawn","SA_Res_EntInitPly",SA_Res_EntInitPly)

function ENT:SetNode(node)
	self.Node = node
	self:UM_SetNode()
end

function ENT:LoadConfig(name)
end

function ENT:Initialize()
	self.ResourceTable = {}
	self.ResourceTableMax = {}
	SA.Resources.EntityTable[self] = self
end

function ENT:OnRemove()
	SA.Resources.EntityTable[self] = nil
end

function ENT:AddResource(res,capacity,nonetworking)
	res = SA.Resources.GetResID(res)
	if self.ResourceTableMax[res] then return false end
	self.ResourceTable[res] = 0
	self.ResourceTableMax[res] = capacity
	if nonetworking ~= true then self:UM_Resource_Max(res) end
	return true
end

function ENT:SupplyResource(res,val,nonetworking)
	if val <= 0 then return -1 end
	res = SA.Resources.GetResID(res)
	if not self.ResourceTable[res] then return -1 end
	val = self.ResourceTable[res] + val
	local max = self.ResourceTableMax[res]
	if val > max then
		self.ResourceTable[res] = max
		val = (val - max)
	else
		self.ResourceTable[res] = val
		val = 0
	end
	if nonetworking ~= true then self:UM_Resource_Val(res) end
	return val
end

function ENT:ConsumeResource(res,val,nonetworking)
	if val <= 0 then return -1 end
	res = SA.Resources.GetResID(res)
	if not self.ResourceTable[res] then return -1 end
	val = self.ResourceTable[res] - val
	if val < 0 then
		self.ResourceTable[res] = 0
		val = 0 - val
	else
		self.ResourceTable[res] = val
		val = 0
	end
	if nonetworking ~= true then self:UM_Resource_Val(res) end
	return val
end
]]