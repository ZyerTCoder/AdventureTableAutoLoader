local addonName, T = ...

T.configFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)

local frame = T.configFrame
frame.name = addonName
frame:Hide()

local rewardPrioCBs = {}
local togglePrioCBs = {}
local swapTemp

local function remakeRewardPrio()
	ZyersATALData.rewardsPrio = {order = {}}
	for k, cb in ipairs(togglePrioCBs) do
		if cb:GetChecked() then
			ZyersATALData.rewardsPrio.order[#ZyersATALData.rewardsPrio.order+1] = cb.Text:GetText()
		end
	end
	for k, v in pairs(ZyersATALData.rewardsPrio.order) do
		-- make r = v without spaces
		local r = string.gsub(v, "%s+", "")
		for _, vv in pairs(T.RewardTypes.groups[r]) do
			ZyersATALData.rewardsPrio[#ZyersATALData.rewardsPrio+1] = vv
		end
	end
end

local function swapOrder(reward)
	if not swapTemp then
		for k, cb in ipairs(rewardPrioCBs) do
			if cb.Text == reward then
				swapTemp = k
				return
			end
		end
		return
	end
	for k, cb in ipairs(rewardPrioCBs) do
		if cb.Text == reward then
			rewardPrioCBs[k].Text:SetText(rewardPrioCBs[swapTemp].Text) -- check right
			rewardPrioCBs[swapTemp].Text:SetText(cb.Text) -- check right
			break
		end
	end
	-- remakeRewardPrio()
end


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
	auto:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 10, -10)
	auto.SetValue = function(_, value)
		ZyersATALDataLocal.auto = (value == "1")
	end

	local verboseSlider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
	do
		verboseSlider:SetPoint("TOPLEFT", auto, "BOTTOMLEFT", 0, -20)
		verboseSlider:SetMinMaxValues(0, 3)
		verboseSlider:SetValueStep(1)
		verboseSlider.Text:SetText("Debug level")
		verboseSlider.Low:SetText("0")
		verboseSlider.High:SetText("3")
		verboseSlider.tooltipText = "Change how much info the addon prints out:"
		verboseSlider.tooltipRequirement = [[3: debug info 
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
	end

	-- local btName = "Set Reward Priority"
	-- local setRewardPrioButton = CreateFrame("Button", addonName .. "Button" .. btName, frame, "UIPanelButtonTemplate")
	-- setRewardPrioButton.tooltipText = btName
	-- setRewardPrioButton.tooltipRequirement = "Save the selected reward priority"
	-- setRewardPrioButton:SetPoint("TOPLEFT", verboseSlider, "BOTTOMLEFT", 0, -40)
	-- setRewardPrioButton:SetText(btName)
	-- setRewardPrioButton:SetWidth(setRewardPrioButton:GetTextWidth() * 1.2)
	-- setRewardPrioButton.SetValue = remakeRewardPrio

	local description = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    description:SetPoint("TOPLEFT", verboseSlider, "BOTTOMLEFT", 0, -30)
    -- description:SetPoint("RIGHT", frame, -32, 0)
    --description:SetNonSpaceWrap(true)
    description:SetJustifyH("LEFT")
    description:SetJustifyV("TOP")
	description:SetWidth(400)
    description:SetText("Change which rewards and in which order you want to prioritise sending missions for.\nThe left checkbox toggles whether you want this reward or not.")

	if not ZyersATALData.rewardsPrio then
		ZyersATALData.rewardsPrio = T.DefaultRewardPrio
	end

	-- set index 0 for the loop and remove later
	rewardPrioCBs = {[0] = verboseSlider}
	togglePrioCBs = {[0] = verboseSlider}

	-- build checkboxes
	for k, v in ipairs(T.RewardTypes.titles) do
		-- rewardPrioCBs[k] = createCheckbox("Reward Priority Reorder", "Click on two checkboxes to swap their order")
		-- rewardPrioCBs[k]:SetPoint("TOPLEFT", rewardPrioCBs[k-1], "BOTTOMLEFT", 0, -10)
		-- rewardPrioCBs[k].Text:SetText(v.v)
		-- rewardPrioCBs[k].SetValue = swapOrder(_, rewardPrioCBs[k].Text) -- possible error, make sure its passing the current cb text value
		togglePrioCBs[k] = createCheckbox("Reward Priority Toggle", "Check checkboxes for which missions you want to complete")
		togglePrioCBs[k]:SetPoint("TOPLEFT", togglePrioCBs[k-1], "BOTTOMLEFT", 0, -5)
		togglePrioCBs[k].Text:SetText(v)
		togglePrioCBs[k].SetValue = remakeRewardPrio
	end

	-- fix offset
	rewardPrioCBs[0] = nil
	togglePrioCBs[0] = nil
	togglePrioCBs[1]:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -20)
	-- rewardPrioCBs[1]:SetPoint("TOPLEFT", togglePrioCBs[1], "TOPRIGHT", 3, 0)

	function frame:Refresh()
		auto:SetChecked(ZyersATALDataLocal.auto)
		verboseSlider:SetValue(ZyersATALData.verbose)
		for k, v in pairs(togglePrioCBs) do
			togglePrioCBs[k]:SetChecked(T.isInTable(ZyersATALData.rewardsPrio.order, togglePrioCBs[k].Text:GetText()))
			-- v:SetChecked(nil)
		end
	end

	frame:Refresh()
	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)
