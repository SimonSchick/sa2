function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModel("Ore Model")
end

function ENT:SetResource(resID, amount)
	self:SetMaterial(SA.Plugins.Resources:GetResourceMaterial(resID))
	local phys = self:GetPhysicsObject()
	phys:SetMass(phys:GetMass()*SA.Plugins.Resources:GetResourceWeight(resID)*(amount^1.01))
	phys:SetMaterial(SA.Plugins.Resources:GetResourcePhysMaterial(resID))
	--scaling here
	self._resource = resID
	self._resourceAmount = amount
end

function ENT:Use(activator, caller)
	if(activator:IsPlayer()) then
		activator:SAAddBackPackResource(self._resource, self._resourceAmount)
		self:Remove()
	end
end