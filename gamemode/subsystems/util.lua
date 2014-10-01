local assert = assert
local tconcat = table.concat
local tremove = table.remove
local sformat = string.format
local next = next
local type = type
local error = error

local dofile = dofile

local _G = _G

local dgetlocal = debug.getlocal

local getName = getName

module("util")

local incl = {}

function include(path)
	if incl[path] then
		return
	end
	incl[path] = true
	return dofile(path)
end

function loadClass(className)
	include("includes/classes/"..className)
end

function fassert(cond, lvl, format, ...)
	if(not cond) then
		if(not format) then
			error("assertion failed!")
		end
		error(sformat(format, ...), lvl+1)
	end
	return cond
end

function assertArg(arg, t, ind)
	local t2 = type(arg)
	fassert(t == t2, 3, "bad argument #%i to '?' (%s expected, got %s)", ind, t, t2)
end

function assertArgLevel(arg, t, lvl, ind)
	local t2 = type(arg)
	fassert(t == t2, lvl+1, "bad argument #%i to '?' (%s expected, got %s)", ind, t, t2)
end

function assertMultiArgLevel(arg, lvl, ind, ...)
	local t2 = type(arg)
	fassert(t == t2, lvl+1, "bad argument #%i to '?' (%s expected, got %s)", ind, tconcat({...}, " or "), t2)
end

function ferror(str, level, ...)
	error(sformat(str, ...), level+1)
end

function tableCopy(dest, src)
	for k, v in next, src do
		dest[k] = v
	end
end

function copyNoOverride(dest, src)
	for k, v in next, src do
		if(not curr[k]) then
			dest[k] = v
		end
	end
end

function tableCount(tbl)
	local i = 0
	for _ in next, tbl do
		i = i + 1
	end
	return i
end

function substractTable(curr, rem)
	for k, v in next, rem do
		curr[k] = nil
	end
end

function removeKeyByValue(tbl, val)
	for k, v in next, tbl do
		if(val == v) then
			tremove(tbl, k)
			return true
		end
	end
	return false
end

local asserters = {}

function makeClassAsserter(className)
	if(asserters[className]) then
		return asserters[className]
	end
	local func = _G.IsClass[className]
	fassert(func, 2, "Could not make class asserter for class %s", className)
	local errString = "bad argument #%i to '%s' (expected "..className..", got %s)"
	local retFunc = function(b, idx)
		local a = func(b)
		if(a) then
			return b
		end
		return fassert(false, 2, errString, idx, dgetlocal(2, idx), getName(b))
	end
	asserters[className] = retFunc
	return retFunc
end