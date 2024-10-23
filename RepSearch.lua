local addonName, rs = ...
local wticc = WrapTextInColorCode

local searchBox
local eventReceiver = CreateFrame("Frame")
eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")
--eventReceiver:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
--eventReceiver:RegisterEvent("MAJOR_FACTION_UNLOCKED")
--eventReceiver:RegisterEvent("QUEST_LOG_UPDATE")
--eventReceiver:RegisterEvent("UPDATE_FACTION")

REPSEARCH_SETTINGS = {}

local function addDataWithIndexToList(factionData, index, factionList)
    factionData.factionIndex = index;
    tinsert(factionList, factionData);
end

local category = Settings.RegisterVerticalLayoutCategory(addonName)
local factionList = {}
local firstActualIndex = 1

local function isIDInList(id)
    for _, v in ipairs(factionList) do
        if(v.factionID == id) then
            return v
        end
    end

    return nil
end

local ReputationType = EnumUtil.MakeEnum(
	"Standard",
	"Friendship",
	"MajorFaction"
);

local function checkForDescription(description, boxText)
    local startIndex, endIndex, isNotTitle

    if(REPSEARCH_SETTINGS.includeDescriptions) then
        local startIndex, endIndex = string.find(string.lower(description), boxText)

        if(startIndex) then
            isNotTitle = true
        end
    end

    return startIndex, endIndex, isNotTitle
end

local function checkForStandingReaction(factionData, boxText)
    local isNotTitle
    local type = ReputationType.Standard

    local friendshipData = C_GossipInfo.GetFriendshipReputation(factionData.factionID);
    local isFriendshipReputation = friendshipData and friendshipData.friendshipFactionID > 0;
    if isFriendshipReputation then
        type = ReputationType.Friendship;
    end

    if C_Reputation.IsMajorFaction(factionData.factionID) then
        type = ReputationType.MajorFaction;
    end

    local reputationStandingtext

    if(type == ReputationType.Standard) then
        reputationStandingtext = _G["FACTION_STANDING_LABEL" .. factionData.reaction]

    elseif(type == ReputationType.Friendship) then
        reputationStandingtext = friendshipData.reaction
        
    elseif(type == ReputationType.MajorFaction) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionData.factionID);
        
        reputationStandingtext = RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel

    end

    local startIndex, endIndex = string.find(string.lower(reputationStandingtext), boxText)
    
    if(startIndex) then
        isNotTitle = true
    end

    return startIndex, endIndex, isNotTitle
end

