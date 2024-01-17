hook.Add("CanChangeRPName", "UpdatePlayerNicknameInDB", function(ply, newName)
    if IsValid(ply) then
        local steamID = policeDb:escape(ply:SteamID())

        local function updateNickname()
            local escapedName = policeDb:escape(newName) 
            local query = policeDb:query("UPDATE flizan_player_info SET nickname = '" .. escapedName .. "' WHERE steamid = '" .. steamID .. "'") -- Обновляем никнейм игрока в базе данных

            query.onSuccess = function()
                print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Никнейм обновлен для игрока " .. ply:Nick())
            end

            query.onError = function(_, err)
                print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Ошибка обновления никнейма для игрока " .. ply:Nick() .. ": " .. err)
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
            criminal:SendLua([[chat.AddText(Color(30, 144, 255), "[Полицейский Департамент] ", Color(255, 255, 255), "Вы разыскиваетесь.")]])

            local logQuery = policeDb:query("INSERT INTO flizan_logs_police (name, steamid, name2, steamid2, date, action, reason) VALUES ('" .. escapedActorName .. "', '" .. actorSteamID .. "', '" .. escapedCriminalName .. "', '" .. criminalSteamID .. "', NOW(), 'wantedplayer', '" .. escapedReason .. "')") -- Записываем действие в журнал логов

            logQuery.onError = function(_, err)
                print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Ошибка записи в лог: " .. err)
            end

            logQuery:start()
        end

        query.onError = function(_, err)
            print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Ошибка пометки игрока " .. actor:Nick() .. " как разыскиваемого: " .. err)
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
            excriminal:SendLua([[chat.AddText(Color(30, 144, 255), "[Полицейский Департамент] ", Color(255, 255, 255), "Вы больше не разыскиваетесь.")]])

            local logQuery = policeDb:query("INSERT INTO flizan_logs_police (name, steamid, name2, steamid2, date, action) VALUES ('" .. actor:Nick() .. "', '" .. actorSteamID .. "', '" .. excriminal:Nick() .. "', '" .. excriminalSteamID .. "', NOW(), 'unwantedplayer')") -- Записываем действие в журнал логов

            logQuery.onError = function(_, err)
                print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Ошибка записи в лог: " .. err)
            end

            logQuery:start()
        end

        query.onError = function(_, err)
            print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Ошибка снятия статуса разыскиваемого с игрока " .. actor:Nick() .. ": " .. err)
        end

        query:start()
    end
end)

hook.Add("PlayerDisconnected", "ClearWantedOnDisconnect", function(ply)
    local steamID = policeDb:escape(ply:SteamID()) -- Получаем SteamID игрока и экранируем его
    local query = policeDb:query("UPDATE flizan_player_info SET wanted = 0 WHERE steamid = '" .. steamID .. "'") 
    query.onSuccess = function()
        -- print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Игрок " .. ply:Nick() .. " отключился. Статус разыскиваемого сброшен.")
    end

    query.onError = function(_, err)
        print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Ошибка обновления статуса разыскиваемого для игрока " .. ply:Nick() .. ": " .. err)
    end

    query:start()
end)

hook.Add("ShutDown", "ResetAllWantedStatuses", function()
    local query = policeDb:query("UPDATE flizan_player_info SET wanted = 0 WHERE wanted = 1") 

    query.onSuccess = function()
        print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Все статусы разыскиваемых сброшены при завершении сервера.")
    end

    query.onError = function(_, err)
        print("[ПОЛИЦЕЙСКАЯ СИСТЕМА] Ошибка сброса статусов разыскиваемых при завершении сервера: " .. err)
    end

    query:start()
end)