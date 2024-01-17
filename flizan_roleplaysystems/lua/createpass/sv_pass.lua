local function setupPassportCommand(getMessage)
    hook.Add("PlayerSay", "ShowPassportCommand", function(ply, text, team)
        local text = string.lower(text)

        if text == "/pass" then
            local steamID = ply:SteamID()
            local query = policeDb:query("SELECT unique_id FROM flizan_player_info WHERE steamid = '" .. steamID .. "'")

            query.onSuccess = function(_, result)
                local uniqueID = result[1] and result[1].unique_id or getMessage("unknownID")
                DarkRP.talkToRange(ply, getMessage("passportShown", {player = ply:Nick(), id = uniqueID}), "", 5)
            end

            query.onError = function(_, err)
                print(getMessage("dbQueryError", {error = err}))
            end

            query:start()

            return ""
        end
    end)
end

return setupPassportCommand