local function loadRepSearch()
    if(ReputationFrame) then
        local setting = Settings.RegisterAddOnSetting(category, "REPSEARCH_IncludeDescriptions", "includeDescriptions", REPSEARCH_SETTINGS, "boolean", "Include descriptions", false)
        Settings.CreateCheckbox(category, setting, "Include/exclude faction description searching (may lag on lower end machines).")
        Settings.RegisterAddOnCategory(category)
        
        local settingsButton = CreateFrame("Button", "RepSearch_SettingsButton", ReputationFrame, "UIButtonTemplate")
        settingsButton:SetSize(14, 14)
        settingsButton:SetNormalAtlas("QuestLog-icon-setting")
        settingsButton:SetHighlightAtlas("QuestLog-icon-setting")
        settingsButton:SetScript("OnClick", function()
            REPSEARCH_OpenInterfaceOptions()
        end)
        settingsButton:SetFrameStrata("HIGH")
        settingsButton:SetPoint("RIGHT", CharacterFrameCloseButton, "LEFT", -2, 0)
    
        searchBox = CreateFrame("EditBox", nil, ReputationFrame, "SearchBoxTemplate")
        searchBox:SetSize(190, 35)
        searchBox:SetPoint("RIGHT", ReputationFrame.filterDropdown, "LEFT", -5, 0)
        searchBox:SetScript("OnTextChanged", function(self)
            SearchBoxTemplate_OnTextChanged(self)
    
            ReputationFrame:Update()
    
        end)
    
        ReputationFrame.Update = function()
            ReputationFrame.ScrollBox:Flush()
    
            local boxText = searchBox:GetText() or ""
            local lastUpper, lastMiddle
            local allMiddleAllowed, allLowsAllowed
            local isNotTitle
            --C_Reputation.ExpandAllFactionHeaders()
    
            factionList = {}

            local lowerBoxText = string.lower(boxText)
    
            for index = 1, C_Reputation.GetNumFactions() do
                isNotTitle = false
                local factionData = C_Reputation.GetFactionDataByIndex(index);
    
                if(factionData) then
                    if(factionData.isCollapsed) then
                        C_Reputation.ExpandFactionHeader(index)
                    end
    
                    local startIndex, endIndex = string.find(string.lower(factionData.name), lowerBoxText)
    
                    if(not startIndex) then
                        startIndex, endIndex, isNotTitle = checkForDescription(factionData.description, lowerBoxText)
                        
                        if(not isNotTitle) then
                            startIndex, endIndex, isNotTitle = checkForStandingReaction(factionData, lowerBoxText)
                            
                        end
                    end
                    
                    if(factionData.isHeader == true and factionData.isChild == false) then
                        lastUpper = factionData.factionID
                        lastMiddle = nil
                        allMiddleAllowed = false
                        allLowsAllowed = false
                        
                    elseif(factionData.isHeader == true and factionData.isChild == true or factionData.isHeader == false and factionData.isChild == false) then
                        lastMiddle = factionData.factionID
                        allLowsAllowed = false
    
                    end
    
                    if(startIndex or allMiddleAllowed or allLowsAllowed) then
                        if(boxText ~= "") then
                            if(factionData.isHeader == false and factionData.isChild == false) then
                                if(not isIDInList(lastUpper)) then
                                    addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastUpper), index, factionList)
    
                                end
                            elseif(factionData.isHeader == false and factionData.isChild == true) then
                                if(lastUpper and not isIDInList(lastUpper)) then
                                    addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastUpper), index, factionList)
    
                                end
    
                                if(lastMiddle and not isIDInList(lastMiddle)) then
                                    addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastMiddle), index, factionList)
    
                                end
                            elseif(factionData.isHeader == true and factionData.isChild == true) then
                                allLowsAllowed = true
    
                                if(lastUpper and not isIDInList(lastUpper)) then
                                    addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastUpper), index, factionList)
    
                                end
    
                            elseif(factionData.isHeader == true and factionData.isChild == false) then
                                allMiddleAllowed = true
    
                            end
    
                        end
    
                        if(startIndex) then
                            if(not isNotTitle) then
                                factionData.name = string.sub(factionData.name, 0, startIndex - 1) .. wticc(string.sub(factionData.name, startIndex, endIndex), "FF2ECC40") .. string.sub(factionData.name, endIndex + 1)
                                
                            --else
                                --factionData.description = string.sub(factionData.description, 0, startIndex - 1) .. wticc(string.sub(factionData.description, startIndex, endIndex), "FF2ECC40") .. string.sub(factionData.description, endIndex + 1)
    
                            end
    
                        end
    
                        firstActualIndex = index
                        
                        addDataWithIndexToList(factionData, index, factionList)
    
                    end
    
                end
            end
    
            C_Reputation.SetSelectedFaction(firstActualIndex)
    
            ReputationFrame.ScrollBox:SetDataProvider(CreateDataProvider(factionList), ScrollBoxConstants.RetainScrollPosition);
            ReputationFrame.ReputationDetailFrame:Refresh()
        end
    
    end
end



local function events(_, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        if(ReputationFrame and not _G["RepSearch_SettingsButton"]) then
            loadRepSearch()
        end
    else

    end
end

eventReceiver:SetScript("OnEvent", events)

function REPSEARCH_OpenInterfaceOptions()
    Settings.OpenToCategory(category:GetID())
end