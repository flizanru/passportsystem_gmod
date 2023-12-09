local function createPlayerInfoTable()
    local createTableQuery = policeDb:query([[
        CREATE TABLE IF NOT EXISTS flizan_player_info (
            unique_id VARCHAR(8) PRIMARY KEY,
            nickname VARCHAR(255),
            steamid VARCHAR(20),
            steamid64 VARCHAR(20),
            join_date DATETIME,
            wanted INT,
            gun_license INT
        )
    ]])

    createTableQuery.onSuccess = function()
  --      print("[FL-System] Table 'flizan_player_info' successfully created or already exists.")
    end

    createTableQuery.onError = function(_, err)
        print("[FL-System] Error creating table 'flizan_player_info': " .. err)
    end

    createTableQuery:start()
end

local function createPoliceLogsTable()
    local createTableQuery = policeDb:query([[
        CREATE TABLE IF NOT EXISTS flizan_logs_police (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255),
            steamid VARCHAR(20),
            name2 VARCHAR(255),
            steamid2 VARCHAR(20),
            date DATETIME,
            action VARCHAR(255),
            reason VARCHAR(255)
        )
    ]])

    createTableQuery.onSuccess = function()
--        print("[FL-System] Table 'flizan_logs_police' successfully created or already exists.")
    end

    createTableQuery.onError = function(_, err)
        print("[FL-System] Error creating table 'flizan_logs_police': " .. err)
    end

    createTableQuery:start()
end

createPlayerInfoTable()
createPoliceLogsTable()

return {
    createPlayerInfoTable = createPlayerInfoTable,
    createPoliceLogsTable = createPoliceLogsTable,
    policeDb = policeDb,
}
