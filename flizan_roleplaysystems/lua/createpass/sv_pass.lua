hook.Add("PlayerSay", "ShowPassportCommand", function(ply, text, team)
    local text = string.lower(text)

    if text == "/pass" then
        local steamID = ply:SteamID()
        local query = policeDb:query("SELECT unique_id FROM flizan_player_info WHERE steamid = '" .. steamID .. "'")

        query.onSuccess = function(_, result)
            local uniqueID = result[1] and result[1].unique_id or "Unknown"
            DarkRP.talkToRange(ply, "Player " .. ply:Nick() .. " showed passport (ID: " .. uniqueID .. ")", "", 5)
        end

        query.onError = function(_, err)
            print("[POLICE SYSTEM] Error querying data from the database: " .. err)
        end

        query:start()

        return ""
    end
end)
