local addonName, rs = ...
local wticc = WrapTextInColorCode

local searchBox
local eventReceiver = CreateFrame("Frame")
eventReceiver:RegisterEvent("PLAYER_ENTERING_WORLD")

local function isIDInList(id, list)
    for _, v in ipairs(list) do
        if(v.factionID == id) then
            return true
        end
    end

    return false
end

local function addDataWithIndexToList(factionData, index, factionList)
    factionData.factionIndex = index;
    tinsert(factionList, factionData);
end

local function replace_char3(pos, str, r) -- https://stackoverflow.com/questions/5249629/modifying-a-character-in-a-string-in-lua
return table.concat{str:sub(1,pos-1), r, str:sub(pos+1)}
end

local function events(self, event, ...)
    if(event == "PLAYER_ENTERING_WORLD") then
        if(ReputationFrame) then
            searchBox = CreateFrame("EditBox", nil, ReputationFrame, "SearchBoxTemplate")
            searchBox:SetSize(190, 30)
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
                --C_Reputation.ExpandAllFactionHeaders()

                local factionList = {};
                for index = 1, C_Reputation.GetNumFactions() do
                    local factionData = C_Reputation.GetFactionDataByIndex(index);

                    if(factionData) then
                        if(factionData.isCollapsed) then
                            C_Reputation.ExpandFactionHeader(index)
                        end

                        local startIndex, endIndex = string.find(string.lower(factionData.name), string.lower(boxText))
                        --local match = string.match(string.lower(factionData.name), string.lower(boxText))
                        
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
                                    if(not isIDInList(lastUpper, factionList)) then
                                        addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastUpper), index, factionList)
        
                                    end
                                elseif(factionData.isHeader == false and factionData.isChild == true) then
                                    if(lastUpper and not isIDInList(lastUpper, factionList)) then
                                        addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastUpper), index, factionList)
        
                                    end
        
                                    if(lastMiddle and not isIDInList(lastMiddle, factionList)) then
                                        addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastMiddle), index, factionList)
        
                                    end
                                elseif(factionData.isHeader == true and factionData.isChild == true) then
                                    allLowsAllowed = true

                                    if(lastUpper and not isIDInList(lastUpper, factionList)) then
                                        addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastUpper), index, factionList)
        
                                    end

                                elseif(factionData.isHeader == true and factionData.isChild == false) then
                                    allMiddleAllowed = true

                                end

                                if(startIndex) then
                                    factionData.name = string.sub(factionData.name, 0, startIndex - 1) .. wticc(string.sub(factionData.name, startIndex, endIndex), "FF2ECC40") .. string.sub(factionData.name, endIndex + 1)
                                    
                                end
    
                            end
                            
                            addDataWithIndexToList(factionData, index, factionList)

                        end
                    end
                end
            
                ReputationFrame.ScrollBox:SetDataProvider(CreateDataProvider(factionList), ScrollBoxConstants.RetainScrollPosition);
            
                ReputationFrame.ReputationDetailFrame:Refresh();
            end
        end

    end
end

eventReceiver:SetScript("OnEvent", events)