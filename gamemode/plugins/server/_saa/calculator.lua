local myMathLib = {
	tonumber = tonumber
}

for k, v in next, math do
	if(k:lower() == k) then--fucku garry
		myMathLib[k] = v
	end
end
myMathLib.randomseed = nil


local badWords = {
	"%s*break%s", "%s*do%s", "%s*else%s", "%s*elseif%s",
	"%s*end%s", "%s*false%s", "%s*for%s", "%s*function%s", "%s*if%s",
	"%s*in%s", "%s*local%s", "%s*nil%s",
	"%s*repeat%s", "%s*return%s", "%s*then%s", "%s*true%s", "%s*until%s", "%s*while%s",
	"{", "}", "%[", "%]"
}

SAA:AddChatCommand("calc", function(ply, text, args)
	for k, v in next, badWords do
		if(expression:find(v)) then
			ply:SASendChatColor("Sorry, no lua operators allowed D:")
		end
	end

	local res = CompileString(string.format("return (%s)", expression), "SAACalc", false)
	if(not res or type(res) == "string") then
		ply:FuckYou("no")
	else
		pcall(setfenv(res, myMathLib))
	end
end)