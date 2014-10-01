include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self._isActive = false
end

include("shared.lua")

function ENT:Draw()
	if(self._isActive) then
		self:DrawMiningEffect()
	end
	self:DrawModel()
end

function ENT:CanMine()
end

function ENT:DrawMiningEffect()
end

local function _enableMine(ent)
	ent._isActive = true
	self:OnStartedup()
end

function ENT:StartMining()
	if(self:CanMine()) then
		self:OnStartup()
		timer.Simple(ENT.StartUpTime,function() _enableMine(self) end)
	end
end

local function _disableMine(ent)
	ent._isActive = true
	self:OnEndedMine()
end

function ENT:EndMining()
	self:OnEndMine()
	timer.Simple(ENT.ShutDownTime, function() _disableMine(self) end)
end