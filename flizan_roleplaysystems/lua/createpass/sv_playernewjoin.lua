local function recordPlayerInfo(ply, newID)
    local uniqueID = string.format("%04d", newID) 
    local nickname = policeDb:escape(ply:Nick())
    local steamID = policeDb:escape(ply:SteamID())
    local steamID64 = policeDb:escape(ply:SteamID64())
    local joinDate = os.date("%Y-%m-%d %H:%M:%S")
    local wanted = 0
    local gunLicense = 0

    -- if not string.match(nickname, "^[a-zA-Z0-9_]+$") then
    --     nickname = "NULL"
    --     ply:SendLua([[chat.AddText(Color(255, 0, 0), "[Error] ", Color(255, 255, 255), "Change your STEAM name. It is not allowed.")]])
    -- end

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
                ply:SendLua([[chat.AddText(Color(30, 144, 255), "[Police Department] ", Color(255, 255, 255), "You have been registered in the police department database.")]])
            end

            insertQuery.onError = function(_, err)
                print("Error recording player information in the database: " .. err)
                ply:SendLua([[chat.AddText(Color(255, 0, 0), "An error occurred while recording your data in the police department")]])
            end

            insertQuery:start()
        else
            ply:SendLua([[chat.AddText(Color(30, 144, 255), "[Police Department] ", Color(255, 255, 255), "You are already connected to the police department.")]])
        end
    end

    checkQuery.onError = function(_, err)
        print("Error checking player information in the database: " .. err)
        ply:SendLua([[chat.AddText(Color(255, 0, 0), "Your data was not found. Please visit the nearest police station.")]])
    end

    checkQuery:start()
end

local function getMaxUniqueID(ply)
    local query = policeDb:query("SELECT MAX(unique_id) as max_id FROM flizan_player_info")
    
    query.onSuccess = function(_, result)
        local maxID = tonumber(result[1].max_id)
        if maxID then
            recordPlayerInfo(ply, maxID + 1)
        else
            recordPlayerInfo(ply, 1)
        end
    end
    
    query.onError = function(_, err)
        print("Error getting the maximum identifier: " .. err)
    end
    
    query:start()
end

hook.Add("PlayerInitialSpawn", "RecordPlayerInfo", function(ply)
    timer.Simple(5, function()
        local steamID = ply:SteamID()
        if steamID then
            getMaxUniqueID(ply) 
        else
            print("Error: SteamID not available.")
        end
    end)
end)
