local getAvailableFollowers = function()
    local available = {}
    local followers = C_Garrison.GetFollowers(123)
    for _, follower in pairs(followers) do
        available[#available+1] = {follower.name, follower.followerID}
    end
    return available
end

local _, stuff = ...

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")

function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ZyersAddon" then
        ZyersTmp = {getAvailableFollowers()}
    end
end
frame:SetScript("OnEvent", frame.OnEvent);
