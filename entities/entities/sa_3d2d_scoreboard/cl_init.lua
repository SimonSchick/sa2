include("shared.lua")

function ENT:Draw()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	cam.Start3D2D(pos, ang, 1)
		--dunno
	cam.End3D2D()
end

function ENT:Initialize()
	SA.Resources.EntityTable[self] = self
end

function ENT:OnRemove()
end