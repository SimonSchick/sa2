local PLUGIN = Plugin("Cvarlock", nil, {"cvar3"})

local vars = {
	--"sv_cheats",
	"host_timescale"
}

function PLUGIN:OnEnable()
	for i = 1, #vars do
		GetConVar(vars[1]):SetFlag(FCVAR_DEVELOPMENTONLY)
	end
end

function PLUGIN:OnDisable()
	for i = 1, #vars do
		GetConVar(vars[1]):RemoveFlag(FCVAR_DEVELOPMENTONLY)
	end
end

SA:RegisterPlugin(PLUGIN)