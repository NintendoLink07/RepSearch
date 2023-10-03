local addonName, repSearch = ...

repSearch.mainFrame = CreateFrame("Frame", "RepSearch_MainFrame", ReputationFrame, "InsetFrameTemplate")

local function insertPointsIntoTable(frame)
	local table = {}

	for i = 1, frame:GetNumPoints(), 1 do
		table[i] = {frame:GetPoint(i)}
	end

	return table
end

local function insertPointsIntoFrame(frame, table)
	for i = 1, #table, 1 do
		frame:SetPoint(unpack(table[i]))
	end
end

local pveFrameTab1_Point = insertPointsIntoTable(CharacterFrameTab1)

repSearch.createRepSearch = function()
    repSearch.loadSettings()
    
    repSearch.mainFrame:SetPoint("TOPLEFT", CharacterFrameInset, "TOPLEFT", 0, 0)
    repSearch.mainFrame:SetHeight(360)
    repSearch.mainFrame:SetPoint("TOPRIGHT", CharacterFrameInset, "TOPRIGHT", 0, 0)
	repSearch.mainFrame:SetFrameStrata("HIGH")
	repSearch.mainFrame.expanded = false
    
	_G[repSearch.mainFrame:GetName()] = repSearch.mainFrame

    local mainScrollFrame = repSearch.persistentFramePool:Acquire("ScrollFrameTemplate")
	mainScrollFrame:SetParent(repSearch.mainFrame)
	mainScrollFrame:SetPoint("TOPLEFT", repSearch.mainFrame, "TOPLEFT", 0, -4)
	mainScrollFrame:SetPoint("BOTTOMRIGHT", repSearch.mainFrame, "BOTTOMRIGHT", 0, 2)
    mainScrollFrame:SetSize(1, 1)
	mainScrollFrame:Show()
    ---@diagnostic disable-next-line: inject-field
    repSearch.mainFrame.mainScrollFrame = mainScrollFrame

	local mainContainer = repSearch.persistentFramePool:Acquire("BackdropTemplate")
	mainContainer:SetPoint("TOPLEFT", mainScrollFrame, "TOPLEFT")
    mainContainer:SetSize(1, 1)
	mainContainer:SetParent(mainScrollFrame)

	mainContainer:Show()

	mainScrollFrame:SetScrollChild(mainContainer)

    repSearch.mainFrame.mainScrollFrame.mainContainer = mainContainer

    local searchBar = CreateFrame("EditBox", "RepSearch_SearchBar", ReputationFrame, "InputBoxTemplate")
    searchBar:SetSize(100, 20)
    searchBar:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -3, -22)
    searchBar:SetAutoFocus(false)

    searchBar:SetFrameStrata("HIGH")
    searchBar:SetScript("OnTextChanged", function(_, key)

        if(key == "ESCAPE") then
            searchBar:ClearFocus()
        else
            mainScrollFrame:SetVerticalScroll(0)
            repSearch.createFrames(tostring(searchBar:GetText()))
        end
    end)
    searchBar:Show()

    repSearch.mainFrame.searchBar = searchBar

    local toggleMainFrame = repSearch.persistentFramePool:Acquire("UICheckButtonTemplate")
    toggleMainFrame:SetSize(25, 25)
    toggleMainFrame:SetPoint("RIGHT", searchBar, "LEFT", 0, 0)
    toggleMainFrame:SetChecked(true)
    toggleMainFrame:SetParent(searchBar)
    toggleMainFrame:SetFrameStrata("HIGH")
    toggleMainFrame:SetScript("OnClick", function()
        if(toggleMainFrame:GetChecked()) then
            repSearch.mainFrame:Show()
            ReputationFrame.ScrollBox:Hide()
            ReputationFrame.ScrollBar:Hide()
            repSearch.F.ADDON_VISIBLE = true

        else
            repSearch.mainFrame:Hide()
            ReputationFrame.ScrollBox:Show()
            ReputationFrame.ScrollBar:Show()
            repSearch.F.ADDON_VISIBLE = false
        end

    end)
    toggleMainFrame:Show()

    if(toggleMainFrame:GetChecked()) then
        repSearch.mainFrame:Show()
        ReputationFrame.ScrollBox:Hide()
        ReputationFrame.ScrollBar:Hide()
    else
        repSearch.mainFrame:Hide()
        ReputationFrame.ScrollBox:Show()
        ReputationFrame.ScrollBar:Show()

    end

    repSearch.mainFrame.toggleMainFrame = toggleMainFrame

    local expandDownwardsButton = repSearch.persistentFramePool:Acquire("UIButtonTemplate")
	expandDownwardsButton:SetParent(repSearch.mainFrame)
	expandDownwardsButton:SetSize(20, 20)
	expandDownwardsButton:SetPoint("RIGHT", toggleMainFrame, "LEFT", 0, -expandDownwardsButton:GetHeight()/4)

	expandDownwardsButton:SetNormalTexture(293770)
	expandDownwardsButton:SetPushedTexture(293769)

	expandDownwardsButton:RegisterForClicks("LeftButtonDown")
	expandDownwardsButton:SetScript("OnClick", function(self, button, down)
		repSearch.mainFrame.expanded = not repSearch.mainFrame.expanded

		if(repSearch.mainFrame.expanded) then
			repSearch.mainFrame:SetSize(repSearch.mainFrame:GetWidth(), repSearch.mainFrame:GetHeight() * 1.5)
			CharacterFrameTab1:ClearAllPoints()
			CharacterFrameTab1:SetWidth(CharacterFrameTab1:GetWidth()-2)
			CharacterFrameTab1:SetPoint("TOPLEFT", repSearch.mainFrame, "BOTTOMLEFT", 0, 0)

		elseif(not repSearch.mainFrame.expanded) then
			repSearch.mainFrame:SetSize(repSearch.mainFrame:GetWidth(), repSearch.mainFrame:GetHeight() / 1.5)
			CharacterFrameTab1:ClearAllPoints()
			CharacterFrameTab1:SetWidth(CharacterFrameTab1:GetWidth()+2)
			insertPointsIntoFrame(CharacterFrameTab1, pveFrameTab1_Point)

		end

		
        repSearch.mainFrame:HookScript("OnShow", function()
            CharacterFrameTab1:ClearAllPoints()
            CharacterFrameTab1:SetWidth(CharacterFrameTab1:GetWidth()-2)
		CharacterFrameTab1:SetPoint("TOPLEFT", repSearch.mainFrame, "BOTTOMLEFT", 0, 0)
	end)
	repSearch.mainFrame:HookScript("OnHide", function()
		CharacterFrameTab1:ClearAllPoints()
		CharacterFrameTab1:SetWidth(CharacterFrameTab1:GetWidth()+2)
		insertPointsIntoFrame(CharacterFrameTab1, pveFrameTab1_Point)
	end)
	end)
    expandDownwardsButton:Show()


    local detailFrame = repSearch.persistentFramePool:Acquire("ChatConfigBorderBoxTemplate")
    detailFrame:SetSize(200, 250)
    detailFrame:SetPoint("LEFT", ReputationFrame, "RIGHT", 5, 70)
    detailFrame:SetParent(repSearch.mainFrame)
    detailFrame.InsertData = function(index)
        repSearch.F.CURRENTLY_WATCHED_FACTION = index
        detailFrame.renownButton.factionID = index

        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive = GetFactionInfo(index)
        local majorData, friendshipInfo, friendshipRanks

        if(factionID) then
            friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)

            if(friendshipInfo.friendshipFactionID ~= 0) then
                friendshipRanks= C_GossipInfo.GetFriendshipReputationRanks(factionID)
            elseif(C_Reputation.IsMajorFaction(factionID)) then
                majorData = C_MajorFactions.GetMajorFactionData(factionID)

                if(majorData) then
                    local rewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, majorData.renownLevel+1)

                    repSearch.mainFrame.nextRewardFrame.rewardForLevel:SetText("Reward for Level "..majorData.renownLevel+1)
                    repSearch.mainFrame.nextRewardFrame.header:SetText(rewards[1].name)
                    repSearch.mainFrame.nextRewardFrame.icon:SetBackdrop( { bgFile=rewards[1].icon, tileSize=16, tile=true} )
                    repSearch.mainFrame.nextRewardFrame.textFrame:SetText(rewards[1].description:gsub("Account Unlock|r|n", "").."|r")
                end
            else
                
            end
            
            repSearch.mainFrame.nextRewardFrame:SetShown(C_Reputation.IsMajorFaction(factionID))

            detailFrame.descriptionFrame.header:SetText(name)
            detailFrame.descriptionFrame.textFrame:SetText(description)

            if(canToggleAtWar) then
                detailFrame.settingsFrame.atWarButton:Enable()
                detailFrame.settingsFrame.atWarButton:SetChecked(atWarWith)
                detailFrame.settingsFrame.atWarButton.text.fontString:SetTextColor(1, 1, 1, 1)
            else
                detailFrame.settingsFrame.atWarButton:Disable()
                detailFrame.settingsFrame.atWarButton.text.fontString:SetTextColor(0.4, 0.4, 0.4, 1)
            end

            if(not isHeader) then
                detailFrame.settingsFrame.inactiveButton:Enable()
                detailFrame.settingsFrame.inactiveButton.text.fontString:SetTextColor(1, 1, 1, 1)
            else
                detailFrame.settingsFrame.inactiveButton:Disable()
                detailFrame.settingsFrame.inactiveButton.text.fontString:SetTextColor(0.4, 0.4, 0.4, 1)
            end

            if(isWatched) then
                detailFrame.settingsFrame.experienceButton:SetChecked(true)
            end

            SetSelectedFaction(repSearch.F.CURRENTLY_WATCHED_FACTION)
            detailFrame.renownButton:Refresh()

            if(canSetInactive) then
                detailFrame.settingsFrame.inactiveButton:SetChecked(IsFactionInactive(index))
            end
        end
    end

    local closeButton = repSearch.persistentFramePool:Acquire("UIPanelCloseButton")
    closeButton:SetSize(25, 25)
    closeButton:SetPoint("TOPRIGHT", detailFrame, "TOPRIGHT")
    closeButton:SetParent(detailFrame)
    closeButton:SetFrameStrata("DIALOG")
    closeButton:Show()
    detailFrame.closeButton = closeButton
    
    repSearch.mainFrame.detailFrame = detailFrame

    local descriptionFrame = repSearch.persistentFramePool:Acquire("BackdropTemplate")
    descriptionFrame:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", 4, -5)
    descriptionFrame:SetParent(detailFrame)
    descriptionFrame:SetSize(detailFrame:GetWidth()-7, detailFrame:GetHeight() * 0.6)
    descriptionFrame:Show()

    detailFrame.descriptionFrame = descriptionFrame

    local descriptionFrameBackground = repSearch.persistentTexturePool:Acquire()
    descriptionFrameBackground:SetSize(descriptionFrame:GetWidth(), descriptionFrame:GetHeight())
    descriptionFrameBackground:SetTexture("interface\\paperdollinfoframe\\ui-character-reputation-detailbackground")
    descriptionFrameBackground:SetTexCoord(0, 0.73, 0, 0.98)
    descriptionFrameBackground:SetPoint("TOPLEFT", descriptionFrame, "TOPLEFT")
    descriptionFrameBackground:SetParent(descriptionFrame)
    descriptionFrameBackground:Show()

    detailFrame.descriptionFrame.background = descriptionFrameBackground

    local descriptionFrameHeader = repSearch.persistentHeaderTextPool:Acquire()
    descriptionFrameHeader:SetText("HEADER")
    descriptionFrameHeader:SetWordWrap(true)
    descriptionFrameHeader:SetJustifyH("LEFT")
    descriptionFrameHeader:SetWidth(descriptionFrame:GetWidth()-18)
    descriptionFrameHeader:SetPoint("TOPLEFT", descriptionFrame, "TOPLEFT", 10, -12)
    descriptionFrameHeader:SetParent(descriptionFrame)
    descriptionFrameHeader:Show()

    detailFrame.descriptionFrame.header = descriptionFrameHeader

    local descriptionFrameDescription = repSearch.persistentNormalTextPool:Acquire()
    descriptionFrameDescription:SetText("DESCRIPTION")
    descriptionFrameDescription:SetPoint("TOPLEFT", descriptionFrameHeader, "BOTTOMLEFT", 0, -5)
    descriptionFrameDescription:SetParent(descriptionFrame)
    descriptionFrameDescription:SetSize(descriptionFrameHeader:GetWidth()-20, descriptionFrame:GetHeight()*0.7)
    descriptionFrameDescription:SetJustifyV("TOP")
    descriptionFrameDescription:SetWordWrap(true)
    descriptionFrameDescription:Show()

    detailFrame.descriptionFrame.textFrame = descriptionFrameDescription

    local detailFrameSettings = repSearch.persistentFramePool:Acquire("BackdropTemplate")
    detailFrameSettings:SetPoint("TOPLEFT", descriptionFrame, "BOTTOMLEFT", 0, 5)
    detailFrameSettings:SetParent(detailFrame)
    detailFrameSettings:SetSize(detailFrame:GetWidth()-7, detailFrame:GetHeight() * 0.4 - 5)
    repSearch.createFrameBackgroundWithSolidColor(detailFrameSettings, 0, 0.1, 0.1, 0.1, 0.6)
    detailFrameSettings:Show()

    detailFrame.settingsFrame = detailFrameSettings

    local atWarButton = repSearch.persistentFramePool:Acquire("UICheckButtonTemplate")
    atWarButton:SetSize(25, 25)
    atWarButton:SetPoint("TOPLEFT", detailFrameSettings, "TOPLEFT", 0, -2)
    atWarButton:SetChecked(false)
    atWarButton:SetParent(detailFrameSettings)
    atWarButton:SetScript("OnClick", function()
        FactionToggleAtWar(repSearch.F.CURRENTLY_WATCHED_FACTION)
    end)
    atWarButton:Show()
    detailFrame.settingsFrame.atWarButton = atWarButton

    local atWarButtonText = repSearch.createFrameWithFontStringAttached("persistent", "BackdropTemplate", detailFrameSettings, detailFrameSettings:GetWidth()*0.8, detailFrameSettings:GetHeight()*0.25, 11)
    atWarButtonText:SetPoint("LEFT", atWarButton, "RIGHT")
    atWarButtonText.fontString:SetText("At War")

    atWarButton.text = atWarButtonText

    local inactiveButton = repSearch.persistentFramePool:Acquire("UICheckButtonTemplate")
    inactiveButton:SetSize(25, 25)
    inactiveButton:SetPoint("TOP", atWarButton, "BOTTOM")
    inactiveButton:SetParent(detailFrameSettings)
    inactiveButton:SetScript("OnClick", function()
        local _, _, _, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(repSearch.F.CURRENTLY_WATCHED_FACTION)

        if(inactiveButton:GetChecked()) then
            SetFactionInactive(repSearch.F.CURRENTLY_WATCHED_FACTION)
        else
            SetFactionActive(repSearch.F.CURRENTLY_WATCHED_FACTION)
        end

        local newIndex = repSearch.getNewIndex(factionID)
        detailFrame.InsertData(newIndex)
    end)
    inactiveButton:Show()
    detailFrame.settingsFrame.inactiveButton = inactiveButton

    local inactiveButtonText = repSearch.createFrameWithFontStringAttached("persistent", "BackdropTemplate", detailFrameSettings, detailFrameSettings:GetWidth()*0.8, detailFrameSettings:GetHeight()*0.25, 11)
    inactiveButtonText:SetPoint("LEFT", inactiveButton, "RIGHT")
    inactiveButtonText.fontString:SetText("Set inactive")

    inactiveButton.text = inactiveButtonText

    local experienceButton = repSearch.persistentFramePool:Acquire("UICheckButtonTemplate")
    experienceButton:SetSize(25, 25)
    experienceButton:SetPoint("TOP", inactiveButton, "BOTTOM")
    experienceButton:SetParent(detailFrameSettings)
    experienceButton:SetScript("OnClick", function()
        if(experienceButton:GetChecked()) then
            SetWatchedFactionIndex(repSearch.F.CURRENTLY_WATCHED_FACTION)
        else
            SetWatchedFactionIndex(-1)
        end
    end)
    experienceButton:Show()
    detailFrame.settingsFrame.experienceButton = experienceButton

    local experienceButtonText = repSearch.createFrameWithFontStringAttached("persistent", "BackdropTemplate", detailFrameSettings, detailFrameSettings:GetWidth()*0.8, detailFrameSettings:GetHeight()*0.25, 11)
    experienceButtonText:SetPoint("LEFT", experienceButton, "RIGHT")
    experienceButtonText.fontString:SetText("Show experience bar")


    local renownButton = repSearch.persistentFramePool:Acquire("UIPanelButtonTemplate")
    renownButton:SetText("View Renown")
    Mixin(renownButton, ReputationDetailViewRenownButtonMixin)
    renownButton:SetSize(detailFrame.settingsFrame:GetWidth()*0.5, 20)
    renownButton:SetPoint("TOPLEFT", experienceButton, "BOTTOMLEFT")
    renownButton:SetParent(detailFrameSettings)
    renownButton:SetScript("OnClick", function(self)
        MajorFactions_LoadUI();

        if MajorFactionRenownFrame:IsShown() and MajorFactionRenownFrame:GetCurrentFactionID() == self.factionID then
            ToggleMajorFactionRenown();
        else
            HideUIPanel(MajorFactionRenownFrame);
            EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", self.factionID);
            ShowUIPanel(MajorFactionRenownFrame);
        end
    end)
    renownButton:Hide()
    detailFrame.renownButton = renownButton

    local nextRewardFrame = repSearch.persistentFramePool:Acquire("ChatConfigBorderBoxTemplate")
    nextRewardFrame:SetSize(detailFrame:GetWidth(), detailFrame:GetHeight()/2)
    nextRewardFrame:SetPoint("TOPLEFT", detailFrame, "BOTTOMLEFT", 0, 0)
    nextRewardFrame:SetParent(detailFrame)

    repSearch.mainFrame.nextRewardFrame = nextRewardFrame
    
    local nextRewardFrameBackground = repSearch.persistentTexturePool:Acquire()
    nextRewardFrameBackground:SetSize(nextRewardFrame:GetWidth() - 4, nextRewardFrame:GetHeight() - 4)
    nextRewardFrameBackground:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
    nextRewardFrameBackground:SetColorTexture(0.1, 0.1, 0.1, 0.6)
    nextRewardFrameBackground:SetPoint("CENTER", nextRewardFrame, "CENTER")
    nextRewardFrameBackground:SetParent(nextRewardFrame)
    nextRewardFrameBackground:Show()

    nextRewardFrame.background = nextRewardFrameBackground

    local nextRewardIcon = repSearch.createBaseFrame("persistent", "BackdropTemplate", nextRewardFrame, 20, 20)
    nextRewardIcon:SetPoint("TOPLEFT", nextRewardFrameBackground, "TOPLEFT", 2, -2)
    nextRewardFrame.icon = nextRewardIcon

    local rewardForLevel = repSearch.persistentNormalTextPool:Acquire()
    rewardForLevel:SetText("Reward for Level 500")
    rewardForLevel:SetWordWrap(true)
    rewardForLevel:SetJustifyH("CENTER")
    rewardForLevel:SetWidth(nextRewardFrame:GetWidth() - 16 - 20)
    rewardForLevel:SetPoint("LEFT", nextRewardIcon, "RIGHT", 0, 0)
    rewardForLevel:SetParent(nextRewardFrame)
    rewardForLevel:Show()

    repSearch.mainFrame.nextRewardFrame.rewardForLevel = rewardForLevel

    local nextRewardFrameHeader = repSearch.persistentHeaderTextPool:Acquire()
    nextRewardFrameHeader:SetText("HEADER")
    nextRewardFrameHeader:SetWordWrap(true)
    nextRewardFrameHeader:SetJustifyH("CENTER")
    nextRewardFrameHeader:SetWidth(nextRewardFrame:GetWidth() - 16)
    nextRewardFrameHeader:SetPoint("TOPLEFT", nextRewardIcon, "BOTTOMLEFT", 2, -4)
    nextRewardFrameHeader:SetParent(nextRewardFrame)
    nextRewardFrameHeader:Show()

    repSearch.mainFrame.nextRewardFrame.header = nextRewardFrameHeader

    local nextRewardFrameDescription = repSearch.persistentNormalTextPool:Acquire()
    nextRewardFrameDescription:SetText("DESCRIPTION")
    nextRewardFrameDescription:SetPoint("TOPLEFT", nextRewardFrameHeader, "BOTTOMLEFT", 5, -5)
    nextRewardFrameDescription:SetParent(nextRewardFrame)
    nextRewardFrameDescription:SetSize(nextRewardFrame:GetWidth() - 20, nextRewardFrame:GetHeight()*0.7)
    nextRewardFrameDescription:SetJustifyH("CENTER")
    nextRewardFrameDescription:SetJustifyV("TOP")
    nextRewardFrameDescription:SetWordWrap(true)
    nextRewardFrameDescription:Show()

    repSearch.mainFrame.nextRewardFrame.textFrame = nextRewardFrameDescription

---@diagnostic disable-next-line: inject-field
    repSearch.mainFrame.detailFrame = detailFrame
end

repSearch.mainFrame:RegisterEvent("PLAYER_LOGIN")
repSearch.mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
repSearch.mainFrame:RegisterEvent("ADDON_LOADED")

repSearch.mainFrame:RegisterEvent("UPDATE_FACTION")
--repSearch.mainFrame:RegisterEvent("QUEST_LOG_UPDATE")
--repSearch.mainFrame:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
--repSearch.mainFrame:RegisterEvent("MAJOR_FACTION_UNLOCKED")

repSearch.mainFrame:SetScript("OnEvent", repSearch.OnEvent)
