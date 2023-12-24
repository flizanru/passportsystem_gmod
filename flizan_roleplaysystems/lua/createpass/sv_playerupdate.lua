hook.Add("CanChangeRPName", "UpdatePlayerNicknameInDB", function(ply, newName)
    if IsValid(ply) then
        local steamID = policeDb:escape(ply:SteamID())

        local function updateNickname()
            local escapedName = policeDb:escape(newName)
            local query = policeDb:query("UPDATE flizan_player_info SET nickname = '" .. escapedName .. "' WHERE steamid = '" .. steamID .. "'")

            query.onSuccess = function()
                print("[POLICE SYSTEM] Nickname updated for player " .. ply:Nick())
            end

            query.onError = function(_, err)
                print("[POLICE SYSTEM] Error updating nickname for player " .. ply:Nick() .. ": " .. err)
            end

            query:start()
        end

        if ply:Nick() == newName then
            updateNickname()
        else
            timer.Simple(1, function()
                if IsValid(ply) and ply:Nick() == newName then
                    updateNickname()
                end
            end)
        end
    end
end)

hook.Add("playerWanted", "SetPlayerWanted", function(criminal, actor, reason)
    if IsValid(criminal) and IsValid(actor) then
        local criminalSteamID = policeDb:escape(criminal:SteamID())
        local actorSteamID = policeDb:escape(actor:SteamID())
        local escapedActorName = policeDb:escape(actor:Nick())
        local escapedCriminalName = policeDb:escape(criminal:Nick())
        local escapedReason = policeDb:escape(reason)

        local query = policeDb:query("UPDATE flizan_player_info SET wanted = 1 WHERE steamid = '" .. criminalSteamID .. "'")

        query.onSuccess = function()
            criminal:SendLua([[chat.AddText(Color(30, 144, 255), "[Police Department] ", Color(255, 255, 255), "You are now wanted.")]])

            local logQuery = policeDb:query("INSERT INTO flizan_logs_police (name, steamid, name2, steamid2, date, action, reason) VALUES ('" .. escapedActorName .. "', '" .. actorSteamID .. "', '" .. escapedCriminalName .. "', '" .. criminalSteamID .. "', NOW(), 'wantedplayer', '" .. escapedReason .. "')")

            logQuery.onError = function(_, err)
                print("[POLICE SYSTEM] Error writing log: " .. err)
            end

            logQuery:start()
        end

        query.onError = function(_, err)
            print("[POLICE SYSTEM] Error declaring player " .. actor:Nick() .. " wanted: " .. err)
        end

        query:start()
    end
end)

hook.Add("playerUnWanted", "UnSetPlayerWanted", function(excriminal, actor)
    if IsValid(excriminal) and IsValid(actor) then
        local excriminalSteamID = policeDb:escape(excriminal:SteamID())
        local actorSteamID = policeDb:escape(actor:SteamID())

        local query = policeDb:query("UPDATE flizan_player_info SET wanted = 0 WHERE steamid = '" .. excriminalSteamID .. "'")

        query.onSuccess = function()
            excriminal:SendLua([[chat.AddText(Color(30, 144, 255), "[Police Department] ", Color(255, 255, 255), "You are no longer wanted.")]])

            local logQuery = policeDb:query("INSERT INTO flizan_logs_police (name, steamid, name2, steamid2, date, action) VALUES ('" .. actor:Nick() .. "', '" .. actorSteamID .. "', '" .. excriminal:Nick() .. "', '" .. excriminalSteamID .. "', NOW(), 'unwantedplayer')")

            logQuery.onError = function(_, err)
                print("[POLICE SYSTEM] Error writing log: " .. err)
            end

            logQuery:start()
        end

        query.onError = function(_, err)
            print("[POLICE SYSTEM] Error removing player " .. actor:Nick() .. " from wanted list: " .. err)
        end

        query:start()
    end
end)


hook.Add("PlayerDisconnected", "ClearWantedOnDisconnect", function(ply)
    local steamID = policeDb:escape(ply:SteamID())
    local query = policeDb:query("UPDATE flizan_player_info SET wanted = 0 WHERE steamid = '" .. steamID .. "'")

    query.onSuccess = function()
        -- print("[POLICE SYSTEM] Player " .. ply:Nick() .. " disconnected. Wanted status reset.")
    end

    query.onError = function(_, err)
        print("[POLICE SYSTEM] Error updating wanted status for player " .. ply:Nick() .. ": " .. err)
    end

    query:start()
end)

hook.Add("ShutDown", "ResetAllWantedStatuses", function()
    local query = policeDb:query("UPDATE flizan_player_info SET wanted = 0 WHERE wanted = 1")

    query.onSuccess = function()
        print("[POLICE SYSTEM] All wanted statuses reset on shutdown.")
    end

    query.onError = function(_, err)
        print("[POLICE SYSTEM] Error resetting wanted statuses on shutdown: " .. err)
    end

    query:start()
end)
