include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	
	cam.Start3D2D(self._storPos, self._storAng, 1)
		if(self._displayMode == 0) then
		elseif(self._htmlLoaded) then
			surface.SetMaterial(self._htmlMat)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, 512, 512)
		end
	cam.End3D2D()
end

function ENT:Initialize()
	self._storPos = self:GetPos()
	self._storAng = self:GetAngles()
end

function ENT:OnRemove()
end

function ENT:SetContents(str)
	self._contents = str
	if(str:find("<html>", 1, true)) then
		self._displayMode = 1
		self._htmlLoaded = false
		local tempHTML = vgui.Create("Awesomenium")
		tempHTML:SetVisible(false)
		tempHTML:SetSize(512, 512)
		tempHTML:SetHTML(str)
		timer.Simple(1.5, function()
			self._htmlLoaded = true
			self._htmlMat = tempHTML:GetHTMLMaterial()
			tempHTML:Remove()
		end)
	end
end

function ENT:SetOwnerID(id)
	self._ownerID = id
end