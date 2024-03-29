local _, T = ...
-- TODO
-- atal will think the mission fails if theres too high lag <1000ms maybe desynced event orders?
-- add a button on the table gui to make/cmpl ?
-- add button on mission page to save/add team ?

local cmdList = {}
local notAtGarrNPC = true

local function getTableLen(tab)
	local c = 0
	for k, v in pairs(tab) do
		c = c + 1
	end
	return c
end

function T.isInTable(tab, val)
	local set = {}
	for _, l in pairs(tab) do set[l] = true end
	if set[val] then
	   return true
	end
	return false
end

local function addTeam()
	if not C_Garrison.IsAtGarrisonMissionNPC() then
		print("Not at the table.")
		return
	elseif not CovenantMissionFrame.MissionTab.MissionPage.missionInfo then
		print("Open a mission to add to it.")
		return
	end

	if not ZyersATALTeams[T.CurrCov] then
		print("ZyersATALTeams[T.CurrCov] == nil, this is weird")
	end

	local mid = CovenantMissionFrame.MissionTab.MissionPage.missionInfo.missionID
	-- check if there already is an entry for this mission in the table
	if ZyersATALTeams[T.CurrCov][mid] == nil then
		ZyersATALTeams[T.CurrCov][mid] = {}
	end

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
			ZyersATALTeams[T.CurrCov][mid] = {team, any=true}
		else
			print("No companions on this mission, if you want to use this as an open team put in 4 troops.")
		end
		return
	end

	if ZyersATALTeams[T.CurrCov][mid].any then
		print("This mission has an open team already saved.")
		return
	end
	-- check if duplicate
	-- if not getTableLen(ZyersATALTeams[T.CurrCov][mid]) then

	for _, teamIn in pairs(ZyersATALTeams[T.CurrCov][mid]) do
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
	table.insert(ZyersATALTeams[T.CurrCov][mid], team)
	print(string.format("Saved this team to %d, there are %d teams saved to it.", mid, getTableLen(ZyersATALTeams[T.CurrCov][mid])))
end

local function removeAllTeamsFromMissionID(mid)
	if mid then
		ZyersATALTeams[T.CurrCov][tonumber(mid)] = nil
		print(string.format("Removed %s.", mid))
	else
		print("No mission ID provided")
	end
end

