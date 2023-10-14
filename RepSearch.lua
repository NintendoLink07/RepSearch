local addonName, repSearch = ...

local reputationDataStructure = {}

repSearch.getNewIndex = function(argID)
    for index = 1, GetNumFactions(), 1 do
        local name, _, _, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(index)

        if(argID == factionID) then
            return index
        end
    end
end

repSearch.createDataStructure = function()
    reputationDataStructure = {}
    local currentHeader, currentSubheader, currentChild

    for index = 1, GetNumFactions(), 1 do
        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus  = GetFactionInfo(index)

        if(isHeader and isCollapsed) then
            ExpandFactionHeader(index)
        end

        local majorData, friendshipInfo, friendshipRanks

        if(factionID) then
            friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)

            if(friendshipInfo.friendshipFactionID ~= 0) then
                friendshipRanks= C_GossipInfo.GetFriendshipReputationRanks(factionID)
            end
            if(C_Reputation.IsMajorFaction(factionID)) then
                majorData = C_MajorFactions.GetMajorFactionData(factionID)
            end
        end

        if(isHeader == true) then
            if(hasRep == true and isChild) then --true true true --SUBHEADER#1 --SUBHEADER WITH REP
                currentSubheader = #reputationDataStructure[currentHeader].Subheader + 1
                currentChild = 0

                reputationDataStructure[currentHeader].Subheader[currentSubheader] = {
                    Index = currentSubheader,
                    FactionIndex = index,
                    FactionID = factionID,
                    Name = name,
                    Type = repSearch.C.SUBHEADER2,
                    Layer = 2,
                    Description = description,
                    FactionType = majorData and "major" or friendshipInfo.friendshipFactionID ~= 0 and "friendship" or "normal",
                    BarMin = (majorData or friendshipInfo.friendshipFactionID ~= 0) and 0 or barMin,
                    BarMax = majorData and majorData.renownLevelThreshold or friendshipInfo.friendshipFactionID ~= 0 and (friendshipInfo.nextThreshold or friendshipInfo.maxRep) or barMax,
                    BarValue = majorData and majorData.renownReputationEarned or friendshipInfo.friendshipFactionID ~= 0 and friendshipInfo.standing or barValue,
                    Standing = majorData and majorData.renownLevel or friendshipInfo.friendshipFactionID ~= 0 and friendshipRanks.currentLevel or standingID,
                    IsInactive = IsFactionInactive(index),
                    IsWatched = isWatched,
                    Parent = currentHeader,
                    Children = {}
                }

            elseif(hasRep == false) then
                if(isChild == true) then --true false true --SUBHEADER#2 --SUBHEADER WITH NO REP
                    currentSubheader = #reputationDataStructure[currentHeader].Subheader + 1
                    currentChild = 0

                    reputationDataStructure[currentHeader].Subheader[currentSubheader] = {
                        Index = currentSubheader,
                        FactionIndex = index,
                        FactionID = factionID,
                        Name = name,
                        Type = repSearch.C.SUBHEADER1,
                        Layer = 2,
                        Description = description,
                        FactionType = majorData and "major" or friendshipInfo.friendshipFactionID ~= 0 and "friendship" or "normal",
                        BarMin = (majorData or friendshipInfo.friendshipFactionID ~= 0) and 0 or barMin,
                        BarMax = majorData and majorData.renownLevelThreshold or friendshipInfo.friendshipFactionID ~= 0 and (friendshipInfo.nextThreshold or friendshipInfo.maxRep) or barMax,
                        BarValue = majorData and majorData.renownReputationEarned or friendshipInfo.friendshipFactionID ~= 0 and friendshipInfo.standing or barValue,
                        Standing = majorData and majorData.renownLevel or friendshipInfo.friendshipFactionID ~= 0 and friendshipRanks.currentLevel or standingID,
                        IsInactive = IsFactionInactive(index),
                        IsWatched = isWatched,
                        Parent = currentHeader,
                        Children = {}
                    }


                elseif(isChild == false) then --true false false --HEADER --EXPANSION / GUILD HEADER
                    currentHeader = #reputationDataStructure + 1

                    reputationDataStructure[currentHeader] = {
                        Index = currentHeader,
                        FactionIndex = index,
                        FactionID = factionID,
                        Name = name,
                        Type = repSearch.C.HEADER,
                        Layer = 1,
                        Description = description,
                        FactionType = majorData and "major" or friendshipInfo.friendshipFactionID ~= 0 and "friendship" or "normal",
                        BarMin = (majorData or friendshipInfo.friendshipFactionID ~= 0) and 0 or barMin,
                        BarMax = majorData and majorData.renownLevelThreshold or friendshipInfo.friendshipFactionID ~= 0 and (friendshipInfo.nextThreshold or friendshipInfo.maxRep) or barMax,
                        BarValue = majorData and majorData.renownReputationEarned or friendshipInfo.friendshipFactionID ~= 0 and friendshipInfo.standing or barValue,
                        Standing = majorData and majorData.renownLevel or friendshipInfo.friendshipFactionID ~= 0 and friendshipRanks.currentLevel or standingID,
                        IsInactive = IsFactionInactive(index),
                        IsWatched = isWatched,
                        Subheader = {},
                    }

                    currentSubheader = 0
                end
            elseif(hasRep == nil) then --INACTIVE HEADER
                currentHeader = #reputationDataStructure + 1

                reputationDataStructure[currentHeader] = {
                    Index = currentHeader,
                    FactionIndex = -1,
                    FactionID = 9999999,
                    Name = "Inactive",
                    Type = repSearch.C.HEADER,
                    Layer = 1,
                    Description = "Inactive factions",
                    FactionType = "normal",
                    BarMin = 0,
                    BarMax = 0,
                    BarValue = 0,
                    Standing = 1,
                    IsInactive = false,
                    Subheader = {},
                }

            end
        elseif(isHeader == false) then
            if(isChild == true) then --false false true --CHILD#2 --UNDER SUBHEADER
                currentChild = currentChild + 1

                reputationDataStructure[currentHeader].Subheader[currentSubheader].Children[currentChild] = {
                    Index = currentChild,
                    FactionIndex = index,
                    FactionID = factionID,
                    Name = name,
                    Type = repSearch.C.CHILDSUBHEADER,
                    Layer = 3,
                    Description = description,
                    FactionType = majorData and "major" or friendshipInfo.friendshipFactionID ~= 0 and "friendship" or "normal",
                    BarMin = (majorData or friendshipInfo.friendshipFactionID ~= 0) and 0 or barMin,
                    BarMax = majorData and majorData.renownLevelThreshold or friendshipInfo.friendshipFactionID ~= 0 and (friendshipInfo.nextThreshold or friendshipInfo.maxRep) or barMax,
                    BarValue = majorData and majorData.renownReputationEarned or friendshipInfo.friendshipFactionID ~= 0 and friendshipInfo.standing or barValue,
                    Standing = majorData and majorData.renownLevel or friendshipInfo.friendshipFactionID ~= 0 and friendshipRanks.currentLevel or standingID,
                    IsInactive = IsFactionInactive(index),
                    IsWatched = isWatched,
                    GrandParent = currentHeader,
                    Parent = currentSubheader,
                }

            elseif(isChild == false) then --false false false --CHILD#1 --UNDER HEADER / GUILD BAR
                currentSubheader = #reputationDataStructure[currentHeader].Subheader + 1

                reputationDataStructure[currentHeader].Subheader[currentSubheader] = {
                    Index = currentSubheader,
                    FactionIndex = index,
                    FactionID = factionID,
                    Name = name,
                    Type = repSearch.C.CHILDHEADER,
                    Layer = 3,
                    Description = description,
                    FactionType = majorData and "major" or friendshipInfo.friendshipFactionID ~= 0 and "friendship" or "normal",
                    BarMin = (majorData or friendshipInfo.friendshipFactionID ~= 0) and 0 or barMin,
                    BarMax = majorData and majorData.renownLevelThreshold or friendshipInfo.friendshipFactionID ~= 0 and (friendshipInfo.nextThreshold or friendshipInfo.maxRep) or barMax,
                    BarValue = majorData and majorData.renownReputationEarned or friendshipInfo.friendshipFactionID ~= 0 and friendshipInfo.standing or barValue,
                    Standing = majorData and majorData.renownLevel or friendshipInfo.friendshipFactionID ~= 0 and friendshipRanks.currentLevel or standingID,
                    IsInactive = IsFactionInactive(index),
                    IsWatched = isWatched,
                    Parent = currentHeader,
                }
            end
        end
    end
