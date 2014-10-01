local PLUGIN = Plugin("Cursorutil", {"Topbar"})

function PLUGIN:OnEnable()
	concommand.Add("+SAShowCursor", function()
		gui.EnableScreenClicker(true)
	end)
	concommand.Add("-SAShowCursor", function()
		gui.EnableScreenClicker(false)
	end)
end

function PLUGIN:OnDisable()
	concommand.Remove("+SAShowCursor")
	concommand.Remove("-SAShowCursor")
end

SA:RegisterPlugin(PLUGIN)