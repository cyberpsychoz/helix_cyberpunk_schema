PLUGIN.name = "Cyberpunk RED system"
PLUGIN.author = "Крыжовник"
PLUGIN.description = "Сделано для проекта Cyberpunk RED."

-- [[ FILE INCLUSIONS ]] --

ix.util.Include("sh_hooks.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_config.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sh_chat.lua")
--ix.util.Include("cl_plugin.lua")
--ix.util.Include("sh_hrpgskills.lua")

PLUGIN.hudTextColors = {
	GREEN = Color(0, 255, 0),
	BLUE = Color(0, 128, 255),
	YELLOW = Color(255, 255, 0),
	RED = Color(255, 0, 0),
	BLACK = Color(128, 128, 128)
}

 -- Нетраннерские приколы

 --[[Cтарая функция взлома
local function HackDoor(client, door)
    local char = client:GetCharacter()
    local netrunning = char:GetSkill("netrunning", 0)
    print(netrunning)
    
    local L = 180 -- максимальное время взлома
    local k = 1 / (netrunning + 1) -- коэффициент роста
    local x0 = netrunning / 2 -- половина навыка от максимума

    -- Пересмотренная формула для времени взлома
    local time = L / (1 + math.exp(-k * (netrunning - x0)))

    -- Проверяем, является ли игрок нетранером
    if char:GetBackground() == "Нетраннер" then
        -- Проверяем, является ли дверь дверью и закрыта ли она
        if door:GetClass() == "prop_door_rotating" and door:GetNWBool("Closed") then
            -- Ебошим прогресбар на взлом
            client:SetAction("ПРОИСХОДИТ ВЗЛОМ...", time)
            client:DoStaredAction(self, function()
                door:Fire("Open")
            end)
            print("Дверь взломана и открыта за " .. time .. " секунд.")
        else
            print("Дверь уже открыта или не является дверью.")
        end
    else
        print("Вы не нетранер.")
    end
end


-- Контекстная кнопка
properties.Add("Hack", {
    MenuLabel = "Взломать",
    Order = 999,
    MenuIcon = "icons/hacker.png", 
    Filter = function(self, ent, ply)
        -- Проверяем, является ли объект дверью и является ли игрок нетранером
        return IsValid(ent) --and ent:GetClass() == "prop_door_rotating"
    end,
    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        HackDoor(ply, ent)
    end
})
]]