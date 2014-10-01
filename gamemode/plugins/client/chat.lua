local PLUGIN = Plugin("Chat", {})
PLUGIN._chatBox = nil
PLUGIN._isOpen = false
PLUGIN._textBox = nil

function PLUGIN:OnEnable()
	include(SA.Folder:sub(11).."/gamemode/plugins/client/_chat/DSAChatBox.lua")
	
	self._oldChatAddText = chat.AddText
	self._oldChatGetBoxPos = chat.GetChatBoxPos

	local box = vgui.Create("DSAChatBox")
	box:SetSize(ScrW()/3.5, ScrH()/3.5)
	box.x = 5
	box:AlignBottom(30)
	box:SetVisible(false)
	
	hook.Add("StartChat", "SAChatBox", function(isTeamSay)
		box:Show()
		return true
	end)
	
	hook.Add("FinishChat", "SAChatBox", function()
		box:Hide()
	end)
	
	hook.Add("ChatText", "SAChatBox", function(plyIdx, name, txt, msgType)
		if(msgType == "joinleave") then
			box:AddNotify(txt)
		elseif(msgType == "none") then
			--???
		end
	end)
	
	hook.Add("HUDShouldDraw", "SAChatBox", function(elem)
		if(elem == "CHudChat") then
			return false
		end
	end)
	
	hook.Add("PlayerBindPress", "SAChatBox", function(ply, bind, pressed)
		if !pressed then return end

		if bind == "messagemode" || bind == "messagemode2" then
			hook.Call("StartChat", GAMEMODE, bind == "messagemode2")
			return true
		end
	end)
	
	hook.Add("OnPlayerChat", "SAChat", function(ply, txt)
		if(ply ~= LocalPlayer()) then
			if(txt:lower():find(LocalPlayer():GetName():lower(), 1, true)) then
				box._lastMentioning = RealTime()
			else
				box._lastChat = RealTime()
			end
		end
	end)
	
	function chat.AddText(...)
		self._oldChatAddText(...)
		box:Popup(4)
		
		box:AddBBCodeLine(...)
	end
	
	function chat.GetChatBoxPos()
		return box:GetPos()
	end
	
	self._chatBox = box
end

function PLUGIN:OnDisable()
	chat.AddText = self._oldChatAddText
	chat.GetChatBoxPos = self._oldGetChatBoxPos
	
	self._chatBox:Remove()
	
	hook.Remove("StartChat", "SAChatBox")
	hook.Remove("FinishChat", "SAChatBox")
	hook.Remove("HUDShouldDraw", "SAChatBox")
	hook.Remove("PlayerBindPress", "SAChatBox")
end

SA:RegisterPlugin(PLUGIN)