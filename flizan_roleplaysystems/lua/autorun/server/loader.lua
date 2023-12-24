include("mysql/connect_db.lua")
include("mysql/create_tables.lua")
include("createpass/sv_pass.lua")
include("createpass/sv_playernewjoin.lua")
include("createpass/sv_playerupdate.lua")
print("FL-System 1.3 has been successfully loaded")

local currentVersion = "1.3" 

local function initializeDatabase()
    sql.Query("CREATE TABLE IF NOT EXISTS flizan_pass_version (version TEXT, first_load DATETIME)")

    local data = sql.Query("SELECT * FROM flizan_pass_version")

    if not data then
        sql.Query("INSERT INTO flizan_pass_version (version, first_load) VALUES ('" .. currentVersion .. "', DATETIME('now'))")
        print("[POLICE SYSTEM] The first launch! The version is set to " .. currentVersion)
    else
        local lastVersion = data[#data].version
        if lastVersion ~= currentVersion then
            sql.Query("INSERT INTO flizan_pass_version (version, first_load) VALUES ('" .. currentVersion .. "', DATETIME('now'))")
            print("[POLICE SYSTEM] A new version has been discovered! Upgrade from " .. lastVersion .. " to " .. currentVersion)
        else
            print("[POLICE SYSTEM] Launching an existing version " .. currentVersion)
        end
    end
end

initializeDatabase()
