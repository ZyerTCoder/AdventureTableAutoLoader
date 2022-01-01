local this, T = ...
-- TODO
-- add tons of teams
-- for mid 2319 save a team with watcher vesperbloom and yiralya
-- after successfully populating a mission, make sure it disables other followers so they cant be used in subsequent missions
-- see if you can take over completeting the missions too 
-- then attach the whole thing to the GARRISON_MISSION_NPC_OPENED event :winkwinkwink:

local getTableLen = function(tab)
    local c = 0
    for k, v in pairs(tab) do
        c = c + 1
    end
    return c
end

local isInTable = function(tab, val)
    local set = {}
    for _, l in pairs(tab) do set[l] = true end
    if set[val] then
       return true
    end
    return false
end

local addTeam = function(args)
    if not C_Garrison.IsAtGarrisonMissionNPC() then
        print("Not at the table.")
        return
    elseif not CovenantMissionFrame.MissionTab.MissionPage.missionInfo then
        print("Open a mission to add to it.")
        return
    end

    if not ZyersATALTeams then
        print("Saved far == nil, this is weird")
    end

    local mid = CovenantMissionFrame.MissionTab.MissionPage.missionInfo.missionID
    -- check if there already is an entry for this mission in the table
    if ZyersATALTeams[mid] == nil then
        ZyersATALTeams[mid] = {}
    end
    --/run local board = CovenantMissionFrame.MissionTab.MissionPage.Board.framesByBoardIndex; for i=0,4 do local ii=board[i].info;if ii then print(ii.isAutoTroop, ii.garrFollowerID, ii.name) end end
    local team = {}
    local board = CovenantMissionFrame.MissionTab.MissionPage.Board.framesByBoardIndex
    local noCompanions = true
    for i=0,4 do
        local ii = board[i].info
        if ii then
            if not ii.isAutoTroop then
                noCompanions = false
            end
            team[i] = {ii.garrFollowerID, ii.name}
        end
    end

    -- DevTools_Dump(team)
    -- print(getTableLen(team))
    if noCompanions then
        if getTableLen(team) == 4 then
            print("No companions on this mission, adding as an open team.")
            ZyersATALTeams[mid] = {team, any=true}
        else
            print("No companions on this mission, if you want to use this as an open team put in 4 troops.")
        end
        return
    end

    if ZyersATALTeams[mid].any then
        print("This mission has an open team already saved.")
        return
    end
    -- check if duplicate
    -- if not getTableLen(ZyersATALTeams[mid]) then

    for _, teamIn in ipairs(ZyersATALTeams[mid]) do
        local isDupe = true
        for k, member in pairs(teamIn) do
            local newMember = team[k] or {}
            if not (member[1] == newMember[1]) then
                isDupe = false
            end
        end
        if isDupe then
            print("This mission is already saved.")
            return
        end
    end
    -- and should check if its a valid team
    table.insert(ZyersATALTeams[mid], team)
    print(string.format("Saved this team to %d, there are %d teams saved to it.", mid, getTableLen(ZyersATALTeams[mid])))
end

local removeAllTeamsFromMissionID = function(mid)
    ZyersATALTeams[tonumber(mid)] = nil
    print("Removed %s.", mid)
end

