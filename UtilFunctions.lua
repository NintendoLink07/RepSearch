local addonName, repSearch = ...

local function checkFrameBorderArguments(thickness, r, g, b, a)
	if(not thickness) then
		thickness = 1
	end

	if(not r) then
		r = random(0, 1)
	end

	if(not g) then
		g = random(0, 1)
	end

	if(not b) then
		b = random(0, 1)
	end

	if(not a) then
		a = 1
	end

	return thickness, r, g, b, a
end

repSearch.createFrameBorder = function(frame, oThickness, oR, oG, oB, oA)
	local thickness, r, g, b, a = checkFrameBorderArguments(oThickness, oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness} )
	frame:SetBackdropColor(0.1, 0.1 , 0.1, 0) -- main area color
	frame:SetBackdropBorderColor(r, g, b, a) -- border color
end

repSearch.createFrameBackgroundWithSolidColor = function(frame, oThickness, oR, oG, oB, oA)
	local thickness, r, g, b, a = checkFrameBorderArguments(oThickness, oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true} )
	frame:SetBackdropColor(r, g, b, a) -- main area color
	--frame:SetBackdropBorderColor(0, 0, 0, a) -- border color
end

repSearch.createFrameWithBackgroundAndBorder = function(frame, oThickness, oR, oG, oB, oA)
	local thickness, r, g, b, a = checkFrameBorderArguments(oThickness, oR, oG, oB, oA)

	frame:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=thickness} )
	frame:SetBackdropColor(r, g, b, a) -- main area color
	frame:SetBackdropBorderColor(0, 0, 0, 1) -- border color
end

repSearch.findInString = function(str1, str2)
    return string.find(string.lower(str1), string.lower(str2))
end

repSearch.simpleSplit = function(tempString, delimiter)
	local resultArray = {}
	for result in string.gmatch(tempString, "[^"..delimiter.."]+") do
		resultArray[#resultArray+1] = result
	end

	return resultArray
end