local function getTeamString(team)
	local troops = 0
	local companions = {}
	for _, mem in pairs(team) do
		if T.isInTable(T.Covs[T.CurrCov].TroopIDs, mem[1]) then
			troops = troops + 1
		else
			companions[#companions+1] = mem[2]
		end
	end
	return string.format("%s and %d troops", table.concat(companions, ", "), troops)
end

local function populateMission(mission, team, testMode)
	local sucess = true
	local order = {2, 3, 4, 0, 1}
	for _, v in pairs(order) do
		if team[v] then
			local fid = ZyersATALidConv[team[v][1]]
			if not testMode then
				sucess = C_Garrison.AddFollowerToMission(mission.missionID, fid, v)
			end
		end
		if not sucess then break end
	end
	if not sucess then
		print(string.format("|cFFFF0000Failed to add %s to %s. ", getTeamString(team), mission.name))
		return false
	end
	return true
end

local function getNumberOfTeams(mid)
	if not mid then
		return -1, "|cFFFF0000No missionID was given"
	elseif not ZyersATALTeams[T.CurrCov][mid] or #ZyersATALTeams[T.CurrCov][mid] == 0 then
		return 0, "|cFFFF0000has no teams"
	elseif ZyersATALTeams[T.CurrCov][mid].any then
		return 1000, "|cFF00FF00can be done with any team"
	else
		local n = getTableLen(ZyersATALTeams[T.CurrCov][mid])
		if n == 1 then
			return n, "|cFFFFFF00Has 1 team"
		elseif n > 15 then
			return n, string.format("|cFF00FF00has %d teams", n)
		elseif n == 1 then
			return n, string.format("|cFFFFFF00has %d team", n)
		else
			return n, string.format("|cFFFFFF00has %d teams", n)
		end
	end
	return -1000, "|cFFFF0000????"
end

local function getAvailableFollowersSorted()
	local unsortedFollowers = C_Garrison.GetFollowers(123)
	local followers = {}
	for _, prio in pairs(T.Covs[T.CurrCov].FollowerPrio) do
		for _, fol in pairs(unsortedFollowers) do
			if (fol.status == nil) and (prio[1] == fol.garrFollowerID) then
				followers[#followers+1] = prio
				break
			end
		end
	end
	return followers
end

local function getMissionsTodo()
	local missionsToDo = {}
	local missions = C_Garrison.GetAvailableMissions(123)
	for _, rewardType in pairs(ZyersATALData.rewardsPrio) do
		for _, mission in pairs(missions) do
			if not T.isInTable(missionsToDo, mission) and mission.basecost <= ZyersATALData.maxMissionCost then -- TODO add missionCost chest here ZyersATALData.maxMissionCost
				for _, reward in pairs(mission.rewards) do
					local k, reTyp, currID = rewardType[1], rewardType[2], rewardType[3]
					if k == "title" then
						if reward.title == reTyp and (reward.currencyID == currID or reward.currencyID == 0) then
							local _, s = getNumberOfTeams(mission.missionID)
							missionsToDo[#missionsToDo +1] = mission
							if ZyersATALData.verbose >= 2 then
								local currName = C_CurrencyInfo.GetCurrencyLink(currID or 0)
								print(string.format("%s %s for %s %s %s", mission.missionID, mission.name, reTyp, currName or "", s))
							end
						end
					elseif k == "itemID" then
						if reward.itemID == reTyp then
							local _, ilink = GetItemInfo(reTyp)
							if not ilink then
								ilink = tostring(reTyp)
							end
							local _, s = getNumberOfTeams(mission.missionID)
							missionsToDo[#missionsToDo +1] = mission
							if ZyersATALData.verbose >= 2 then
								print(string.format("%s %s for %s %s", mission.missionID, mission.name, ilink, s))
							end
						end
					end
				end
			end
		end
	end
	return missionsToDo
end

local function getAnima()
	local anima = C_CurrencyInfo.GetCurrencyInfo(1813)
	return anima.quantity
end


local function isFollowerGood(followerID)
	-- max level and full hp
	local f = C_Garrison.GetFollowerInfo(ZyersATALidConv[followerID])
	local cs = C_Garrison.GetFollowerAutoCombatStats(ZyersATALidConv[followerID])
	if not f or not cs then return false end
	return f.isMaxLevel and (cs.currentHealth == cs.maxHealth)
end

local function checkTeamAvailable(team, followers)
	for _, member in pairs(team) do
		local flag = false
		for _, fol in pairs(followers) do
			if (member[1] == fol[1] or T.isInTable(T.Covs[T.CurrCov].TroopIDs, member[1])) and isFollowerGood(member[1]) then
				flag = true
			end
		end
		if not flag then return false end
	end
	return true
end

local function makeTeams(testMode)
	local t0 = debugprofilestop()

	-- order available missions by interest
	local missionsToDo = getMissionsTodo()

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

	do -- for the queue space
		-- queue functions
		local queue = {}
		local qTicker
		local queueTick = function() --TODO a bunch of things related to populateMission and stopping the q early
			local i, v = next(queue)
			if not i then print("nothing in q, clear me after testing this works") return end -- stop if queue is empty, this will only happen if the queue is cleared before ticking for every element
			if v[1].basecost + 4 > getAnima() then -- always assume max troop number
				qTicker:Cancel()
				print("|cFFFF0000Abordted sending missions: Not enough anima.")
				return
			end
			if notAtGarrNPC then
				qTicker:Cancel()
				print("|cFFFF0000Aborted sending missions: Left the table")
				return
			end
			if not testMode then
				populateMission(v[1], v[2])
				C_Garrison.StartMission(v[1].missionID)
			end
			queue[i] = nil
			if ZyersATALData.verbose >= 1 then
				print(string.format("Sent on %s.", v[1].name))
			end
		end

		local queueAdd = function(v)
			queue[#queue+1] = v
			if ZyersATALData.verbose >= 2 then
				print(string.format("Added %s to the queue with %s", v[1].name, getTeamString(v[2])))
			end
		end

		-- for mission in missionsToDo
			-- for follower in followerPrio
				-- if mission has team with this follower send
		for _, mission in pairs(missionsToDo) do
			-- print(mission.missionID, mission.name)
			local missionSent = false
			for k, fol in pairs(followers) do
				if missionSent then break end
				if not ZyersATALTeams[T.CurrCov][mission.missionID] then break end
				if ZyersATALTeams[T.CurrCov][mission.missionID].any then
					local team = {}
					local _tmp = ZyersATALTeams[T.CurrCov][mission.missionID][1]
					for i = 0, 4 do
						local v = _tmp[i]
						if not v then
							team[i] = fol
						else
							team[i] = v
						end
					end
					missionSent = true
					followers[k] = nil
					queueAdd({mission, team})
					break
				else
					-- print(mission.missionID, fol[2])
					for _, team in pairs(ZyersATALTeams[T.CurrCov][mission.missionID]) do
						if missionSent then break end
						for _, member in pairs(team) do
							if member[1] == fol[1] then
								-- print(mission.missionID, fol[2], "good")
								-- print("team with", fol[2])
								if checkTeamAvailable(team, followers) then
									-- print("and it is available, added to queue")
									missionSent = true
									--followers[k] = nil
									for _, mem in pairs(team) do
										for j, foll in pairs(followers) do
											if mem[1] == foll[1] then
												followers[j] = nil
											end
										end
									end
									queueAdd({mission, team})
									break
								end
							end
						end
					end
				end
			end
		end
		print("Got", #queue, "missions")
		if #queue > 0 then
			qTicker = C_Timer.NewTicker(0.5, queueTick, #queue)
		end
	end
	if ZyersATALData.verbose >= 3 then
		print(string.format("Took %f ms. ", debugprofilestop() - t0))
	end
	return true
end

local function printSavedTeamsInfo()
	local totalMissions = 0
	local totalTeams = 0
	local totalAnys = 0
	for _, mission in pairs(ZyersATALTeams[T.CurrCov]) do
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

local function fixSavedVars()
	if not ZyersATALData then
		ZyersATALData = {}
	end
	if not ZyersATALDataLocal then
		ZyersATALDataLocal = {}
	end
	if not ZyersATALData.rewardsPrio then
		ZyersATALData.rewardsPrio = T.Defaults.RewardPrio
	end
	local currentCov = C_Covenants.GetActiveCovenantID()
	if ZyersATALTeams == nil then
		ZyersATALTeams = {}
	end
	T.CurrCov = currentCov
	if ZyersATALTeams[T.CurrCov] == nil then
		ZyersATALTeams[T.CurrCov] = {}
	end
	if ZyersATALidConv == nil then
		ZyersATALidConv = {}
	end
	if ZyersATALData.verbose == nil then
		ZyersATALData.verbose = T.Defaults.Verbose
	end
	if ZyersATALData.maxMissionCost == nil then
		ZyersATALData.maxMissionCost = T.Defaults.MaxMissionCost
	end
	local fols = C_Garrison.GetFollowers(123)
	if not fols then return end
	if #fols < #ZyersATALidConv and currentCov == ZyersATALidConv.currCov then return end
	ZyersATALidConv.currCov = currentCov
	for _, f in pairs(C_Garrison.GetFollowers(123)) do
		ZyersATALidConv[f.garrFollowerID] = f.followerID
	end
	for _,f in pairs(C_Garrison.GetAutoTroops(123)) do
		ZyersATALidConv[f.garrFollowerID] = f.followerID
	end
end

local function setSavedVar(var, value)
	if not var then
		print("Pick a variable to change: auto/verbose/maxMissionCost")
		return
	end
	if var == "a" or var == "auto" then
		if value then
			ZyersATALDataLocal.auto = value
			print("ATAL: Auto is " .. value)
		elseif ZyersATALDataLocal.auto then
			ZyersATALDataLocal.auto = nil
			print("ATAL: Auto is off.")
		else
			ZyersATALDataLocal.auto = true
			print("ATAL: Auto is on.")
		end
	elseif var == "v" or var == "verbose" then
		if value then
			ZyersATALData.verbose = tonumber(value)
		end
		print(string.format("verbose = %d.", ZyersATALData.verbose))
	elseif var == "maxMissionCost" then
		if value then
			ZyersATALData.maxMissionCost = tonumber(value)
		end
		print(string.format("maxMissionCost = %d.", ZyersATALData.maxMissionCost))
	else
		print("Var not recognised.")
	end
	if T.configFrame:IsVisible() then
		T.configFrame:Refresh()
	end
end

local function printCompleteMissionResponse(success, t)
	local mid = t[1]
	local mission = C_Garrison.GetBasicMissionInfo(mid)
	if success then
		if ZyersATALData.verbose >= 1 then
			print(string.format("Completed %d %s", mid, mission and mission.name or ""))
		end
	else
		print(string.format("|cFFFF0000Failed %d %s and had these followers, go delete manually, COMPLETE_RESPONSE was saved in the general saved vars", mid, mission and mission.name or ""))
		for k, v in pairs(t[5]) do
			local f = C_Garrison.GetFollowerInfo(v.followerID)
			if f then print(f.name) end
		end
		ZyersATALData.lastFail = t
	end
end

local function completeAllMissions(xpac)
	if type(xpac) == "string" then
		xpac = tonumber(xpac)
	end
	if not xpac then return end
	for _, m in pairs(C_Garrison.GetCompleteMissions(xpac)) do
		local i = m.missionID
		C_Garrison.MarkMissionComplete(i)
		C_Garrison.MissionBonusRoll(i)
	end
end

local function checkFollowersAvailability()
	local fols = C_Garrison.GetFollowers(123)
	for _, f in pairs(fols) do
		local fol = C_Garrison.GetFollowerInfo(f.followerID)
		local cs = C_Garrison.GetFollowerAutoCombatStats(f.followerID)

		if fol and cs then
			local _good = isFollowerGood(f.garrFollowerID)
			local good
			if _good then good = "|cFF00FF00Good|r"
			else good = "|cFFFF0000Bad|r"
			end

			local _status = fol.status
			local status
			if not _status then status = "|cFF00FF00Free|r"
			else status = "|cFFFF0000" .. _status .. "|r"
			end

			local _isMaxLevel = fol.isMaxLevel
			local isMaxLevel
			if _isMaxLevel then isMaxLevel = "|cFF00FF00isMaxLevel|r"
			else isMaxLevel = "|cFFFF0000isn'tMaxLevel|r"
			end

			print(fol.name, "|", good, "|", status, "|", isMaxLevel, "|", cs.currentHealth, "/", cs.maxHealth, "hp")
		end
	end
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GARRISON_MISSION_NPC_OPENED")
frame:RegisterEvent("GARRISON_MISSION_NPC_CLOSED")
frame:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE")
frame:RegisterEvent("GARRISON_MISSION_BONUS_ROLL_COMPLETE")
local completedMissions = {}
function frame:OnEvent(event, ...)
	local arg = {...}
	if event == "GARRISON_MISSION_NPC_OPENED" then
		if notAtGarrNPC then
			fixSavedVars()
		end
		if ZyersATALDataLocal.auto and notAtGarrNPC then
			notAtGarrNPC = false
			if arg[1] == 123 then -- SL command table
				completeAllMissions(123)
				C_Timer.After(1, makeTeams)
			elseif arg[1] == 1 then -- WoD command table
				completeAllMissions(1)
			end
		end
	elseif event == "GARRISON_MISSION_NPC_CLOSED" then
		notAtGarrNPC = true
	elseif event == "GARRISON_MISSION_COMPLETE_RESPONSE" then
		completedMissions[arg[1]] = arg
	elseif event == "GARRISON_MISSION_BONUS_ROLL_COMPLETE" then
		printCompleteMissionResponse(arg[2], completedMissions[arg[1]])
		completedMissions[arg[1]] = nil
	end
end
frame:SetScript("OnEvent", frame.OnEvent);

local function infoGetter(what)
	if what == "missions" or what == "m" then
		local _v = ZyersATALData.verbose
		ZyersATALData.verbose = max(_v, 2)
		local missions = getMissionsTodo()
		ZyersATALData.verbose = _v

		if #missions == 0 then
			print("No missions of interest found.")
		end
	elseif what == "teams" or what == "t" then
		printSavedTeamsInfo()
	elseif what == "followers" or what == "f" then
		checkFollowersAvailability()
	elseif what == "rewards" or what == "r" then
		if #ZyersATALData.rewardsPrio.order == 0 then
			print("You don't have any rewards chosen.")
			return
		end
		local p
		for k, v in pairs(ZyersATALData.rewardsPrio.order) do
			if p then
				p = p .. ", " .. v
			else
				p = v
			end
		end
		print("Reward priority is: " .. p)
	else
		print("getter options: missions/teams/followers/rewards")
	end
end

-- extra cmds and shortcuts
do
	local helpMsg = [[Welcome to Zyer's Adventure Table Auto Loader:
'/atal make' to send missions
'/atal remove <id>' to remove every team from a mission
'/atal change <var>' to change setting
'/atal get <option>' for info on missions/teams/followers/rewards
'/atal options' to open the options menu
'/atal complete 123' to auto set all missions as completed]]
	cmdList.make = makeTeams
		cmdList.mk = cmdList.make
	cmdList.add = addTeam
	cmdList.remove = removeAllTeamsFromMissionID
		cmdList.rm = cmdList.remove
	cmdList.set = setSavedVar
		cmdList.s = cmdList.set
	cmdList.get = infoGetter
		cmdList.g = cmdList.get
	cmdList.help = function() print(helpMsg) end
		cmdList.h = cmdList.help
	cmdList.complete = completeAllMissions
		cmdList.cmpl = cmdList.complete
end

SLASH_ATAL1 = "/atal"
SLASH_ATAL2 = "/zy"
SlashCmdList["ATAL"] = function(cmd)
	fixSavedVars()
	local args = { strsplit(" ", cmd) }
	cmd = args[1]
	if cmdList[cmd] then
		cmdList[cmd](args[2], args[3])
	elseif not T.configFrame:IsVisible() then
		InterfaceOptionsFrame_OpenToCategory(T.configFrame)
		InterfaceOptionsFrame_OpenToCategory(T.configFrame)
	end
end