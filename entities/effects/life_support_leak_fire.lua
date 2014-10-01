local soundlist = {};
local sprites = {};
function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin();
	local ent = effectdata:GetEntity();
	self:SetPos(pos);
	self:SetAngles(effectdata:GetNormal():Angle());
	self:SetParent(ent);
	self.AirRes = self:GetMagnitude();
	self.Emitter = ParticleEmitter(pos,false);
	seld.EntId = ent:EntIndex();
	self.Sound = CreateSound(ent,table.Random(soundlist));
	self.Sound:play();
	self.Sound:FadeOut(5);
	self.DieTime = RealTime()+self:GetScale();
end

function EFFECT:Render()
end

local function collide(self)
	self:SetAlpha(0);--Removing particles is not possible D:
end

function EFFECT:Think()
	local emitter = self.Emitter;
	local pos = self:GetPos();
	local forward = self:GetForward();
	local particle;
	local vec = Vector();
	local vel = self:GetVelocity();
	local roll = math.pi*math.random(0.1,0.25);
	
	--[[ To be considered
	if(SA.Config.GetSetting("Dynamic_Lights") then
		local light = DynamicLight(self.EntId);
		dlight.Pos = pos+forward*10
		dlight.r = 255;
		dlight.g = 255;
		dlight.b = 25;
		dlight.Brightness = 3;
		dlight.Size = 64;
		dlight.Decay = 256;
		dlight.DieTime = CurTime() + 0.1
		dlight.Style = 1;--Candle light style
	end
	]]
	
	for i = 1,5 do
		particle = emitter:Add(table.Random(sprites),pos);
		particle:SetDieTime(0.2);
		vec.x = math.random(-0.1,0.1);
		vec.y = math.random(-0.1,0.1);
		vec.z = math.random(-0.1,0.1);
		particle:SetVelocity(vel+(self:GetForward()+vec)*math.random(100,120));
		particle:SetCollide(true);
		particle:SetCollideCallback(collide);
		particle:SetEndAlpha(0);
		particle:SetStartSize(0.1);
		particle:SetStartLength(0.1);
		particle:SetEndSize(0.5);
		particle:SetEndLength(0.5);
		if(self.AirRes != 0) then
			particle:SetAirResistance(self.AirRes);--When we are in space there is no air resistance :D
		end
		particle:SetRollDelta(roll);
	end
	return RealTime() < self.DieTime;	
end