--Consider a env_smokestack here, it MIGHT be faster

function EFFECT:Init(effectdata)
	self.Start = effectdata:GetOrigin();
	self.End = effectdata:GetStart();
	self.Emitter = ParticleEmitter((self.Start + self.End)/2)--math is for faggots
end

function EFFECT:Render()
end

function EFFECT:Think()
	--Add particles in within the box here randomly
end