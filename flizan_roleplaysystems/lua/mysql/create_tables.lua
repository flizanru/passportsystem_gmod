local function createPlayerInfoTable(getMessage)
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
        print(getMessage("tableCreated", {tableName = "flizan_player_info"}))
    end

    createTableQuery.onError = function(_, err)
        print(getMessage("tableCreateError", {tableName = "flizan_player_info", error = err}))
    end

    createTableQuery:start()
end

local function createPoliceLogsTable(getMessage)
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
        print(getMessage("tableCreated", {tableName = "flizan_logs_police"}))
    end

    createTableQuery.onError = function(_, err)
        print(getMessage("tableCreateError", {tableName = "flizan_logs_police", error = err}))
    end

    createTableQuery:start()
end

return {
    createPlayerInfoTable = createPlayerInfoTable,
    createPoliceLogsTable = createPoliceLogsTable
}
