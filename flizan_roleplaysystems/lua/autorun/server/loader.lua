local languageSettings = include("language_settings.lua")
local currentVersion = "1.4"
local language = "ru"

local function getMessage(key, replacements)
    local message = languageSettings[language][key] or ""
    
    if replacements then
        for k, v in pairs(replacements) do
            message = message:gsub("{{" .. k .. "}}", v)
        end
    end
    
    return message
end

local function initializeDatabase()
    sql.Query("CREATE TABLE IF NOT EXISTS flizan_pass_version (version TEXT, first_load DATETIME)")

    local data = sql.Query("SELECT * FROM flizan_pass_version")

    if not data then
        sql.Query("INSERT INTO flizan_pass_version (version, first_load) VALUES ('" .. currentVersion .. "', DATETIME('now'))")
        print(getMessage("firstLaunch", {version = currentVersion}))
    else
        local lastVersion = data[#data].version
        if lastVersion ~= currentVersion then
            sql.Query("INSERT INTO flizan_pass_version (version, first_load) VALUES ('" .. currentVersion .. "', DATETIME('now'))")
            print(getMessage("newVersion", {lastVersion = lastVersion, currentVersion = currentVersion}))
        else
            print(getMessage("existingVersion", {currentVersion = currentVersion}))
        end
    end
end

initializeDatabase()

local connectDB = include("mysql/connect_db.lua")
connectDB(getMessage)

local tables = include("mysql/create_tables.lua")
tables.createPlayerInfoTable(getMessage)
tables.createPoliceLogsTable(getMessage)

local setupPassportCommand = include("createpass/sv_pass.lua")
setupPassportCommand(getMessage)

local setupPlayerInfoHook = include("createpass/sv_playernewjoin.lua")
setupPlayerInfoHook(getMessage)

include("createpass/sv_playerupdate.lua")

print(getMessage("loaded", {version = currentVersion}))