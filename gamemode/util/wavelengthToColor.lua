--[[ ORIGINAL CODE
local mRound = math.Round
local mpow = math.pow
local mfloor = math.floor

local function factorAdjust(col, factor, intense, gamma)
	if(col == 0) then
		return 0;
	else
		return mRound(intense * mpow(col * factor, gamma));
	end
end

function wavelengthToColor(wl)
	mfloor(wl)
	local gamma = 1;
	local intensityMax = 255;
	local b, g, r, f;

	if(wl >= 350 and wl <=439) then
		r	= -(wl - 440) / (440 - 350);
		g = 0;
		b= 1;
	elseif(wl >= 440 and wl <= 489) then
		r	= 0;
		g = (wl - 440) / (490 - 440);
		b	= 1;
	elseif(wl >= 490 and wl <= 509) then
		r = 0;
		g = 1;
		b = -(wl - 510) / (510 - 490);
	elseif(wl >= 510 and wl <= 579) then
		r = (wl - 510) / (580 - 510);
		g = 1;
		b = 0;
	elseif(wl >= 580 and wl <= 644) then
		r = 1.0;
		g = -(wl - 645) / (645 - 580);
		b = 0.0;
	elseif(wl >= 645 and wl <= 780) then
		r = 1;
		g = 0;
		b = 0;
	else 
		r = 0;
		g = 0;
		b = 0;
	end
	
	if(wl >= 350 and wl <= 419) then
		f = 0.3 + 0.7*(wl - 350) / (420 - 350);
	elseif(wl >= 420 and wl <= 700) then
		f = 1;
	elseif(wl >= 701 and wl <= 780) then
		f = 0.3 + 0.7*(780 - wl) / (780 - 700);
	else
		f = 0;
	end
  return Color(factorAdjust(r, f, intensityMax, gamma), factorAdjust(g, f, intensityMax, gamma), factorAdjust(b, f, intensityMax, gamma), 255);
end
]]

local mfloor = math.floor

local r, g, b, fac

function wavelengthToColor(wl)
	wl = mfloor(wl)

	if(wl >= 350 and wl <=439) then
		r = -(wl - 440) / (440 - 350)
		g = 0
		b = 1
	elseif(wl >= 440 and wl <= 489) then
		r = 0
		g = (wl - 440) / (490 - 440)
		b = 1
	elseif(wl >= 490 and wl <= 509) then
		r = 0
		g = 1
		b = -(wl - 510) / (510 - 490)
	elseif(wl >= 510 and wl <= 579) then
		r = (wl - 510) / (580 - 510)
		g = 1
		b = 0
	elseif(wl >= 580 and wl <= 644) then
		r = 1.0
		g = -(wl - 645) / (645 - 580)
		b = 0.0
	elseif(wl >= 645 and wl <= 780) then
		r = 1
		g = 0
		b = 0
	else 
		r = 0
		g = 0
		b = 0
	end
	
	if(wl >= 350 and wl <= 419) then
		fac = 0.3 + 0.7*(wl - 350) / (420 - 350)
	elseif(wl >= 420 and wl <= 700) then
		fac = 1
	elseif(wl >= 701 and wl <= 780) then
		fac = 0.3 + 0.7*(780 - wl) / (780 - 700)
	else
		fac = 0
	end
	return mfloor(255 * r * fac), mfloor(255 * g * fac), mfloor(255 * b * fac)
end