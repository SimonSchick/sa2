include("shared.lua")

function ENT:Draw()
	if(self._isActive) then
		self:DrawMiningEffect()
	end
	self:DrawModel()
end

local function _enableMine(ent)
	ent._isActive = true
	self:OnStartedMine()
end

function ENT:StartMining()
	self:OnStartMine()
	timer.Simple(ENT.StartUpTime, function() _enableMine(self) end)
end

local function _disableMine(ent)
	ent._isActive = true
	self:OnEndedMine()
end

function ENT:EndMining()
	self:OnEndMine()
	timer.Simple(ENT.ShutDownTime, function() _disableMine(self) end)
end