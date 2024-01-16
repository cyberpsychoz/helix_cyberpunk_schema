ITEM.name = "Implant"
ITEM.description = "Cyberpunk implants"
ITEM.category = "Implants"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.class = "implant"
ITEM.width = 2
ITEM.height = 2
ITEM.isWeapon = false
ITEM.isGrenade = false
ITEM.useSound = "items/ammo_pickup.wav"

-- Функция проверки возможности использования предмета
function ITEM:CanPlayerInstallImplant(player)
    local character = player:GetCharacter()
    return character:GetClass() == CLASS_REPMED
end

-- Функция для добавления или обновления данных об установленных имплантах
function ITEM:AddImplantData(player, implantName)
    print("Игрок: ", player)
    local character = player:GetCharacter()
    local implantsData = character:GetData("implants", {})
    local boostname = self.attrboost
    local boostbonus = self.bonus
    local bodypart = self.bodypart
    local skillname = self.skillname
    local skillbonus = self.skillbonus
    print("Улучшает атрибут: " .. boostname .. " на " .. boostbonus)

    -- Добавляем или обновляем данные об импланте
    implantsData[bodypart] = {implantName, boostbonus, boostname, skillbonus, skillname}

    -- Сохраняем данные в персонаже
    character:SetData("implants", implantsData)

    -- Увеличиваем атрибут
    local currentAttr = character:GetAttribute(boostname, 0)
    character:SetAttrib(boostname, currentAttr + boostbonus)

    -- Увеличиваем навык
    local currentSkill = character:GetSkill(skillname, 0)
    character:SetSkill(skillname, currentSkill + skillbonus)
end

ITEM.functions.Use = {
    name = "Вживить имплант",
    icon = "icons/0_2.png",
    OnRun = function(item)
        local client = item.player

        if item:CanPlayerInstallImplant(client) then
            local trace = client:GetEyeTraceNoCursor()
            local target = trace.Entity

            -- Проверяем валидность цели 
            if IsValid(target) and target:IsPlayer() and target ~= client then
                local cybertechSkill = client:GetCharacter():GetSkill("cybertech", 0)

                -- Модификатор
                local chanceModifier = cybertechSkill * 5 -- Уровень cybertech добавляет 5% к шансу на 1 пункт, НЕ ЗАБЫТЬ

                -- Рассчитываем общий шанс
                local randomNum = math.random(1, chanceModifier)

                -- Выводим отображение насколько ты лох ебаный
                ix.chat.Send(client, "me", "попытался установить имплант с шансом (" .. randomNum .. " из " .. item.basechance .. ").")

                -- Проверка возможности установки импланта
                if randomNum >= item.basechance then
                    target:ChatPrint(client:GetName() .. " успешно установил вам имплант!")
                    client:ChatPrint("Вы успешно установили имплант " .. target:GetName() .. "!")

                    -- Добавляем или обновляем имплант в данных персонажа
                    item:AddImplantData(target, item.name)
                    return true
                else
                    client:ChatPrint("При установке импланта что-то пошло не так...")
                    target:ChatPrint("При установке импланта что-то пошло не так...")
                    target:TakeDamage(item.bonus)
                    return false
                end
            else
                client:ChatPrint("Чумба ты не можешь вставить имплант сам себе!")
                return false
            end
        else
            client:ChatPrint("Даже блять не пробуй это делать. Ты без понятия как устанавливать импланты.")
            return false
        end
    end
}
--[[
ITEM.functions.DebugApplyImplant = {
    name = "Отладка: Применить имплант на себе",
    icon = "icons/arrow_upward.png",
    OnRun = function(item)
        local client = item.player
        local name = item.name

        -- Обновляем данные персонажа
        item:AddImplantData(client, name)
        item.player:Notify("Вы успешно применили имплант на себе для дебага.")
        return false
    end,
}
]]