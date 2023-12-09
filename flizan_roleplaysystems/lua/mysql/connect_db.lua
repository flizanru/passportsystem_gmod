policeDb = nil

function ConnectToDatabase()
    if not policeDb or not policeDb:ping() then
        policeDb = mysqloo.connect("IP", "username", "password", "database", 3306)

        policeDb.onConnected = function()
            print("[FL-System] Successful connection to the database.")
            local charsetQuery = policeDb:query("SET NAMES utf8")
            charsetQuery:start()
        end

        policeDb.onConnectionFailed = function(_, err)
            print("[FL-System] Database connection error: " .. err)
        end

        policeDb:connect()
    end
end

ConnectToDatabase()
