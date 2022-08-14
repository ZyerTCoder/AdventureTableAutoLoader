local addonName, T = ...

T.configFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)

--[[
	Most useful commands:
	"/atal make" will send all missions it can
	"/atal get missions" will print a list of available missions and how many teams are available for each
	"/atal get followers will print all followers and their statuses
	
	extra use:
	to add a new team to any mission, set up the mission team as if you were to manually send it and then use "/atal add" to save it
	you can remove all teams saved to a mission with "/atal remove <id>", no you cant remove only 1 at a time without manually going to the savedVars

	known issues:
	i dont check for current anima anywhere apart from when automatically sending missions, which doesnt send if you have less than 1k anima
	this hasnt been super tested for non NF covs so have fun
	occasionally it fails to send missions, probably lag or smth, itll bug the mission page until you /reload

]]

local frame = T.configFrame
frame.name = addonName
frame:Hide()

local togglePrioCBs = {}
local upPrioButtons = {}
local downPrioButtons = {}

local function remakeRewardPrio()
	ZyersATALData.rewardsPrio = {order = {}}
	for _, cb in ipairs(togglePrioCBs) do
		if cb:GetChecked() then
			ZyersATALData.rewardsPrio.order[#ZyersATALData.rewardsPrio.order+1] = cb.Text:GetText()
		end
	end
	for _, v in pairs(ZyersATALData.rewardsPrio.order) do
		for _, vv in pairs(T.RewardTypes[v]) do
			ZyersATALData.rewardsPrio[#ZyersATALData.rewardsPrio+1] = vv
		end
	end
end

local function swapUp(v)
	local t = togglePrioCBs[v].Text:GetText()
	togglePrioCBs[v].Text:SetText(togglePrioCBs[v-1].Text:GetText())
	togglePrioCBs[v-1].Text:SetText(t)
	local t2 = togglePrioCBs[v]:GetChecked()
	togglePrioCBs[v]:SetChecked(togglePrioCBs[v-1]:GetChecked())
	togglePrioCBs[v-1]:SetChecked(t2)
	remakeRewardPrio()
end

local function swapDown(v)
	local t = togglePrioCBs[v].Text:GetText()
	togglePrioCBs[v].Text:SetText(togglePrioCBs[v+1].Text:GetText())
	togglePrioCBs[v+1].Text:SetText(t)
	local t2 = togglePrioCBs[v]:GetChecked()
	togglePrioCBs[v]:SetChecked(togglePrioCBs[v+1]:GetChecked())
	togglePrioCBs[v+1]:SetChecked(t2)
	remakeRewardPrio()
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
	description:SetWidth(250)
    description:SetText("Change which rewards and in which order you want to prioritise sending missions for.\nThe left checkbox toggles whether you want this reward or not.")

	if not ZyersATALData.rewardsPrio then
		ZyersATALData.rewardsPrio = T.DefaultRewardPrio
	end

	-- set index 0 for the loop and remove later
	togglePrioCBs = {[0] = verboseSlider}
	upPrioButtons = {[0] = verboseSlider}
	downPrioButtons = {[0] = verboseSlider}

	-- build checkboxes
	local c = 1
	for _,_ in pairs(T.RewardTypes) do
		local k = c
		togglePrioCBs[k] = createCheckbox("Reward Priority Toggle", "Check checkboxes for which missions you want to complete")
		togglePrioCBs[k]:SetPoint("TOPLEFT", togglePrioCBs[k-1], "BOTTOMLEFT", 0, -5)
		togglePrioCBs[k].SetValue = remakeRewardPrio

		upPrioButtons[k] = CreateFrame("Button", addonName .. "ButtonUpPrio" .. k, frame, "UIPanelButtonTemplate")
		upPrioButtons[k].tooltipText = "Move up"
		upPrioButtons[k]:SetPoint("TOPLEFT", togglePrioCBs[k], "TOPRIGHT", 150, 0)
		upPrioButtons[k]:SetScript("OnClick", function() swapUp(k) end)
		upPrioButtons[k]:SetNormalTexture("interface\\buttons\\arrow-up-up")
		upPrioButtons[k]:SetPushedTexture("interface\\buttons\\arrow-up-down")
		upPrioButtons[k]:SetSize(25, 25)

		downPrioButtons[k] = CreateFrame("Button", addonName .. "ButtonUpPrio" .. k, frame, "UIPanelButtonTemplate")
		downPrioButtons[k].tooltipText = "Move down"
		downPrioButtons[k]:SetPoint("TOPLEFT", upPrioButtons[k], "TOPRIGHT", 10, 0)
		downPrioButtons[k]:SetScript("OnClick", function() swapDown(k) end)
		downPrioButtons[k]:SetNormalTexture("interface\\buttons\\arrow-down-up")
		downPrioButtons[k]:SetPushedTexture("interface\\buttons\\arrow-down-down")
		downPrioButtons[k]:SetSize(25, 25)
		c = c+1
	end

	-- fix one-offs
	togglePrioCBs[0] = nil
	upPrioButtons[0] = nil
	downPrioButtons[0] = nil
	togglePrioCBs[1]:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -20)
	upPrioButtons[1]:SetDisabledTexture("interface\\buttons\\arrow-up-disabled")
	upPrioButtons[1]:Disable()
	downPrioButtons[#upPrioButtons]:SetDisabledTexture("interface\\buttons\\arrow-down-disabled")
	downPrioButtons[#upPrioButtons]:Disable()
	-- upPrioButtons[1]:SetPoint("TOPLEFT", togglePrioCBs[1], "TOPRIGHT", 200, 0)
	-- downPrioButtons[1]:SetPoint("TOPLEFT", upPrioButtons[1], "TOPRIGHT", 20, 0)

	function frame:Refresh()
		auto:SetChecked(ZyersATALDataLocal.auto)
		verboseSlider:SetValue(ZyersATALData.verbose)

		local function isInCBs(cbs, val)
			for _, cb in pairs(cbs) do
				if cb.Text:GetText() == val then
					return true
				end
			end
			return false
		end

		for kk, vv in pairs(togglePrioCBs) do
			if ZyersATALData.rewardsPrio.order[kk] then
				vv.Text:SetText(ZyersATALData.rewardsPrio.order[kk])
			else
				for typ, _ in pairs(T.RewardTypes) do
					if not isInCBs(togglePrioCBs, typ) then
						vv.Text:SetText(typ)
						break
					end
				end
			end
		end
		for kk, _ in pairs(togglePrioCBs) do
			togglePrioCBs[kk]:SetChecked(T.isInTable(ZyersATALData.rewardsPrio.order, togglePrioCBs[kk].Text:GetText()))
		end
	end

	frame:Refresh()
	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)
