local tinsert = table.insert
local tremove = table.remove
local tostring = tostring
local setmetatable = setmetatable
local getmetatable = getmetatable
local next = next
local type = type

function getName(obj)
	local meta = getmetatable(obj)
	return (meta and meta.__name) or type(obj)
end

local getName = getName

include("util.lua")


function super(obj)
	local new = {}
	for k, v in next, obj do
		new[k] = v
	end
	return setmetatable(new, getmetatable(obj).super)
end

IsClass = {
	Bool = function(o) return o == true or o == false end,
	Table = function(o) return type(o) == "table" end,
	String = function(o) return type(o) == "string" end,
	Number = function(o) return type(o) == "number" end,
	UserData = function(o) return type(o) == "userdata" end,
	Nil = function(o) return (not o) and (o ~= false) end
}

IsClass.Boolean = IsClass.Bool

local fAssert = util.fassert

function class(name, data)
	local statics = data.statics
	local methods = data.methods
	
	fAssert(methods, 2, "No methods defined for class %q", name)
	
	if(methods[name]) then
		methods.__construct = methods[name]
	end

	--fAssert(methods.__construct, 2, "No constructor defined for class %q", name)
	
	if(not methods.__tostring) then--implementing tostring if not existant
		methods.__tostring = function()
			return name
		end
	end
	
	methods.__index = methods
	
	local base = data.base
	if base then
		setmetatable(methods, base.__methods)
		methods.base = base.__methods
	end
	
	--for k, v in next, methods do
		--fAssert(v ~= true, 2 ,"Attempted to register class %q without implementing abstract class method %q", name, k)
	--end	
	
	local interfaces = data.interfaces
	
	if interfaces then
		for _, interf in next, interfaces do
			for k, funcName in next, interf do
				if funcName ~= "name" and type(k) == "function" then
					fAssert(methods[funcName] and type(methods[funcName]) == "function", 2, "Class did not implement method %q defined in interface %q", funcName, interf.name)
				end
			end
		end
	end
	
	local classTbl = {__methods = methods}--The actual class table
	
	if(base) then--we require a reference to the parent class
		classTbl.super = base.__methods
		classTbl.__base = base
	end
	
	methods.__classTbl = classTbl
	
	local constructorStack = {methods.__construct}--this way we can cache to constructor stack and don't have to build it each time
	if(base) then
		local currParent = base
		while currParent do
			tinsert(constructorStack, currParent.__methods.__construct)--pushing the function onto the stack
			currParent = currParent.__base
		end
	end
	local constructorStackSize = #constructorStack
	
	local classMeta = statics or {}
	
	classMeta.__manualCreate = function(tbl)
		return setmetatable(tbl, methods)
	end
	if(constructorStackSize > 0) then
		classMeta.__call = function(self, ...)--constructor
			local instance = setmetatable({}, methods)--required
			for i = constructorStackSize, 1, -1 do
				constructorStack[i](instance, ...)
			end
			return instance
		end
	else
		classMeta.__call = function(self, ...)--constructor
			return setmetatable({}, methods)--required
		end
	end
	--classMeta.__newindex = function(self)
		--error("Cannot modify class table", 2)
	--end
	local namespace = data.namespace or _G
	
	if(not IsClass) then
		IsClass = {}
	end
	
	IsClass[name] = function(obj)
		local meta = getmetatable(obj)
		if not meta then
			return false
		end
		meta = meta.__classTbl
		while meta do
			if meta == classTbl then
				return true
			end
			meta = meta.__base
		end
		return false
	end
	
	if base then--copying statics
		for k, v in next, getmetatable(base) do
			if not classMeta[k] then
				classMeta[k] = v
			end
		end
	end

	classMeta.__index = classMeta--required
	setmetatable(classTbl, classMeta)--required
	namespace[name] = classTbl
end





























function abstract_class(name, data)
	local statics = data.statics
	local methods = data.methods
	
	fAssert(methods, 2, "No methods defined for class %q", name)
	
	if methods[name] then
		methods.__construct = methods[name]
	end

	fAssert(methods.__construct, 2, "No constructor defined for class %q", name)
	
	if not methods.__index then--FIXME
		methods.__index = methods
	end
	
	local base = data.base
	if base then
		setmetatable(methods, {__index = base.__methods})
	end
	
	local interfaces = data.interfaces
	
	if interfaces then
		for _, interf in next, interfaces do
			for funcName in next, interf do
				if funcName ~= "name" then
					fAssert(methods[funcName] and type(methods[funcName]) == "function", 2, "Class did not implement method %q defined in interface %q", funcName, interf.name)
				end
			end
		end
	end
	
	local classTbl = {__methods = methods}--The actual class table
	
	if base then--we require a reference to the parent class
		classTbl.super = base.__methods
		classTbl.__base = base
	end
	
	methods.__classTbl = classTbl
	
	local classMeta = statics or {}
	
	classMeta.__call = function(self, ...)--constructor
		error(string.format("Cannot instantiate abstract class %s", name), 2)
	end
	
	local namespace = data.namespace or _G
	
	if(not namespace.IsClass) then
		namespace.IsClass = {}
	end
	
	namespace.IsClass[name] = function(obj)
		local meta = getmetatable(obj)
		if(not meta) then
			return false
		end
		while(meta and meta.__base) do
			if(meta.__base == classTbl) then
				return true
			end
			meta = meta.__base
		end
		return false
	end
	
	if base then--copying statics
		for k, v in next, getmetatable(base) do
			if not classMeta[k] and type(v) == "function" then
				classMeta[k] = v
			end
		end
	end

	classMeta.__index = classMeta--required
	setmetatable(classTbl, classMeta);--required
	namespace[name] = classTbl
end

function interface(name, methods, namespace)
	local int = methods
	int.name = name;
	(namespace or _G)["I"..name] = int
end
	