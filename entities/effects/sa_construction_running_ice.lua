local rDrawBeam = render.DrawBeam;
local rDrawSprite = render.DrawSprite;
local beammat = Material("sprites/bluelaser1");
local spritemat = Material("function EFFECTs/blueflare1");

function EFFECT:Init(data)
	local ent = data:GetEntity();
	self:SetModel(ent:GetModel());
	self:SetPos(ent:GetPos());
	self:SetAngles(ent:GetAngles());
	ent:SetColor(255,255,255,0);
	self:SetParent(ent);
	self:SetSkin(ent:GetSkin());
	self.ent = ent;
	local dim = self:OBBMaxs() - self:OBBMins();
	self.buildmat = Material("models/props_lab/Tank_Glass001");
	self.dimx = dim.x*1.01;
	self.dimy = dim.y*1.01;
	self.dimz = dim.z*1.01;
	self.inittime = RealTime();
	self.building = true;
	self.shouldremove = false;
	self.FadeColor = 1;
	local length = dim:Length()
	self.buildtime = length/100;
	self.beamwidth = length/25;
	self.spritesize = length/12.5;
	self.buildcolor = Color(255,255,255,255);
end

function EFFECT:RenderBuild()
	local col = self.buildcolor;
    local front = self:GetForward();
	local center = self:LocalToWorld(self:OBBCenter());
	local offset = front * self.dimx * (math.min((RealTime() - self.inittime)/self.buildtime,1)-0.5)
	SetMaterialOverride(self.buildmat);
	render.EnableClipping(true);
    render.PushCustomClipPlane(-front,-front:Dot(center - offset));
		self:DrawModel();
	render.PopCustomClipPlane();
	SetMaterialOverride(nil);
    render.PushCustomClipPlane(front,front:Dot(center - offset));
		self:DrawModel()
    render.PopCustomClipPlane();
    render.EnableClipping(false);
	local front = front * (self.dimx / 2);
	local right = self:GetRight() * (self.dimy / 2);
	local top = self:GetUp() * (self.dimz / 2);
	
	local FRT = (center + front + right + top);
	local BLB = (center - offset - right - top);
	local FLT = (center + front - right + top);
	local BRT = (center - offset + right + top);
	local BLT = (center - offset - right + top);
	local FRB = (center + front + right - top);
	local FLB = (center + front - right - top);
	local BRB = (center - offset + right - top);
	
	render.SetMaterial(self.buildmat);
	render.DrawQuad(BLT,BRT,BRB,BLB);
	render.DrawQuad(BLB,BRB,BRT,BLT);
	
	local width = self.beamwidth
	render.SetMaterial(beammat);
	rDrawBeam(FLT, FRT, width, 0, 0, col);
	rDrawBeam(FRT, BRT, width, 0, 0, col);
	rDrawBeam(BRT, BLT, width, 0, 0, col);
	rDrawBeam(BLT, FLT, width, 0, 0, col);

	rDrawBeam(FLT, FLB, width, 0, 0, col);
	rDrawBeam(FRT, FRB, width, 0, 0, col);
	rDrawBeam(BRT, BRB, width, 0, 0, col);
	rDrawBeam(BLT, BLB, width, 0, 0, col);

	rDrawBeam(FLB, FRB, width, 0, 0, col);
	rDrawBeam(FRB, BRB, width, 0, 0, col);
	rDrawBeam(BRB, BLB, width, 0, 0, col);
	rDrawBeam(BLB, FLB, width, 0, 0, col);
	
	render.SetMaterial(spritemat);
	local sin = ((math.sin(RealTime()*4)+1)+0.2)*self.spritesize;
	rDrawSprite(FRT,sin,sin,col);
	rDrawSprite(BLB,sin,sin,col);
	rDrawSprite(FLT,sin,sin,col);
	rDrawSprite(BRT,sin,sin,col);
	rDrawSprite(BLT,sin,sin,col);
	rDrawSprite(FRB,sin,sin,col);
	rDrawSprite(FLB,sin,sin,col);
	rDrawSprite(BRB,sin,sin,col);
end

function EFFECT:Think()
	if(!ValidEntity(self.ent)) then
		return false;
	end
	return not self.shouldremove;
end

function EFFECT:Render()
	if(self.building) then
		if((self.inittime + self.buildtime) <= RealTime()) then
			self.building = false;
			self:RenderBuildEnd();
		else
			self:RenderBuild();
		end
	else
		self:RenderBuildEnd();
	end
end

function EFFECT:RenderBuildEnd()
	self:DrawModel();
	local col = self.buildcolor;
	col.r = col.r * self.FadeColor;
	col.g = col.g * self.FadeColor;
	col.b = col.b * self.FadeColor;
	local center = self:LocalToWorld(self:OBBCenter());
	local front = self:GetForward() * (self.dimx / 2);
	local right = self:GetRight() * (self.dimy / 2);
	local top = self:GetUp() * (self.dimz / 2);
	local FRT = (center + front + right + top);
	local BLB = (center - front - right - top);
	local FLT = (center + front - right + top);
	local BRT = (center - front + right + top);
	local BLT = (center - front - right + top);
	local FRB = (center + front + right - top);
	local FLB = (center + front - right - top);
	local BRB = (center - front + right - top);
	local width = self.beamwidth;
	render.SetMaterial(beammat)
	rDrawBeam(FLT, FRT, width, 0, 0, col);
	rDrawBeam(FRT, BRT, width, 0, 0, col);
	rDrawBeam(BRT, BLT, width, 0, 0, col);
	rDrawBeam(BLT, FLT, width, 0, 0, col);

	rDrawBeam(FLT, FLB, width, 0, 0, col);
	rDrawBeam(FRT, FRB, width, 0, 0, col);
	rDrawBeam(BRT, BRB, width, 0, 0, col);
	rDrawBeam(BLT, BLB, width, 0, 0, col);

	rDrawBeam(FLB, FRB, width, 0, 0, col);
	rDrawBeam(FRB, BRB, width, 0, 0, col);
	rDrawBeam(BRB, BLB, width, 0, 0, col);
	rDrawBeam(BLB, FLB, width, 0, 0, col);
	
	
	
	local size = self.spritesize;
	render.SetMaterial(spritemat);
	rDrawSprite(FRT,size,size,col);
	rDrawSprite(BLB,size,size,col);
	rDrawSprite(FLT,size,size,col);
	rDrawSprite(BRT,size,size,col);
	rDrawSprite(BLT,size,size,col);
	rDrawSprite(FRB,size,size,col);
	rDrawSprite(FLB,size,size,col);
	rDrawSprite(BRB,size,size,col);
	
	self.FadeColor = self.FadeColor - 0.01;
	if(self.FadeColor <= 0.4) then
		self.ent:SetColor(255,255,255,255)
		self.shouldremove = true;
	end
end