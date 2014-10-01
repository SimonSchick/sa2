local PLUGIN = Plugin("Clientsecurity", {
		"MySQL",
		"Playerdata",
		"Systimer"
	},{
		"crypt"
	}
)

local _maxAttempts = 5
local _loginTimeout = 120

function PLUGIN:OnEnable()
	util.AddNetworkString("SAClientSecurityStart")
	SA.Plugins.Playerdata:RegisterCallback("use_password", function(ply, val)
		ply.__SAClientSecurity = ply.__SAClientSecurity or {}
		if(val == 1) then
			ply:Lock()
			net.Start("SAClientSecurityStart")
				net.WriteUInt(_loginTimeout, 16)
				net.WriteUInt(_maxAttempts, 8)
			net.Send(ply)
			ply.__SAClientSecurity.shouldAuth = true
			SA.Plugins.Systimer:CreateTimer(
				"SAClientSecurity"..ply:SteamID(),
				1,
				_loginTimeout,
				function()
					--SA.Plugins.Sourcebans:BanPlayer(ply, 600, "Client security timeout")
					ply:Kick("FUCK ASS BITCH NIGGER")
				end
			)
		end
	end)
	
	SA.Plugins.Playerdata:RegisterCallback("password", function(ply, val)
		ply.__SAClientSecurity = ply.__SAClientSecurity or {}
		ply.__SAClientSecurity.password = val
	end)
	
	util.AddNetworkString("SAClientSecurityResponse")
	util.AddNetworkString("SAClientSecurityFailed")
	util.AddNetworkString("SAClientSecurityFinish")
	net.Receive("SAClientSecurityResponse", function(len, ply)
		if(not ply.__SAClientSecurity.shouldAuth) then
			return
		end
		local loginMode = net.ReadUInt(1)
		local pass
		if(loginMode == 1) then--cookie mode
			pass = net.ReadString()
		elseif(loginMode == 0) then
			pass = crypt.sha256(net.ReadString(), true)
		end
		if(pass == ply.__SAClientSecurity.password) then
			
			net.Start("SAClientSecurityFinish")
			net.Send(ply)
			ply:UnLock()
			SA.Plugins.Systimer:RemoveTimer("SAClientSecurity"..ply:SteamID())
			ply.__SAClientSecurity.shouldAuth = false
			return
		end
		
		local failed = ply.__SAClientSecurity.failedAttempts
		if(not failed) then
			failed = 0
		end
		ply.__SAClientSecurity.failedAttempts = failed + 1
		if(failed == self._maxAttempts) then
			--SA.Plugins.Sourcebans:BanPlayer(ply, 600, "Wrong client security password")
			ply:Kick("FUCK ASS BITCH NIGGER")
			return
		end
		net.Start("SAClientSecurityFailed")
			net.WriteUInt(self._maxAttempts - failed, 8)
		net.Send(ply)
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)