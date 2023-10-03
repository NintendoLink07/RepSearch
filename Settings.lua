local addonName, repSearch = ...

local function compareSettings()
	for index, row in ipairs(repSearch.defaultOptionSettings) do
		if(row.key ~= RepSearch_SavedOptionSettings[index].key or row.title ~= RepSearch_SavedOptionSettings[index].title) then
			return false
		end
	end

	return true
end

repSearch.saveCurrentSettings = function()
	RepSearch_SavedOptionSettings = repSearch.defaultOptionSettings
end

repSearch.loadSettings = function()
    repSearch.defaultOptionSettings = {

	}

	if(RepSearch_SavedOptionSettings) then
		if(compareSettings()) then
			repSearch.defaultOptionSettings = RepSearch_SavedOptionSettings
		else
			repSearch.saveCurrentSettings()
		end
	else
		repSearch.saveCurrentSettings()
	end

	return repSearch.defaultOptionSettings
end