--Consider a env_smokestack here, it MIGHT be faster

--hook.Add("PrePlayerDraw","Tiber this is also shit, needs handler!!

--Use clipping planes here, will get complicated ass fuck

function EFFECT:Init(effectdata)
	self.Player = effectdata:GetEntity();
	self:SetParent(self.Player);
	
end

function EFFECT:Render()
	--Do nothing here...
end

function EFFECT:Think()
	--Add particles in within the box here randomly
end