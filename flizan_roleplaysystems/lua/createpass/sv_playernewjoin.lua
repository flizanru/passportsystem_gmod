local function recordPlayerInfo(getMessage, ply, newID)
    local uniqueID = string.format("%04d", newID) 
    local nickname = policeDb:escape(ply:Nick())
    local steamID = policeDb:escape(ply:SteamID())
    local steamID64 = policeDb:escape(ply:SteamID64())
    local joinDate = os.date("%Y-%m-%d %H:%M:%S")
    local wanted = 0
    local gunLicense = 0

    local checkQuery = policeDb:prepare("SELECT unique_id FROM flizan_player_info WHERE steamid = ?")
    checkQuery:setString(1, steamID)

    checkQuery.onSuccess = function(_, result)
        if not result[1] then
            local insertQuery = policeDb:prepare("INSERT INTO flizan_player_info (unique_id, nickname, steamid, steamid64, join_date, wanted, gun_license) VALUES (?, ?, ?, ?, ?, ?, ?)")
            insertQuery:setString(1, uniqueID)
            insertQuery:setString(2, nickname)
            insertQuery:setString(3, steamID)
            insertQuery:setString(4, steamID64)
            insertQuery:setString(5, joinDate)
            insertQuery:setNumber(6, wanted)
            insertQuery:setNumber(7, gunLicense)

            insertQuery.onSuccess = function()
                ply:SendLua([[chat.AddText(Color(30, 144, 255), "]] .. getMessage("playerRegistered") .. [[")]])
            end

            insertQuery.onError = function(_, err)
                print(getMessage("dbInsertError", {error = err}))
                ply:SendLua([[chat.AddText(Color(255, 0, 0), "]] .. getMessage("insertError") .. [[")]])
            end

            insertQuery:start()
        else
            ply:SendLua([[chat.AddText(Color(30, 144, 255), "]] .. getMessage("playerAlreadyRegistered") .. [[")]])
        end
    end

    checkQuery.onError = function(_, err)
        print(getMessage("dbCheckError", {error = err}))
        ply:SendLua([[chat.AddText(Color(255, 0, 0), "]] .. getMessage("checkError") .. [[")]])
    end

    checkQuery:start()
end

local function getMaxUniqueID(getMessage, ply)
    local query = policeDb:query("SELECT MAX(unique_id) as max_id FROM flizan_player_info")
    
    query.onSuccess = function(_, result)
        local maxID = tonumber(result[1].max_id)
        if maxID then
            recordPlayerInfo(getMessage, ply, maxID + 1)
        else
            recordPlayerInfo(getMessage, ply, 1)
        end
    end
    
    query.onError = function(_, err)
        print(getMessage("dbMaxIDError", {error = err}))
    end
    
    query:start()
end

local function setupPlayerInfoHook(getMessage)
    hook.Add("PlayerInitialSpawn", "RecordPlayerInfo", function(ply)
timer.Simple(5, function()
local steamID = ply:SteamID()
if steamID then
getMaxUniqueID(getMessage, ply)
else
print(getMessage("steamIDUnavailable"))
end
end)
end)
end

return setupPlayerInfoHook