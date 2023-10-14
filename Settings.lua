local addonName, repSearch = ...

local function compareSettings(defaultOptions, savedSettings)
	for key, optionEntry in pairs(defaultOptions) do
		if(not savedSettings[key]) then
			savedSettings[key] = {}
			for k,v in pairs(optionEntry) do
				savedSettings[key][k] = v
			end
		else
			if(savedSettings[key]["title"] ~= optionEntry["title"]) then
				savedSettings[key]["title"] = optionEntry["title"]

			elseif(savedSettings[key]["type"] ~= optionEntry["type"]) then
				savedSettings[key]["type"] = optionEntry["type"]

			end
		end
	end
end

repSearch.loadSettings = function()
    repSearch.defaultOptionSettings = {

	}

	if(not RepSearch_SavedOptionSettings) then
		RepSearch_SavedOptionSettings = repSearch.defaultOptionSettings
		--MIOG_SavedSettings = {}
	else
		compareSettings(repSearch.defaultOptionSettings, RepSearch_SavedOptionSettings)
	end
	
	
	RepSearch_SavedOptionSettings["datestamp"] = {
		["type"] = "interal",
		["title"] = "Datestamp of last setting save",
		["value"] = date("%d/%m/%y %H:%M:%S")
	}
end