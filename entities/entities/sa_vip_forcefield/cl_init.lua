include("shared.lua")

net.Receive("SAVipForceFieldVertexes", function()
	local ent = net.ReadEntity()
	ent.vertex1:Set(net.ReadVector())
	ent.vertex2:Set(net.ReadVector())
	ent.vertex3:Set(net.ReadVector())
	
	self.vertex4:Set(ent.vertex1)
	self.vertex4:Add(ent.vertex2-ent.vertex1)
	self.vertex4:Add(ent.vertex3-ent.vertex1)
	ent.normal:Set(net.ReadNormal())
	
	self:SetRenderBounds(vertex1, vertex4)
end)

net.Receive("SAVIPForceFieldTouch", function()
	net.ReadEntity():StartTouchEffect()
end)

function ENT:Initialize()
	self.normal = Vector()
	self.vertex1 = Vector(0, 0, 0)
	self.vertex2 = Vector(0, 0, 0)
	self.vertex3 = Vector(0, 0, 0)
	self.vertex4 = Vector(0, 0, 0)
end

function ENT:Draw()
	render.MaterialOverride(planeMat)
		render.SetBlend(1)
		render.SetColorModulation(1, 1, 1)
		render.DrawQuad(
			self.vertex1,
			self.vertex2,
			self.vertex3,
			self.vertex4
		)
	render.MaterialOverride(nil)
end

