local _, T = ...

local addTeam = function(args)
    mid = CovenantMissionFrame.MissionTab.MissionPage.missionInfo.missionID
    -- check if there already is an entry for this mission in the table
    if ZyersATALTeams[mid] == nil then
        ZyersATALTeams[mid] = {}
    end

    local team = {}
    
    local board = CovenantMissionFrame.MissionTab.MissionPage.Board.framesByBoardIndex
    for i=0,4 do
        local ii = board[i].info
        if ii then
            team[i] = {ii.followerID, ii.name}
        end
    end
    -- should check if not duplicate
    -- and should check if its a valid team
    table.insert(ZyersATALTeams[mid], team)
    print("Saved this team to " .. mid)
end

local populateMission = function(mission, team)
    -- Don't question this, GetAvailableMissions apparently is missing this data so I'm adding random filler
    if not mission.encounterIconInfo then
       mission.encounterIconInfo = {
          isRare=false,
          portraitFileDatalD=3583223,
          missionScalar=48,
          isElite=false,
          isRare=false,
          portraitFileDatalD=3583223,
          missionScalar=48,
          isElite=false
       }
    end
    CovenantMissionFrame:OnClickMission(mission)
    local order = {2, 3, 4, 0, 1}
    for _, v in ipairs(order) do
       if team[v] then
          CovenantMissionFrame:GetMissionPage():AddFollower(team[v][1])
       else
          CovenantMissionFrame:GetMissionPage():AddFollower("0xFFFFFFFFFFFFFFFE")
       end
    end
    CovenantMissionFrame.MissionTab.MissionPage.StartMissionButton:Click()
    print("Sent " .. mission.name)
end


local getMissions = function(args)
    local missions = C_Garrison.GetAvailableMissions(123)
    print("there are " .. #missions .. " missions")
    for i = 1,#missions do
        print(missions[i].name .. " " .. missions[i].missionID)
        local fol = missions[i].rewards
        for j = 1, #fol do
            local n = fol[j]
            print(" item:")
            
            for k, v in pairs(n) do
                print("  " .. k .. " " .. v)
            end
        end
    end
    print("got missions")
end

local getAvailableFollowers = function()
    local available = {}
    local followers = C_Garrison.GetFollowers(123)
    for _, follower in ipairs(followers) do
        if follower.status == nil then
            available[#available+1] = {follower.followerID, follower.name}
        end
    end
    return available
end

local isInTable = function(tab, val)
    local set = {}
    for _, l in pairs(tab) do set[l] = true end
    if set[val] then
       return true
    end
    return false
end

local makeTeams = function(args)
    local start = debugprofilestop()
    -- order available missions by interest
    local missionsToDo = {}
    local missions = C_Garrison.GetAvailableMissions(123)
    for _, rewardType in ipairs(T.rewardPrio) do
        for _, mission in ipairs(missions) do
            if not isInTable(missionsToDo, mission) then
                for _, reward in ipairs(mission.rewards) do
                --DevTools_Dump(reward)
                    local k, reTyp = rewardType[1], rewardType[2]
                    if k == "title" then
                        if reward.title == reTyp then
                            print("Prio is " .. mission.name .. " for " .. reTyp)
                            missionsToDo[#missionsToDo +1] = mission
                        end
                    elseif k == "itemID" then
                        if reward.itemID == reTyp then
                            print("Prio is " .. mission.name .. " for " .. GetItemInfo(reTyp))
                            missionsToDo[#missionsToDo +1] = mission
                        end
                    elseif k == "missionIDs" then
                        if isInTable(reTyp, mission.missionID) then
                            print("Prio is " .. mission.name .. " for anima")
                            missionsToDo[#missionsToDo +1] = mission
                        end
                    end
                end
            end
        end
    end
    -- DevTools_Dump(missionsToDo)

    -- check which followers are available and order them as per the prio list
    local _followers = getAvailableFollowers()
    local followers = {}
    for _, prio in ipairs(T.NFFollowerPrio) do
        for _, availFol in ipairs(_followers) do
            if prio[1] == availFol[1] then
                followers[#followers+1] = prio
                break
            end
        end
    end
    
    -- for mission in missionsToDo
        -- for follower in followerPrio
            -- if mission has team with this follower send
    -- print("missionsToDo", #missionsToDo)
    -- print("followers", #followers)
    for _, mission in ipairs(missionsToDo) do
        local missionSent = false
        for k, _f in pairs(followers) do
            if missionSent then break end
            local folID = _f[1]
            -- print("folID", folID)
            if ZyersATALTeams[mission.missionID] then
                for _, team in pairs(ZyersATALTeams[mission.missionID]) do
                    if missionSent then break end
                        for _, member in pairs(team) do
                        -- print(member[1], folID)
                        if member[1] == folID then
                            missionSent = true
                            followers[k] = nil
                            populateMission(mission, team)
                            break
                        end
                    end
                end
            end
        end
    end
    print("Done")
    local finish = debugprofilestop()
    print(finish - start)
end

SLASH_TESTADDON1 = "/zy"
SlashCmdList["TESTADDON"] = function(cmd)
    if not cmd or cmd == "" then
        print("Welcome to Zyer's auto adventure table addon that prolly won't work properly")
    else
        local args = { strsplit(" ", string.lower(cmd)) }
        cmd = args[1]
        if cmd == "add" then
            addTeam(args)
        elseif cmd == "get" then
            getMissions(args)
        elseif cmd == "make" then
            makeTeams(args)
        elseif cmd == "test" then
            DevTools_Dump(T.NFFollowerPrio)
        else
            print("Command not recognised.")
        end
    end
end

-- DevTools_Dump()