ITEM.name = "Портативный сканер - ТЦКиО"
ITEM.description = "Портативный сканер тестирования целостности конструкта и оболочки появился не так давно и до 2032 года представлял собой довольно громоздкое устройство. Он был создан для того чтобы определять целостность конструкта и психическую стабильность репликанта или авторейва. Но также может быть пригоден для медицинского обследования обычных людей."
ITEM.model = "models/cyberpunk/items/w_eyescannerhack.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 3500
ITEM.category = "Tools"

local diseaseDescriptions = {
    cough = "Кровоподтеки в легких",
    cyberpsychosis = "Аномальная активность мозга и нервной системы",
    blindness = "Отслоение сетчатки, нарушение целостности зрительной коры",
    cogito = "Признаки нарушения конструкта, обнаруженны нетипичные нейронные связи"
}

function ScanDisease(client)
    if client:IsValid() then
        local character = client:GetCharacter()
        local diseases = character:GetData("diseaseInfo", "Нету.")

        -- Создаем пустую строку для хранения описаний болезней
        local diseaseInfo = "\n"

        -- Разбиваем строку болезней на отдельные названия
        local diseaseNames = string.Split(diseases, ";")

        -- Для каждого названия болезни находим соответствующее описание
        for _, name in ipairs(diseaseNames) do
            local description = diseaseDescriptions[name]
            if description then
                -- Добавляем описание к строке diseaseInfo
                diseaseInfo = diseaseInfo .. description .. "\n"
            end
        end

        --print("Болячки: ", diseaseInfo)
        return diseaseInfo
    end
end

ITEM.functions.ScanSelf = {
    name = "Просканировать себя",
    icon = "icons/bionic-eye.png",
    OnRun = function(item)
        local ply = item.player 

        --ScanDisease(ply)

        if IsValid(ply) then
            local diseases = ScanDisease(ply)
            print(diseases)

            ply:ChatPrint("================================")
            ply:ChatPrint("=== РЕЗУЛЬТАТЫ СКАНИРОВАНИЯ ===")
            ply:ChatPrint("================================")
            if ply:GetCharacter():GetFaction() == FACTION_HUMAN then

                ply:ChatPrint("Анализ тканей: Природные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)
                ply:ChatPrint("================================")

            elseif ply:GetCharacter():GetFaction() == FACTION_REPLICANT then

                ply:ChatPrint("Анализ тканей: Искусcтвенные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)
                ply:ChatPrint("Маркировка оболочки: " .. ply:GetName())
                ply:ChatPrint("Владелец оболочки: " .. ply:GetCharacter():GetData("affiliation", "Не найдено."))
                ply:ChatPrint("================================")

            elseif ply:GetCharacter():GetFaction() == FACTION_DEVIANT then

                ply:ChatPrint("Маркировка оболочки: " .. ply:GetName())
                ply:ChatPrint("Анализ тканей: Искусcтвенные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)
                ply:ChatPrint("Маркировка оболочки: Невозможно считать")
                ply:ChatPrint("Владелец оболочки: DELETE")
                ply:ChatPrint("[!] ВНИМАНИЕ! У данной оболочки обнаружена повышенная нестабильность!")

            elseif ply:GetCharacter():GetFaction() == FACTION_AUTORAVE then

                ply:ChatPrint("Анализ тканей: Искусcтвенные - модифицированные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)
                ply:ChatPrint("Маркировка оболочки: " .. ply:GetName())
                ply:ChatPrint("Владелец оболочки: " .. ply:GetCharacter():GetData("affiliation", "Не найдено."))

            end
        else
            ply:Notify("Вы можете сканировать только оболочки!")
        end

        return false
    end,
}

ITEM.functions.Scan = {
    name = "Просканировать оболочку",
    icon = "icons/bionic-eye.png",
    OnRun = function(item)
        local ply = item.player 
        local trace = ply:GetEyeTrace()
        local target = trace.Entity

        -- ТЕстик
        --ScanDisease(ply)

        if target:IsValid() and target:GetClass() == "player" then
            local diseases = ScanDisease(target)
            --print(diseases)

            ply:ChatPrint("================================")
            ply:ChatPrint("=== РЕЗУЛЬТАТЫ СКАНИРОВАНИЯ ===")
            ply:ChatPrint("================================")
            if target:GetCharacter():GetFaction() == FACTION_HUMAN then

                ply:ChatPrint("Анализ тканей: Природные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)

            elseif target:GetCharacter():GetFaction() == FACTION_REPLICANT then

                ply:ChatPrint("Анализ тканей: Искусcтвенные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)
                ply:ChatPrint("Маркировка оболочки: " .. target:GetName())
                ply:ChatPrint("Владелец оболочки: " .. targetGetCharacter():GetData("affiliation", "Не найдено."))

            elseif target:GetCharacter():GetFaction() == FACTION_DEVIANT then

                ply:ChatPrint("Маркировка оболочки: " .. ply:GetName())
                ply:ChatPrint("Анализ тканей: Искусcтвенные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)
                ply:ChatPrint("Маркировка оболочки: Невозможно считать")
                ply:ChatPrint("Владелец оболочки: DELETE")
                ply:ChatPrint("[!] ВНИМАНИЕ! У данной оболочки обнаружена повышенная нестабильность!")

            elseif target:GetCharacter():GetFaction() == FACTION_AUTORAVE then

                ply:ChatPrint("Анализ тканей: Искусcтвенные - модифицированные")
                ply:ChatPrint("Девиации оболочки: " .. diseases)
                ply:ChatPrint("Маркировка оболочки: " .. target:GetName())
                ply:ChatPrint("Владелец оболочки: " .. target:GetCharacter():GetData("affiliation", "Не найдено."))

            end
        else
            ply:Notify("Вы можете сканировать только оболочки!")
        end

        return false
    end,
}