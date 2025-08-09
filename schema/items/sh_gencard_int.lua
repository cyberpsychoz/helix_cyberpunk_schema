ITEM.name = "Нейронная карта - \"INT\" "
ITEM.description = "Оцифрованная запись чьего-то мозга, чей конструкт имел довольно хороший интеллект. Можно применить в БИСК-М."
ITEM.model = "models/lt_c/sci_fi/holo_tablet.mdl"
ITEM.skin = 4
ITEM.width = 2
ITEM.height = 1
ITEM.price = 45000
ITEM.category = "LVL-UP THINGS"


ITEM.functions.Use = {
    name = "Использовать",
    OnRun = function(item)
        local client = item.player
        local character = client:GetCharacter()

        -- Получаем объект, на который смотрит игрок
        local trace = client:GetEyeTraceNoCursor()
        local entity = trace.Entity

        -- Проверяем, является ли объект ix_lvluptable
        if IsValid(entity) and entity:GetClass() == "ix_lvlupcapsule" then 
            -- Увеличиваем атрибут PHY
            local current = character:GetAttribute("int", 0)
            local debaf = character:GetAttribute("emp", 0)
            
            if current < 20 then
                character:SetAttrib("emp", debaf - 1)
                character:SetAttrib("int", current + 1)
                client:Notify("Ваш генный код был изменён.")
            else
                client:Notify("Ваш генный код слишком сильно деформирован для внесения новых изменений...")
                return false
            end

            return true
        else
            client:Notify("Вы должны использовать это в БИСК-М.")
            return false
        end
    end
}