local addonName, T = ...

T.configFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)

local frame = T.configFrame
frame.name = addonName
frame:Hide()


frame:SetScript("OnShow", function(frame)
	local function createCheckbox(name, tooltip)
		local cb = CreateFrame("CheckButton", addonName .. "Checkbox" .. name, frame, "InterfaceOptionsCheckButtonTemplate")
		cb.Text:SetText(name)
		cb.tooltipText = name
		cb.tooltipRequirement = tooltip
		return cb
	end

	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(addonName)

	local auto = createCheckbox("Auto", "Toggle automatically completing quests and sending missions upon opening the mission table.")
	auto:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
	auto.SetValue = function(_, value)
		ZyersATALData.auto = (value == "1")
	end

	local verboseSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
	verboseSlider:SetPoint("TOPLEFT", auto, "BOTTOMLEFT", 0, -15)
	verboseSlider:SetMinMaxValues(0, 3)
	verboseSlider:SetValueStep(1)
	verboseSlider.Text:SetText("Debug level")
	verboseSlider.Low:SetText("0")
	verboseSlider.High:SetText("3")
	verboseSlider.tooltipText = "Change how much info the addon prints out:"
	verboseSlider.tooltipRequirement = [[
3: debug info 
  - how long it took to calculate missions
2: extra mission info 
  - which missions of interest are available when you open the command table
  - team added to queue feedback
1: basic responses/info DEFAULT
  - missions sent feedback
  - missions completed
0: everything else: errors and command responses]]
	verboseSlider:SetScript("OnValueChanged", function(_, value)
		ZyersATALData.verbose = value
		verboseSlider:SetValue(ZyersATALData.verbose)
	end)

	function frame:Refresh()
		auto:SetChecked(ZyersATALData.auto)
		verboseSlider:SetValue(ZyersATALData.verbose)
	end

	frame:Refresh()
	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)