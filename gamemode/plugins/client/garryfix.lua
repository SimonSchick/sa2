local PLUGIN = Plugin("Garryfix", {})

local awfulThings = {
	PlayerTick = {
		"TickWidgets"
	},
	PostDrawEffects = {
		"RenderWidgets",
		"RenderHalos"
	},
	Think = {
		"RealFrameTime",
		"DOFThink"
	},
	PostRender = {
		"RenderFrameBlend",
	},
	OnGamemodeLoaded = {
		"CreateMenuBar",
	},
	PlayerBindPress = {
		"PlayerOptionInput",
	},
	RenderScene = {
		"RenderSuperDoF",
		"RenderScenePosition",
		"RenderStereoscopy",
		"RenderSceneNormal"
	},
	PopulateToolMenu = {
		"PopulateOptionMenus",
		"PopulateUtilityMenus"
	},
	GUIMouseReleased = {
		"MorphMouseUp",
		"SuperDOFMouseUp"
	},
	VGUIMousePressAllowed = {
		"WorldPickerMouseDisable"
	},
	PreRender = {
		"PreRenderFrameBlend"
	},
	RenderScreenspaceEffects = {
		"RenderBloom",
		"RenderMotionBlur",
		"RenderToyTown",
		"RenderSharpen",
		"RenderMaterialOverlay",
		"RenderSunbeams",
		"RenderTexturize",
		"RenderSobel",
		"DrawMorph",
		"RenderColorModify"
	},
	AddToolMenuCategories = {
		"CreateUtilitiesCategories",
		"CreateOptionsCategories"
	},
	SpawniconGenerated = {
		"SpawniconGenerated"
	},
	PopulateMenuBar = {
		"NPCOptions_MenuBar",
		"DisplayOptions_MenuBar"
	},
	HUDPaint = {
		"DrawRecordingIcon",
		"PlayerOptionDraw"
	}
}

function PLUGIN:OnEnable()
	for hookName, tbl in next, awfulThings do
		for i = 1, #tbl do
			hook.Remove(hookName, tbl[i])
		end
	end
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)