end

local function setUpStatusBar(frame, array)
    local repLevelText = repSearch.temporaryFontStringPool:Acquire()
    PixelUtil.SetPoint(repLevelText, "RIGHT", frame, "LEFT", -2, 0)
    repLevelText:SetParent(frame)
    repLevelText:SetDrawLayer("ARTWORK")
    repLevelText:Show()

    local statusBar = repSearch.temporaryStatusBarPool:Acquire("BackdropTemplate")
    PixelUtil.SetSize(statusBar, frame:GetWidth() - 2, frame:GetHeight() - 2)
    PixelUtil.SetPoint(statusBar, "CENTER", frame, "CENTER", 0, 0)
    statusBar:SetParent(frame)
    statusBar:Show()

    local colorRGBA = nil
    local friendshipInfo = C_GossipInfo.GetFriendshipReputation(array.FactionID)
    local IsMajorFaction = C_Reputation.IsMajorFaction(array.FactionID)

    if(friendshipInfo.friendshipFactionID ~= 0) then
        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipInfo.friendshipFactionID)

        statusBar:SetMinMaxValues(0, friendshipInfo.nextThreshold or friendshipInfo.maxRep)
        statusBar:SetValue(friendshipInfo.standing)
        colorRGBA = {CreateColorFromHexString(repSearch.C.AQUA):GetRGBA()}
        repLevelText:SetText(rankInfo.currentLevel .. "/" .. rankInfo.maxLevel)

    elseif(IsMajorFaction) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(array.FactionID)

        if(majorFactionData) then
            statusBar:SetMinMaxValues(0, majorFactionData.renownLevelThreshold)
            statusBar:SetValue(majorFactionData.renownReputationEarned)
            colorRGBA = {CreateColorFromHexString(repSearch.C.BLUE):GetRGBA()}
            repLevelText:SetText(majorFactionData.renownLevel)
        end

    else
        statusBar:SetMinMaxValues(array.BarMin < 0 and array.BarMin or 0, array.BarMax)
        statusBar:SetValue(array.BarValue)

        if(array.Standing > 4) then
            colorRGBA = {CreateColorFromHexString(repSearch.C.GREEN):GetRGBA()}

        elseif(array.Standing == 4 or array.Standing == 0) then
            colorRGBA = {CreateColorFromHexString(repSearch.C.YELLOW):GetRGBA()}

        elseif(array.Standing == 3) then
            colorRGBA = {CreateColorFromHexString(repSearch.C.ORANGE):GetRGBA()}

        elseif(array.Standing == 2) then
            colorRGBA = {CreateColorFromHexString(repSearch.C.MAROON):GetRGBA()}

        elseif(array.Standing == 1) then
            colorRGBA = {CreateColorFromHexString(repSearch.C.RED):GetRGBA()}

        end
        
        repLevelText:SetText(array.Standing.."/8")
    end

    if(colorRGBA) then
        statusBar:SetStatusBarColor(unpack(colorRGBA))
        repSearch.createFrameBorder(frame, 1, 0, 0, 0, 1)

        colorRGBA[4] = 0.1
        repSearch.createFrameWithBackgroundAndBorder(frame, 1, unpack(colorRGBA))
    end

    local childrenBarText = repSearch.temporaryFontStringPool:Acquire()
    PixelUtil.SetPoint(childrenBarText, "LEFT", statusBar, "LEFT", 3, 0)
    childrenBarText:SetText(string.sub(array.Name, 1, 25) .. ": " .. statusBar:GetValue() .. "/" .. select(2, statusBar:GetMinMaxValues()))
    childrenBarText:SetParent(statusBar)
    childrenBarText:SetDrawLayer("ARTWORK")
    childrenBarText:Show()
