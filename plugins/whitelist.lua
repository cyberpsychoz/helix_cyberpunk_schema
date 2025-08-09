local PLUGIN = PLUGIN

PLUGIN.name = "Whitelist"
PLUGIN.author = "Переделан Крыжовником."
PLUGIN.description = "Adds a server whitelist"

ix.config.Add("whitelistEnabled", false, "Enables the server whitelist.", nil, {
    category = "Whitelist"
})

if SERVER then
    function PLUGIN:LoadData()
        self.allowed = self:GetData() or {}
    end

    function PLUGIN:SaveData()
        self:SetData(self.allowed)
    end

    function PLUGIN:CheckPassword(steamID64)
        local steamID = util.SteamIDFrom64(steamID64)

        if ix.config.Get("whitelistEnabled") and not self.allowed[steamID] then
            return false, "Уп-с! Кажется вас нет в вайтлисте, чтобы получить доступ к серверу, обратитесь в дискорд: https://discord.gg/Nyr7mZA32U \nИли зайдите на сайт: http://cyberpunk-red-wiki.kesug.com/ \nНе волнуйтесь, для вайтлиста вам всего лишь нужно заполнить простую форму, а не писать квенту на 10 листов.\nС уважением, администрация проекта."
        end
    end

    function PLUGIN:PlayerAuthed(client, steamID, uniqueID)
        if ix.config.Get("whitelistEnabled") and not self.allowed[steamID] then
            game.KickID(uniqueID, "Уп-с! Кажется вас нет в вайтлисте, чтобы получить доступ к серверу, обратитесь в дискорд: https://discord.gg/Nyr7mZA32U \nИли зайдите на сайт: http://cyberpunk-red-wiki.kesug.com/ \nНе волнуйтесь, для вайтлиста вам всего лишь нужно заполнить простую форму, а не писать квенту на 10 листов.\nС уважением, администрация проекта.")
        end
    end
end

ix.command.Add("WhitelistAdd", {
    description = "Adds a SteamID to the whitelist",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    arguments = ix.type.string,
    OnRun = function(self, client, steamID)
        if not steamID:match("STEAM_(%d+):(%d+):(%d+)") then
            return "Invalid сука твой айди!"
        end

        if PLUGIN.allowed[steamID] then
            return "УЖЕ СУЩЕСТВУЕТ!"
        else
            PLUGIN.allowed[steamID] = true

            return "Стимайди добавлен в список!"
        end
    end
})

ix.command.Add("WhitelistRemove", {
    description = "Removes a SteamID from the whitelist",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    arguments = ix.type.string,
    OnRun = function(self, client, steamID)
        if not steamID:match("STEAM_(%d+):(%d+):(%d+)") then
            return "Invalid SteamID!"
        end

        if not PLUGIN.allowed[steamID] then
            return "This SteamID is not whitelisted"
        else
            PLUGIN.allowed[steamID] = nil

            return "Removed SteamID from the whitelist"
        end
    end
})

ix.command.Add("WhitelistClear", {
    description = "Clears the whitelist",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    OnRun = function(self)
        PLUGIN.allowed = {}

        return "Cleared the whitelist"
    end
})

ix.command.Add("WhitelistAddAll", {
    description = "Whitelists all current players",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    OnRun = function(self)
        for _, client in ipairs(player.GetHumans()) do
            if IsValid(client) then
                PLUGIN.allowed[client:SteamID()] = true
            end
        end

        return "Added all current players to the whitelist"
    end
})
