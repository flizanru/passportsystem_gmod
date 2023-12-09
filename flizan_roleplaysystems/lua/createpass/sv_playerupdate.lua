hook.Add("playerWanted", "SetPlayerWanted", function(criminal, actor, reason)
    if IsValid(criminal) and IsValid(actor) then
        local criminalSteamID = criminal:SteamID()
        local actorSteamID = actor:SteamID()

        local query = policeDb:query("UPDATE flizan_player_info SET wanted = 1 WHERE steamid = '" .. criminalSteamID .. "'")

        query.onSuccess = function()
            criminal:SendLua([[chat.AddText(Color(30, 144, 255), "[Police Department] ", Color(255, 255, 255), "You are now wanted.")]])

            local logQuery = policeDb:query("INSERT INTO flizan_logs_police (name, steamid, name2, steamid2, date, action, reason) VALUES ('" .. actor:Nick() .. "', '" .. actorSteamID .. "', '" .. criminal:Nick() .. "', '" .. criminalSteamID .. "', NOW(), 'wantedplayer', '" .. reason .. "')")

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
        local excriminalSteamID = excriminal:SteamID()
        local actorSteamID = actor:SteamID()

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
    local steamID = ply:SteamID()
    local query = policeDb:query("UPDATE flizan_player_info SET wanted = 0 WHERE steamid = '" .. steamID .. "'")

    query.onSuccess = function()
     --   print("[POLICE SYSTEM] Player " .. ply:Nick() .. " disconnected. Wanted status reset.")
    end

    query.onError = function(_, err)
       print("[POLICE SYSTEM] Error updating wanted status for player " .. ply:Nick() .. ": " .. err)
    end

    query:start()
end)