end

local function checkOrderedTableForValue(tbl, value)
    for k, v in ipairs(tbl) do
        if(v.Name == value) then
            return true
        end
    end

    return false
end

local function checkForString(filteredList, searchText, parentArray, childArray, index)

    if(repSearch.findInString(childArray.Name, searchText)) then
        if(checkOrderedTableForValue(filteredList, parentArray.Name) == false) then
            if(childArray.Parent and not childArray.GrandParent) then

                parentArray.numOfLayerDeep = 1
                childArray.numOfLayerDeep = 0

            elseif(childArray.GrandParent and childArray.Parent) then

                parentArray.numOfLayerDeep = 2
                parentArray.Subheader[index].numOfLayerDeep = 1
                childArray.numOfLayerDeep = 0

            elseif(not childArray.Parent and not childArray.GrandParent) then

                parentArray.numOfLayerDeep = 0
                
            end

            filteredList[#filteredList+1] = parentArray
        end
    end
end

local function sortTableForMajorFactions(key1, key2)
    if(key1 and key2) then
        if(key1.FactionType == "major" and key2.FactionType == "major" or key1.FactionType == "normal" and key2.FactionType == "normal" or key1.FactionType == "friendship" and key2.FactionType == "friendship") then

            if(key1.Standing == key2.Standing) then
                if(key1.BarValue == key2.BarValue) then
                    return key1.Name < key2.Name
                else
                    return key1.BarValue > key2.BarValue
                end
            else
                return key1.Standing > key2.Standing
            end
        elseif(key1.FactionType == "major" and key2.FactionType == "normal") then
            return true
        elseif(key1.FactionType == "major" and key2.FactionType == "friendship") then
            return true
        elseif(key1.FactionType == "friendship" and key2.FactionType == "major") then
            return false
        elseif(key1.FactionType == "friendship" and key2.FactionType == "normal") then
            return false
        elseif(key1.FactionType == "normal" and key2.FactionType == "major") then
            return false
        elseif(key1.FactionType == "normal" and key2.FactionType == "friendship") then
            return true
        end
    else
    end
end

repSearch.createFrames = function(searchText)
    repSearch.releaseAllTemporaryPools()

    local filteredList

    searchText = string.lower(searchText)

    if(searchText and searchText ~= "") then
        filteredList = {}

        for _, headerArray in ipairs(reputationDataStructure) do
            headerArray.numOfLayerDeep = -1
            checkForString(filteredList, searchText, headerArray, headerArray)

            if(headerArray.Subheader) then
                for sIndex, subheaderArray in ipairs(headerArray.Subheader) do
                    subheaderArray.numOfLayerDeep = -1
                    checkForString(filteredList, searchText, headerArray, subheaderArray)

                    if(subheaderArray.Children) then
                        for _, childrenArray in ipairs(subheaderArray.Children) do
                            childrenArray.numOfLayerDeep = -1
                            checkForString(filteredList, searchText, headerArray, childrenArray, sIndex)
                        end
                    end
                end
            end
        end
    end

    local lastMainReputationFrame = nil

    local rowHeight = 20

    for _, headerArray in ipairs(filteredList or reputationDataStructure) do

        local mainReputationFrame = repSearch.temporaryFramePool:Acquire("ResizeLayoutFrame, BackdropTemplate")
        PixelUtil.SetPoint(mainReputationFrame, "TOPLEFT", lastMainReputationFrame or repSearch.mainFrame.mainScrollFrame.mainContainer, lastMainReputationFrame and "BOTTOMLEFT" or "TOPLEFT", lastMainReputationFrame and 0 or 4, lastMainReputationFrame and -4 or 0)
        mainReputationFrame:SetWidth(repSearch.mainFrame.mainScrollFrame.mainContainer:GetWidth())
        mainReputationFrame:SetParent(repSearch.mainFrame.mainScrollFrame.mainContainer)
        mainReputationFrame:SetFrameStrata("HIGH")
        mainReputationFrame:Hide()

        repSearch.mainFrame.mainScrollFrame.mainContainer[headerArray.Name] = mainReputationFrame

        local headerFrame = repSearch.temporaryFramePool:Acquire("BackdropTemplate")
        PixelUtil.SetPoint(headerFrame, "TOPLEFT", mainReputationFrame, "TOPLEFT", 0, 0)
        PixelUtil.SetSize(headerFrame, 300, rowHeight)
        headerFrame:SetParent(mainReputationFrame)
        headerFrame:Show()

        mainReputationFrame.headerFrame = headerFrame

        local expandHeaderButton = repSearch.temporaryFramePool:Acquire("UICheckButtonTemplate")
        expandHeaderButton:SetChecked(headerArray.numOfLayerDeep == 0 or headerArray.numOfLayerDeep == 1 or headerArray.numOfLayerDeep == 2 or RepSearch_SavedOptionSettings[headerArray.FactionID] and RepSearch_SavedOptionSettings[headerArray.FactionID].value)
        PixelUtil.SetSize(expandHeaderButton, 25, 25)
        PixelUtil.SetPoint(expandHeaderButton, "LEFT", headerFrame, "LEFT", -2, 0)
        expandHeaderButton:SetParent(headerFrame)
        expandHeaderButton:SetScript("OnClick", function()
            if(expandHeaderButton:GetChecked()) then
                mainReputationFrame.headerFrame.allSubheadersFrame:Show()

                mainReputationFrame:MarkDirty()
            else
                mainReputationFrame.headerFrame.allSubheadersFrame:Hide()

                mainReputationFrame:MarkDirty()
            end

            RepSearch_SavedOptionSettings[headerArray.FactionID] = {
                key = headerArray.Name,
                type = "checkbox",
                title = "Expand " .. headerArray.Name .. " header",
                id = headerArray.FactionID,
                value = expandHeaderButton:GetChecked()
            }

        end)
        expandHeaderButton:Show()

        headerFrame.expandButton = expandHeaderButton

        local headerBar = repSearch.temporaryFramePool:Acquire("BackdropTemplate")
        PixelUtil.SetPoint(headerBar, "LEFT", expandHeaderButton, "RIGHT", -5, 0)
        PixelUtil.SetSize(headerBar, headerFrame:GetWidth(), rowHeight)
        headerBar:SetParent(headerFrame)
        headerBar:Show()

        headerFrame.bar = headerBar

        local headerBarText = repSearch.temporaryFontStringPool:Acquire()
        PixelUtil.SetPoint(headerBarText, "LEFT", headerBar, "LEFT", 5, 0)
        headerBarText:SetText(headerArray.Name)
        headerBarText:SetParent(headerBar)
        headerBarText:Show()

        headerFrame.bar.text = headerBarText

        if(headerArray.Subheader) then
            table.sort(headerArray.Subheader, sortTableForMajorFactions)

            local allSubheadersFrame = repSearch.temporaryFramePool:Acquire("ResizeLayoutFrame, BackdropTemplate")
            PixelUtil.SetPoint(allSubheadersFrame, "TOPLEFT", headerFrame, "BOTTOMLEFT", 0, 0)
            allSubheadersFrame:SetParent(mainReputationFrame)
            allSubheadersFrame:SetShown(headerArray.numOfLayerDeep == 0 or headerArray.numOfLayerDeep == 1 or headerArray.numOfLayerDeep == 2 or RepSearch_SavedOptionSettings[headerArray.FactionID] and RepSearch_SavedOptionSettings[headerArray.FactionID].value)

            headerFrame.allSubheadersFrame = allSubheadersFrame

            local lastSubheaderFrame = nil

            for _, subheaderArray in ipairs(headerArray.Subheader) do
                
                if(filteredList == nil or subheaderArray.numOfLayerDeep == 1 or subheaderArray.numOfLayerDeep == 0 or headerArray.numOfLayerDeep == 0) then

                    local subheaderFrame = repSearch.temporaryFramePool:Acquire("ResizeLayoutFrame, BackdropTemplate")
                    PixelUtil.SetPoint(subheaderFrame, "TOPLEFT", lastSubheaderFrame or allSubheadersFrame, lastSubheaderFrame and "BOTTOMLEFT" or "TOPLEFT", 0, 0)
                    subheaderFrame:SetParent(allSubheadersFrame)
                    subheaderFrame:SetMouseClickEnabled(true)

                    subheaderFrame:SetScript("OnMouseDown", function()
                        repSearch.mainFrame.detailFrame.InsertData(subheaderArray.FactionIndex, "subheader")
                        repSearch.mainFrame.detailFrame:Show()
                    end)
                    subheaderFrame:Show()

                    local expandSubheaderButton = repSearch.temporaryFramePool:Acquire("UICheckButtonTemplate")
                    PixelUtil.SetSize(expandSubheaderButton, 20, 20)
                    PixelUtil.SetPoint(expandSubheaderButton, "TOPLEFT", subheaderFrame, "TOPLEFT", 5, 2)
                    expandSubheaderButton:SetChecked(subheaderArray.numOfLayerDeep == 1 or subheaderArray.numOfLayerDeep == 0 or headerArray.numOfLayerDeep == 0 or RepSearch_SavedOptionSettings[subheaderArray.FactionID] and RepSearch_SavedOptionSettings[subheaderArray.FactionID].value or false)
                    expandSubheaderButton:SetParent(subheaderFrame)
                    expandSubheaderButton:SetScript("OnClick", function()
                        if(expandSubheaderButton:GetChecked()) then
                            subheaderFrame.allChildrensFrame:Show()
            
                            mainReputationFrame:MarkDirty()
                        else
                            subheaderFrame.allChildrensFrame:Hide()
            
                            mainReputationFrame:MarkDirty()
                        end

                        RepSearch_SavedOptionSettings[subheaderArray.FactionID] = {
                            key = subheaderArray.Name,
                            type = "checkbox",
                            title = "Expand " .. subheaderArray.Name .. " header",
                            id = subheaderArray.FactionID,
                            value = expandSubheaderButton:GetChecked()
                        }
                    end)

                    local subheaderBar = repSearch.temporaryFramePool:Acquire("BackdropTemplate")
                    PixelUtil.SetPoint(subheaderBar, "LEFT", expandSubheaderButton, "RIGHT", 20, 0)
                    PixelUtil.SetSize(subheaderBar, 300-40, rowHeight)
                    subheaderBar:SetParent(subheaderFrame)
                    subheaderBar:Show()

                    setUpStatusBar(subheaderBar, subheaderArray)

                    lastSubheaderFrame = subheaderFrame
                    
                    if(subheaderArray.Children) then
                        local lastChildrenFrame = nil
                        
                        expandSubheaderButton:Show()
                        
                        table.sort(subheaderArray.Children, sortTableForMajorFactions)
                        
                        local allChildrensFrame = repSearch.temporaryFramePool:Acquire("ResizeLayoutFrame, BackdropTemplate")
                        PixelUtil.SetPoint(allChildrensFrame, "TOPLEFT", subheaderBar, "BOTTOMLEFT", 10, 0)
                        allChildrensFrame:SetParent(subheaderFrame)
                        allChildrensFrame:SetShown(subheaderArray.numOfLayerDeep == 0 or subheaderArray.numOfLayerDeep == 1 or headerArray.numOfLayerDeep == 0 or RepSearch_SavedOptionSettings[subheaderArray.FactionID] and RepSearch_SavedOptionSettings[subheaderArray.FactionID].value)
                        
                        subheaderFrame.allChildrensFrame = allChildrensFrame

                        for _, childrenArray in ipairs(subheaderArray.Children) do
                            if(filteredList == nil or subheaderArray.numOfLayerDeep == 0 or childrenArray.numOfLayerDeep == 0 and subheaderArray.numOfLayerDeep == 1 or headerArray.numOfLayerDeep == 0) then
                                local childrenFrame = repSearch.temporaryFramePool:Acquire("BackdropTemplate")
                                PixelUtil.SetSize(childrenFrame, 250, 20)
                                PixelUtil.SetPoint(childrenFrame, "TOPLEFT", lastChildrenFrame or allChildrensFrame, lastChildrenFrame and "BOTTOMLEFT" or "TOPLEFT", 0, 0)
                                childrenFrame:SetParent(allChildrensFrame)
                                childrenFrame:SetMouseClickEnabled(true)
                                childrenFrame:SetScript("OnMouseDown", function()
                                    childrenFrame:Show()
                                    repSearch.mainFrame.detailFrame.InsertData(childrenArray.FactionIndex, "children")
                                    repSearch.mainFrame.detailFrame:Show()
                                end)
                                childrenFrame:Show()

                                local childrenBar = repSearch.temporaryFramePool:Acquire("BackdropTemplate")
                                PixelUtil.SetSize(childrenBar, childrenFrame:GetWidth(), rowHeight)
                                PixelUtil.SetPoint(childrenBar, "TOPLEFT", childrenFrame, "TOPLEFT", 0, 0)
                                childrenBar:SetParent(childrenFrame)
                                childrenBar:Show()

                                setUpStatusBar(childrenBar, childrenArray)

                                lastChildrenFrame = childrenFrame
                            end
                        end

                        allChildrensFrame:MarkDirty()
                    end
                        
                end
            end
        end

        lastMainReputationFrame = mainReputationFrame
        
        mainReputationFrame:Show()
        mainReputationFrame:MarkDirty()

    end
end

repSearch.OnEvent = function(self, event, ...)
    if(event == "PLAYER_LOGIN") then
        repSearch.releaseAllPersistentPools()
        repSearch.createRepSearch()
    elseif(event == "UPDATE_FACTION") then
        if(repSearch.F.ADDON_VISIBLE == true) then
            repSearch.createDataStructure()

            if(repSearch.mainFrame.mainScrollFrame) then
                repSearch.createFrames(tostring(repSearch.mainFrame.searchBar:GetText()))
            end
        end
    elseif(event == "PLAYER_ENTERING_WORLD") then
        repSearch.releaseAllTemporaryPools()
        repSearch.createDataStructure()
    end
end