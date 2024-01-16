ITEM.name = "Хирургический набор"
ITEM.model = "models/your_model_path.mdl" -- Замените на путь к модели вашего предмета
ITEM.description = "Набор инструментов для удаления имплантов."
ITEM.basechance = 50 -- Базовый шанс успешного удаления импланта

function ITEM:OnRun(client)
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
        ix.chat.Send(client, "me", "попытался удалить имплант с шансом (" .. randomNum .. " из " .. self.basechance .. ").")

        -- Проверка возможности удаления импланта
        if randomNum >= self.basechance then
            target:ChatPrint(client:GetName() .. " успешно удалил у вас имплант!")
            client:ChatPrint("Вы успешно удалили имплант " .. target:GetName() .. "!")

            -- Удаляем имплант из данных персонажа
            self:RemoveImplantData(target)
            return true
        else
            client:ChatPrint("При удалении импланта что-то пошло не так...")
            target:ChatPrint("При удалении импланта что-то пошло не так...")
            target:TakeDamage(self.basechance) -- Наносим урон цели при неудачной попытке
            return false
        end
    else
        client:ChatPrint("Чумба ты не можешь удалять имплант сам у себя!")
        return false
    end
end

function ITEM:RemoveImplantData(player)
    print("Игрок: ", player)
    local character = player:GetCharacter()
    local implantsData = character:GetData("implants", {})
    local boostname = self.attrboost
    local boostbonus = self.bonus
    local bodypart = self.bodypart
    local skillname = self.skillname
    local skillbonus = self.skillbonus
    print("Уменьшает атрибут: " .. boostname .. " на " .. boostbonus)

    -- Проверяем, есть ли имплант в этой части тела
    if implantsData[bodypart] then
        -- Удаляем данные об импланте
        implantsData[bodypart] = nil

        -- Сохраняем обновленные данные в персонаже
        character:SetData("implants", implantsData)

        -- Уменьшаем атрибут
        local currentAttr = character:GetAttribute(boostname, 0)
        character:SetAttrib(boostname, currentAttr - boostbonus)

        -- Уменьшаем навык
        local currentSkill = character:GetSkill(skillname, 0)
        character:SetSkill(skillname, currentSkill - skillbonus)
    else
        print("В этой части тела нет импланта.")
    end
end

