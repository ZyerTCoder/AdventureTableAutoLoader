local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")

function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ZyersAddon" then
        if ZyersTeams == nil then
            ZyersTeams = {}
        end
    end
end
frame:SetScript("OnEvent", frame.OnEvent);
