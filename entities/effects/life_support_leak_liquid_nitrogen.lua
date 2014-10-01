local soundlist = {};
local sprites = {};
local cloudsprites = {};
function EFFECT:Init(effectdata)
	local pos = effectdata:GetOrigin();
	local ent = effectdata:GetEntity();
	self:SetPos(pos);
	self:SetAngles(effectdata:GetNormal():Angle());
	self:SetParent(ent);
	self.Gravity = self:GetMagnitude();
	self.Emitter = ParticleEmitter(pos,false);
	seld.EntId = ent:EntIndex();
	self.Sound = CreateSound(ent,table.Random(soundlist));
	self.Sound:Play();
	self.Sound:FadeOut(5);
	self.DieTime = RealTime()+self:GetScale();
end

function EFFECT:Render()
end

local function collide(self)
	self:SetAlpha(0);--Removing particles is not possible D:
end
local grav = Vector(0,0,600);
local function think(self,emitter,pos)
	local particle = emitter:Add(table.Random(cloudsprites),pos);
	particle:SetGravity(grav);
	particle:SetDieTime(0.2);
end
	

function EFFECT:Think()
	local emitter = self.Emitter;
	local pos = self:GetPos();
	local forward = self:GetForward();
	local particle;
	local vec = Vector();
	local vel = self:GetVelocity();
	local roll = math.pi*math.random(0.1,0.25);
	local grav;
	local usegrav;
	if(self.Gravity != 0) then
		grav = Vector(0,0,self.Gravity);
		usegrav = true;
	end
	
	for i = 1,5 do
		particle = emitter:Add(table.Random(sprites),pos);
		particle:SetDieTime(0.2);
		vec.x = math.random(-0.1,0.1);
		vec.y = math.random(-0.1,0.1);
		vec.z = math.random(-0.1,0.1);
		particle:SetVelocity(vel+(self:GetForward()+vec)*math.random(100,120));
		particle:SetCollide(true);
		particle:SetCollideCallback(function(self,pos) collide(self,emitter,pos,usegrav) end);
		particle:SetEndAlpha(0);
		particle:SetStartSize(0.1);
		particle:SetStartLength(0.1);
		particle:SetEndSize(0.5);
		particle:SetEndLength(0.5);
		if(usegrav) then
			particle:SetGravity(grav);
		end
		particle:SetRollDelta(roll);
	end
	return RealTime() < self.DieTime;	
end