local getTeamString = function(team)
    local troops = 0
    local companions = {}
    for _, mem in pairs(team) do
        if isInTable(T.NightFae.TroopIDs, mem[1]) then
            troops = troops + 1
        else
            companions[#companions+1] = mem[2]
        end
    end
    return string.format("%s and %d troops", table.concat(companions, ", "), troops)
end

local populateMission = function(mission, team, testMode)
    local sucess = true
    local order = {2, 3, 4, 0, 1}
    for _, v in ipairs(order) do
        if team[v] then
            local fid = ZyersATALidConv[team[v][1]]
            if not testMode then
                sucess = C_Garrison.AddFollowerToMission(mission.missionID, fid, v)
            end
        end
        if not sucess then break end
    end
    if not sucess then
        print(string.format("Failed to add %s to %s. ", getTeamString(team), mission.name))
        return false
    end
    return true
end

local getMissions = function()
    local missions = C_Garrison.GetAvailableMissions(123)
    print(string.format("There are %d missions.", #missions))
    for i = 1,#missions do
        print(string.format("%s %d", missions[i].name, missions[i].missionID))
        local fol = missions[i].rewards
        for j = 1, #fol do
            local n = fol[j]
            print(" item:")
            for k, v in pairs(n) do
                print(k, v)
            end
        end
    end
    print("Got missions.")
end

local getNumberOfTeamsString = function(mid)
    if not mid then
        return "|cFFFF0000No missionID was given"
    elseif not ZyersATALTeams[mid] or #ZyersATALTeams[mid] == 0 then
        return "|cFFFF0000Has no teams"
    elseif ZyersATALTeams[mid].any then
        return "|cFF00FF00Can be done with any team"
    else
        local n = getTableLen(ZyersATALTeams[mid])
        if n == 1 then
            return "|cFFFFFF00Has 1 team"
        elseif n > 20 then
            return string.format("|cFF00FF00Has %d teams", n)
        elseif n == 1 then
            return string.format("|cFFFFFF00Has %d team", n)
        else
            return string.format("|cFFFFFF00Has %d teams", n)
        end
    end
    return "|cFFFF0000????"
end

local getAvailableFollowersSorted = function()
    local unsortedFollowers = C_Garrison.GetFollowers(123)
    local followers = {}
    for _, prio in ipairs(T.NightFae.FollowerPrio) do
        for _, fol in ipairs(unsortedFollowers) do
            if (fol.status == nil) and (prio[1] == fol.garrFollowerID) then
                followers[#followers+1] = prio
                break
            end
        end
    end
    return followers
end

local makeTeams = function(testMode)
    -- order available missions by interest
    local missionsToDo = {}
    local missions = C_Garrison.GetAvailableMissions(123)
    for _, rewardType in ipairs(T.RewardPrio) do
        for _, mission in ipairs(missions) do
            if not isInTable(missionsToDo, mission) then
                for _, reward in ipairs(mission.rewards) do
                --DevTools_Dump(reward)
                    local k, reTyp = rewardType[1], rewardType[2]
                    if k == "title" then
                        if reward.title == reTyp then
                            print(string.format("%s %s for %s.  %s", mission.missionID, mission.name, reTyp, getNumberOfTeamsString(mission.missionID)))
                            missionsToDo[#missionsToDo +1] = mission
                        end
                    elseif k == "itemID" then
                        if reward.itemID == reTyp then
                            local _, ilink= GetItemInfo(reTyp)
                            print(string.format("%s %s for %s.  %s", mission.missionID, mission.name, ilink, getNumberOfTeamsString(mission.missionID)))
                            missionsToDo[#missionsToDo +1] = mission
                        end
                    end
                end
            end
        end
    end

    -- check which followers are available and order them as per the prio list
    local followers = getAvailableFollowersSorted()

    -- DevTools_Dump(missionsToDo)
    if getTableLen(missionsToDo) == 0 then
        print("No missions of interest found.")
        return false
    end
    -- checking if player is at table
    if not C_Garrison.IsAtGarrisonMissionNPC() then
        print(string.format("%d followers free, go to the mission table to send missions.", #followers))
        return false
    end

    if getTableLen(followers) == 0 then
        print("No followers available")
        return false
    end

    do
        -- queue functions
        local queue = {}
        local queueTick = function()
            local i, v = next(queue)
            if not testMode then
                C_Garrison.StartMission(v[1].missionID)
            end
            print(string.format("Sent %s to %s.", getTeamString(v[2]), v[1].name))
            queue[i] = nil
        end

        local queueAdd = function(v)
            print(string.format("Added %s to the queue with %s", v[1].name, getTeamString(v[2])))
            queue[#queue+1] = v
        end

        -- for mission in missionsToDo
            -- for follower in followerPrio
                -- if mission has team with this follower send
        for _, mission in ipairs(missionsToDo) do
            local missionSent = false
            for k, fol in pairs(followers) do
                if missionSent then break end
                if ZyersATALTeams[mission.missionID] then
                    if ZyersATALTeams[mission.missionID].any then
                        local team = {}
                        local _tmp = ZyersATALTeams[mission.missionID][1]
                        for i = 0, 4 do
                            local v = _tmp[i]
                            if not v then
                                team[i] = fol
                            else
                                team[i] = v
                            end
                        end
                        if populateMission(mission, team, testMode) then
                            missionSent = true
                            followers[k] = nil
                            queueAdd({mission, team})
                            break
                        end
                    else
                        for _, team in pairs(ZyersATALTeams[mission.missionID]) do
                            if missionSent then break end
                            for _, member in pairs(team) do
                                if member[1] == fol[1] then
                                    if populateMission(mission, team, testMode) then
                                        missionSent = true
                                        followers[k] = nil
                                        queueAdd({mission, team})
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        C_Timer.NewTicker(0.5, queueTick, #queue)
    end
    return true
end

local getSavedTeamsInfo = function()
    local totalMissions = 0
    local totalTeams = 0
    local totalAnys = 0
    for _, mission in pairs(ZyersATALTeams) do
        totalMissions = totalMissions + 1
        if mission.any then
            totalAnys = totalAnys + 1
        else
            totalTeams = totalTeams + #mission
        end
    end
    print(string.format("There are teams for %d missions.", totalMissions))
    print(string.format("%d of these can be done with any companion.", totalAnys))
    print(string.format("%d teams total.", totalTeams))
end

local fixSavedVars = function()
    if ZyersATALTeams == nil then
        ZyersATALTeams = {}
    end
    if ZyersATALidConv == nil then
        ZyersATALidConv = {}
    end
    local fols = C_Garrison.GetFollowers(123)
    if #fols > #ZyersATALidConv then
        for _, f in ipairs(C_Garrison.GetFollowers(123)) do
            ZyersATALidConv[f.garrFollowerID] = f.followerID
        end
        for _,f in ipairs(C_Garrison.GetAutoTroops(123)) do
            ZyersATALidConv[f.garrFollowerID] = f.followerID
        end
    end
end

local toggleAuto = function()
    if ZyersATALAuto then
        ZyersATALAuto = nil
        print("Auto is off.")
    else
        ZyersATALAuto = true
        print("Auto is on.")
    end
end

local printCompleteMissionResponse = function(success, ...)
    local mid = arg[1]
    local mission = C_Garrison.GetBasicMissionInfo(mid)
    if success then
        print(string.format("Completed %d %s", mid, mission.name))
    else
        print(string.format("Failed %d %s and had these followers, go check manually", mid, mission.name))
        DevTools_Dump(arg[4])
    end
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GARRISON_MISSION_NPC_OPENED")
frame:RegisterEvent("GARRISON_MISSION_NPC_CLOSED")
frame:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
frame:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
local npcFlag = true
local completedMissions = {}
function frame:OnEvent(event, ...)
    print("reacting to" , event, ...)
    arg = {...}
    if event == "ADDON_LOADED" and arg[1] == "AdventureTableAutoLoader" then
        fixSavedVars()
    elseif event == "GARRISON_MISSION_NPC_OPENED" then
        if arg[1] == 123 then
            print("in open")
            if ZyersATALAuto and npcFlag then
                npcFlag = nil
                local t0 = debugprofilestop()
                for _, m in pairs(C_Garrison.GetCompleteMissions(123)) do 
                    local i = m.missionID
                    C_Garrison.MarkMissionComplete(i)
                    C_Garrison.MissionBonusRoll(i)
                end 
                print("running make")
                makeTeams("test")
                print(string.format("Done, took %f ms.", debugprofilestop() - t0))
            end
        end
    elseif event == "GARRISON_MISSION_NPC_CLOSED" then
        print("in close")
        npcFlag = true
    elseif event == "GARRISON_MISSION_COMPLETE_RESPONSE" then
        completedMissions[arg[1]] = arg
    elseif event == "GARRISON_MISSION_BONUS_ROLL_COMPLETE" then
        printCompleteMissionResponse(arg    [2], completedMissions[arg[1]])
        completedMissions[arg[1]] = nil
    end
end
frame:SetScript("OnEvent", frame.OnEvent);

-- C_Garrison.CloseMissionNPC

SLASH_ATAL1 = "/atal"
SLASH_ATAL2 = "/zyer"
SLASH_ATAL3 = "/zy"
SlashCmdList["ATAL"] = function(cmd)
    local args = { strsplit(" ", string.lower(cmd)) }
    cmd = args[1]
    if cmd == "mk" or cmd == "make" then
        local t0 = debugprofilestop()
        makeTeams(args[2])
        print(string.format("Done, took %f ms.", debugprofilestop() - t0))
    elseif cmd == "add" then
        addTeam()
    elseif cmd == "rm" or cmd == "remove" then
        removeAllTeamsFromMissionID(args[2])
    elseif cmd == "ta" or cmd == "toggleauto" then
        toggleAuto()
    elseif cmd == "g" or cmd == "get" then
        getSavedTeamsInfo()
        -- getMissions()
    elseif cmd == "test" then
        local t = getAvailableFollowersSorted()
        print(#t)
    else
        print([[Welcome to Zyer's Adventure Table Auto Loader:
'/atal make' to send missions
'/atal add' to add a new team
'/atal remove <id>' to remove every team from a mission
'/atal toggleauto' to run as soon as you interact with the mission table]])
    end
end

