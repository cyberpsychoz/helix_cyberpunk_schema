ITEM.name = "Промышленный сканер"
ITEM.description = "Старое, огромное и тяжелое устройство, если вы не техник, то явно с ним не разберетесь. Позволяет просканировать любой объект, с помощью различных ультразвуковых, магнитронных и радио датчиков."
ITEM.model = "models/slasherin/last year/props/retro-pack/sm_portabletv_01f.mdl"
ITEM.width = 3
ITEM.height = 2
ITEM.price = 7000
ITEM.category = "Tools"

local function ScanObject(ply)
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity
    local character = ply:GetCharacter()
    local backstory = character:GetBackground()

    if backstory == "Техник" then
        if IsValid(ent) then
            ply:ChatPrint("================================")
            ply:ChatPrint("=== РЕЗУЛЬТАТЫ СКАНИРОВАНИЯ ===")
            ply:ChatPrint("================================")
            -- Проверяем, если сканируем игрока
            if ent:IsPlayer() then
                ply:ChatPrint("Сканируемый объект: Оболочка")
                -- Проверяем, если фракция репликантов или авторавов
                if ent:GetCharacter():GetFaction() == FACTION_HUMAN then
                    ply:ChatPrint("[!] Сканирование природной органики промышленным сканером может нанести существенный вред здоровью!")
                    ent:TakeDamage(3)
                    return
                else
                    ply:ChatPrint("Порядковый номер оболочки:" .. ent:Name())
                end
        
                local implants = ent:GetCharacter():GetData("implants", "Отсутствуют.")
                if implants ~= "Отсутствуют." then
                    ply:ChatPrint("Технические модификаторы оболочки:")
                    for category, implantData in pairs(implants) do
                        local implantName = implantData[1] or "Нет названия"
                        ply:ChatPrint(category .. " - " .. implantName)
                    end
                else
                    ply:ChatPrint(implants)
                    ply:ChatPrint("================================")
                end
            else
                ply:ChatPrint("Сканируемый объект: Не является оболочкой")
                ply:ChatPrint("Идентификатор объекта: " .. ent:GetName())
                ply:ChatPrint("Принцип работы: " .. ent:GetClass())
                ply:ChatPrint("================================")
            end
        else
            ply:Notify("Ваш сканер не направлен на объект.")
        end
    else
        ply:Notify("Ты понятия не имеешь как вообще пользоваться сканером...")
    end
end

ITEM.functions.Scan = {
    name = "Просканировать объект",
    icon = "icons/bionic-eye.png",

    OnRun = function(item)
        local ply = item.player
        ScanObject(ply)
        return false
    end,

}

--[[Функция дебага для игрока
local function DebugScan(ply)
    -- Проверяем, если сканируем игрока
    if ply:IsPlayer() then
        print("Сканируемый объект: Оболочка")
        -- Проверяем, если фракция репликантов или авторавов
        if ply:GetCharacter():GetFaction() == FACTION_HUMAN then
            print("[!] Сканирование природной органики промышленным сканером может нанести существенный вред здоровью!")
            return
        else
            print("Порядковый номер оболочки:", ply:Name())
        end

        local implants = ply:GetCharacter():GetData("implants", "Отсутствуют.")
        if implants ~= "Отсутствуют." then
            print("Технические модификаторы оболочки:")
            for category, implantData in pairs(implants) do
                local implantName = implantData[1] or "Нет названия"
                print(category .. " - " .. implantName)
            end
        else
            print("Импланты: ", implants)
        end
        -- Сохранение данных
        lastScanData.name = ply:Name()
    end
end
]]

--[[
ITEM.functions.Debug = {
    name = "ДЕБАГ СКАНА",
    icon = "icons/bionic-eye.png",

    OnRun = function(item)
        local ply = item.player
        DebugScan(ply)
        return false
    end,

}
]]