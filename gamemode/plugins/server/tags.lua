local PLUGIN = Plugin("Tags", nil, {"cvar3"})

function PLUGIN:OnEnable()
	local cvar = GetConVar("sv_tags")
	cvar:ToggleFlag(FCVAR_GAMEDLL)
	cvars.AddChangeCallback("sv_tags", function()
		local svTags = {
			"garrysmod150",
			"gm:spaceage2",
			"sa",
			"sa2",
			"spaceage",
			"spaceage2",
			"spacebuild",
			"lifesupport"
		}
		cvar:SetValue(table.concat(svTags,","))
	end)
end

function PLUGIN:OnDisable()

end

SA:RegisterPlugin(PLUGIN)