local path = SA.Folder:sub(11).."/gamemode/subsystems/classes/"
local files = file.Find(path.."*.lua", LUA_PATH)

for idx, fileName in next, files do
	include(path..fileName)
end