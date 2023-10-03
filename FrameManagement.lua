local addonName, repSearch = ...

local function resetPersistentFrames(_, childFrame)
    childFrame:Hide()
	childFrame:ClearAllPoints()
	childFrame:SetFrameStrata("LOW")
end

local function resetPersistentFontStrings(_, childFontString)
    childFontString:Hide()
	childFontString:ClearAllPoints()
end

local function resetPersistentTextures(_, childTexture)
    childTexture:Hide()
	childTexture:ClearAllPoints()
	childTexture:SetTexture(nil)
end

repSearch.persistentFramePool = CreateFramePoolCollection()
repSearch.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "InsetFrameTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "InsetFrameTemplate, BackdropTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Button", nil, "BigRedRefreshButtonTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "ScrollFrameTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelButtonTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelCloseButton", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Button", nil, "ChatConfigBorderBoxTemplate", resetPersistentFrames)
repSearch.persistentFramePool:CreatePoolIfNeeded("Button", nil, "ChatConfigBorderBoxTemplate, BackdropTemplate", resetPersistentFrames)

repSearch.persistentFontStringPool = CreateFontStringPool(repSearch.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameTooltipText", resetPersistentFontStrings)
repSearch.persistentNormalTextPool = CreateFontStringPool(repSearch.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameTooltipText", resetPersistentFontStrings)
repSearch.persistentHeaderTextPool = CreateFontStringPool(repSearch.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameFontNormal", resetPersistentFontStrings)
repSearch.persistentTexturePool = CreateTexturePool(repSearch.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetPersistentTextures)

repSearch.releaseAllPersistentPools = function()
    repSearch.persistentTexturePool:ReleaseAll()
	repSearch.persistentHeaderTextPool:ReleaseAll()
	repSearch.persistentNormalTextPool:ReleaseAll()
	repSearch.persistentFontStringPool:ReleaseAll()
	repSearch.persistentFramePool:ReleaseAll()
end
local function resetTemporaryFrames(_, childFrame)
    childFrame:Hide()
	childFrame:ClearAllPoints()
	childFrame:SetFrameStrata("MEDIUM")

	local typeOfFrame = childFrame:GetObjectType()

	if(typeOfFrame == "Button") then
		childFrame:SetScript("OnClick", nil)

	elseif(typeOfFrame == "CheckButton") then

	elseif(typeOfFrame == "Frame") then
		childFrame:SetMouseClickEnabled(false)
		childFrame:SetScript("OnMouseDown", nil)
		childFrame:ClearBackdrop()
	elseif(typeOfFrame == "StatusBar") then
		childFrame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		childFrame:SetStatusBarColor(0, 0, 0, 0)
		childFrame:SetMinMaxValues(0, 0)
		childFrame:SetValue(0)
	end
end

local function resetTemporaryFontStrings(_, childFontString)
    childFontString:Hide()
	childFontString:ClearAllPoints()
	childFontString:SetDrawLayer("BACKGROUND")
    childFontString:SetText("")
    childFontString:SetFont(repSearch.fonts["libMono"], 9, "THICK, OUTLINE")
end

repSearch.temporaryFramePool = CreateFramePoolCollection()

repSearch.temporaryFramePool:CreatePoolIfNeeded("Frame", nil, "ResizeLayoutFrame", resetTemporaryFrames)
repSearch.temporaryFramePool:CreatePoolIfNeeded("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", resetTemporaryFrames)
repSearch.temporaryFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetTemporaryFrames)
repSearch.temporaryFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "BackdropTemplate, ScrollFrameTemplate", resetTemporaryFrames)
repSearch.temporaryFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetTemporaryFrames)
--repSearch.temporaryFramePool:CreatePoolIfNeeded("StatusBar", nil, "BackdropTemplate", resetTemporaryFrames)

repSearch.temporaryFontStringPool = CreateFontStringPool(repSearch.temporaryFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameTooltipText", resetTemporaryFontStrings)
repSearch.temporaryStatusBarPool = CreateFramePool("StatusBar", nil, "BackdropTemplate", resetTemporaryFrames)

repSearch.releaseAllTemporaryPools = function()
    repSearch.temporaryStatusBarPool:ReleaseAll()
	repSearch.temporaryFontStringPool:ReleaseAll()
	repSearch.temporaryFramePool:ReleaseAll()
end

repSearch.createBaseFrame = function(type, template, parent, width, height)
	local frame

	if(type == "persistent") then
		frame = repSearch.persistentFramePool:Acquire(template)
	elseif(type == "temporary") then
		frame = repSearch.temporaryFramePool:Acquire(template)
	end

	frame:SetParent(parent)
	frame:SetWidth(width)
	frame:SetHeight(height)
	frame:Show()

	return frame
end

repSearch.createBaseTexture = function(type, texturePath, parent, width, height, layer)
	local texture

	if(type == "persistent") then
		texture = repSearch.persistentTexturePool:Acquire()
	elseif(type == "temporary") then
		texture = repSearch.temporaryTexturePool:Acquire()
	end

	texture:SetDrawLayer(layer or "OVERLAY")
	texture:SetParent(parent)
	
	if(width ~= nil) then
		texture:SetWidth(width)
	end
	if(height ~= nil) then
		texture:SetHeight(height)
	end

	if(texture ~= nil) then
		texture:SetTexture(texturePath)
	end

	texture:Show()

	return texture
end

repSearch.createFrameWithFontStringAttached = function (type, template, parent, width, height, fontSize)
	local frame, fontString

	if(type == "persistent") then
		frame = repSearch.persistentFramePool:Acquire(template)
		fontString = repSearch.persistentFontStringPool:Acquire()
	elseif(type == "temporary") then
		frame = repSearch.temporaryFramePool:Acquire(template)
		fontString = repSearch.temporaryFontStringPool:Acquire()
	end

	frame:SetParent(parent)

	if(width and height) then
		frame:SetWidth(width)
		frame:SetHeight(height)
	end
	frame:Show()

	fontString:SetFont(repSearch.fonts["libMono"], fontSize or 9, "OUTLINE")
	fontString:SetPoint("LEFT", frame, "LEFT")
	fontString:SetJustifyH("LEFT")
	fontString:SetJustifyV("CENTER")
	fontString:SetSize(frame:GetSize())
	fontString:SetParent(frame)
	fontString:Show()

	frame.fontString = fontString

	return frame
end