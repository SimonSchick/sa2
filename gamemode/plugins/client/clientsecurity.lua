local PLUGIN = Plugin("Clientsecurity", {"Config"})

function PLUGIN:TryLogin(password)
	net.Start("SAClientSecurityResponse")
		net.WriteUInt(0, 1)
		net.WriteString(password)
	net.SendToServer()
end

function PLUGIN:ShowLoginDialoge(passHash, timeout, attempts)
	if(passHash) then
		net.Start("SAClientSecurityResponse")
			net.WriteUInt(1, 1)
			net.WriteString(passHash)
		net.SendToServer()
		self._loginPanel:SetCookieLoginEnabled(true)
	end
	self._loginPanel:SetTimeout(timeout)
	self._loginPanel:SetAttemptsLeft(attempts)
	self._loginPanel:Show()
end

function PLUGIN:OnEnable()
	include(SA.Folder:sub(11).."/gamemode/plugins/client/_clientsecurity/DSALoginPanel.lua")
	self._loginPanel = vgui.Create("DSALoginPanel")
	self._loginPanel:SetSize(220, 60)
	self._loginPanel:AlignBottom(260)
	self._loginPanel.x = -130
	self._loginPanel:SetVisible(false)
	
	net.Receive("SAClientSecurityStart", function()
		self._loginTimeout = net.ReadUInt(16)
		self._maxAttempts = net.ReadUInt(8)
		self:ShowLoginDialoge(
			SA.Plugins.Config:Get("saloginhash"),
			self._loginTimeout,
			self._maxAttempts
		)
	end)
	
	net.Receive("SAClientSecurityFinish", function()
		self._loginPanel:SetSuccess(true)
		self._loginPanel:Hide()
	end)
	
	net.Receive("SAClientSecurityFailed", function()
		self._loginPanel:SetAttemptsLeft(net.ReadUInt(8))
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)