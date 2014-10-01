local shaftModel = "models/Slyfo/rover_drillshaft.mdl"

function ENT:Initialize()
	self._mainShaft = ClientsideModel(shaftModel)

	self._drillHead = ClientsideModel("")
	
	self._drillShafts = {}
	
	self._emitter = ParticleEmitter(self:GetPos(), false)
	
	self._fakeHole = ClientsideModel()
	
	self._fakeHoleCap = ClientsideModel()
	
	self._fakeHole:SetNoDraw(true)
	self._fakeHoleCap:SetNoDraw(true)
end

local currRot = Angle()
local part
local randvec = Vector()
function ENT:Think()
	randvec.x = math.random()*64
	randvec.y = math.random()*64
	randvec.z = math.random()*64
	if(self._isDrilling) then
		part = self._emitter:Add("TEXTURE HERE", self._drillingPos)
		--part:SetGravity(
		part:SetVelocity(randvec)
		part:SetStartSize(16)
		part:SetEndSize(16)
		part:SetStartLength(16)
		part:SetEndLength(16)
		part:SetEndAlpha(0)
		part:SetLifeTime(1)
	end
	local ang = self:GetAngles()
	ang.r = RealTime()*self._drillSpeed
	self._mainShaft:SetAngles(ang)
end

local trace = {}
function ENT:Enable()
	trace.start = self:GetPos()
	local up = self:GetUp()
	trace.endpos = trace.start - up*50
	trace.filter = self
	local res = util.TraceLine(trace)
	
	local ang = self:GetAngles()
	
	self._drillingPos = res.HitPos
	
	self._fakeHoleCap:SetPos(res.HitPos)
	self._fakeHoleCap:SetAngles(ang)
	
	self._fakeHole:SetPos(res.HitPos - (up*50))
	self._fakeHole:SetAngles(ang)
	
	self._emitter:SetPos(res.HitPos)
end

function ENT:OnRemove()
	self._fakeHole:Remove()
	self._fakeHoleCap:Remove()

	self._mainShaft:Remove()
	self._emitter:Finish()
end

function ENT:Draw()
	render.SetStencilEnable(true)
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		
		--more stencil stuff
		render.SetBlend(0)
			self._fakeHoleCap:DrawModel()
		render.SetBlend(1)
		
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		
		SetMaterialOverride(mat)
			cam.IgnoreZ(true)
				self._fakeHole:DrawModel()
			cam.IgnoreZ(false)
		SetMaterialOverride(nil)
	render.SetStencilEnable(false)
	
	--render.DrawSprite()
	--render.DrawSprite()
	--render.DrawSprite()
	--render.DrawSprite()
end