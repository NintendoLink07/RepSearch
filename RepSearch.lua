local addonName, rs = ...
local wticc = WrapTextInColorCode

local searchBox
local eventReceiver = CreateFrame("Frame", "RepSearch_EventReceiver")
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
                local allChildrenAllowed = false
                --C_Reputation.ExpandAllFactionHeaders()

                local factionList = {};
                for index = 1, C_Reputation.GetNumFactions() do
                    local factionData = C_Reputation.GetFactionDataByIndex(index);

                    if(factionData) then
                        if(factionData.isCollapsed) then
                            C_Reputation.ExpandFactionHeader(index)
                        end

                        local foundText = string.find(string.lower(factionData.name), string.lower(boxText))
                        
                        if(factionData.isHeader == true and factionData.isChild == false) then
                            lastUpper = factionData.factionID
                            lastMiddle = nil
                            allChildrenAllowed = false
                            
                        elseif(factionData.isHeader == true and factionData.isChild == true or factionData.isHeader == false and factionData.isChild == false) then
                            lastMiddle = factionData.factionID
                            allChildrenAllowed = false

                        end

                        if(foundText or allChildrenAllowed) then
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
                                    allChildrenAllowed = true

                                    if(lastUpper and not isIDInList(lastUpper, factionList)) then
                                        addDataWithIndexToList(C_Reputation.GetFactionDataByID(lastUpper), index, factionList)
        
                                    end

                                end
                            end
                            
                            addDataWithIndexToList(factionData, index, factionList)

                            print(factionData.name, factionData.isHeader, factionData.isChild, lastUpper and C_Reputation.GetFactionDataByID(lastUpper).name, isIDInList(lastUpper, factionList), lastMiddle and C_Reputation.GetFactionDataByID(lastMiddle).name, isIDInList(lastMiddle, factionList))

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