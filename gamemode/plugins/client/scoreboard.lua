local PLUGIN = Plugin("Scoreboard", {"Playerdata", "Playername"})

function PLUGIN:OnEnable()
	include(SA.Folder:sub(11).."/gamemode/plugins/client/_scoreboard/DSAScoreBoard.lua")
	
	local scoreBoard = vgui.Create("DSAScoreBoard")
	scoreBoard:SetSize(ScrW()*0.70, ScrH()*0.70)
	scoreBoard:Center()
	scoreBoard:SetVisible(false)
	local x = scoreBoard:GetPos()
	scoreBoard:SetPos(x, -scoreBoard:GetTall()-10)
	
	self._scoreBoard = scoreBoard
	
	hook.Add("ScoreboardShow", "SAScoreBoard", function()
		gui.EnableScreenClicker(true)
		self._scoreBoard:Show()
		return true
	end)
	
	hook.Add("ScoreboardHide", "SAScoreBoard", function()
		gui.EnableScreenClicker(false)
		self._scoreBoard:Hide()
		return true
	end)
end

function PLUGIN:OnDisable()
	self._scoreBoard:Remove()
	hook.Remove("ScoreboardShow", "SAScoreBoard")
	hook.Remove("ScoreboardHide", "SAScoreBoard")
end

SA:RegisterPlugin(PLUGIN)