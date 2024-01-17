policeDb = nil

function ConnectToDatabase(getMessage)
    if not policeDb or not policeDb:ping() then
        policeDb = mysqloo.connect("IP", "db", "password", "db", 3306)

        policeDb.onConnected = function()
            print(getMessage("dbConnected"))
            local charsetQuery = policeDb:query("SET NAMES utf8")
            charsetQuery:start()
        end

        policeDb.onConnectionFailed = function(_, err)
            print(getMessage("dbConnectionFailed", {error = err}))
        end

        policeDb:connect()
    end
end

return ConnectToDatabase