ITEM.name = "Хирургический набор"
ITEM.model = "models/germandude/medbag/medbag_german.mdl"
ITEM.description = "Набор инструментов для удаления имплантов."
ITEM.basechance = 50

function RemoveImplantData(target, bodypart)
    local character = target:GetCharacter()
    if character then
        local implantsData = character:GetData("implants", {})
        PrintTable(implantsData)
        if table.IsEmpty(implantsData) then
            print("У игрока не обнаружено установленных имплантов у " .. character:GetName() .. ".")
        else
            if implantsData[bodypart] then
                -- Получаем информацию об импланте
                local implantInfo = implantsData[bodypart]
                local boostname = implantInfo[3]
                local boostbonus = implantInfo[2]
                local skillname = implantInfo[5]
                local skillbonus = implantInfo[4]
                -- Уменьшаем атрибут
                local currentAttr = character:GetAttribute(boostname, 0)
                --print(currentAttr)
                --print(boostbonus)
                --print(boostname)
                local finboost = currentAttr - boostbonus
                character:SetAttrib(boostname, finboost)
                -- Уменьшаем навык
                local currentSkill = character:GetSkill(skillname, 0)
                local finskill = currentSkill - skillbonus 
                character:SetSkill(skillname, finskill)
                -- Удаляем данные об импланте
                implantsData[bodypart] = nil
                character:SetData("implants", implantsData)
                ix.chat.Send(target, "it", "Из тела " .. target:GetName() .. " был успешно удален один из имплантов.")
            else
                target:ChatPrint("В этой части тела нет импланта.")
            end
        end
    end
end

ITEM.functions.ImplantRemoving = {
    name = "Провести операцию",
    icon = "icons/skull.png",

    OnRun = function(item)
        if SERVER then
            local client = item.player
            local trace = client:GetEyeTraceNoCursor()
            local target = trace.Entity

            local C_character = client:GetCharacter()

            local backstory = C_character:GetBackground()
            local cybertech = C_character:GetSkill("cybertech", 0)
            local luck = C_character:GetAttribute("luck", 0)
            local difficult = math.random(0, cybertech/0.7)
            local random = math.random(0, cybertech) + luck


            --print("Проверка: ", difficult)
            --print("Игрок стат: ", random)
            --print("Предыстория: ", backstory)
            if backstory == "Рипер" then
                if random >= difficult then
                    if target:IsValid() and target:IsPlayer() and target != client then
                        local T_character = target:GetCharacter()
                        local implantsData = T_character:GetData("implants", {})
                        --PrintTable(implantsData)
                        net.Start("SendImplantsData")           
                        net.WriteTable(implantsData)
                        net.WriteEntity(target)
                        net.Send(client)
                    else
                        client:Notify("Вы должны смотреть на игрока чтобы провести операцию!")
                        return false
                    end
                else
                    ix.chat.Send(client, "me", "Попытался достать имплант из тела " .. target:GetName() .. ", но что-то пошло не так...")
                    local dmg = math.random(0, 5)
                    target:TakeDamage(dmg)
                end
            else
                ix.chat.Send(client, "me", "В попытке достать импланты из тела " .. target:GetName() .. " изувечил его до неузнаваемости. Судя по всему он вообще ничего не понимает в хирургии...")
                ix.Diseases:SetRandomDisease(target)
                local dmg = math.random(0, 35)
                target:TakeDamage(dmg)
            end
        end
        return false
    end
}

--[[
ITEM.functions.ImplantRemDebug = {
    name = "ДЕБАГ ОПЕРАЦИЯ",
    icon = "icons/skull.png",

    OnRun = function(item)
        if SERVER then
            net.Start("OpenImplantRemovalMenu")
            net.Send(item.player)
        end
        return false
    end
}
]]

if SERVER then
    util.AddNetworkString("AddItem")
    util.AddNetworkString("RemoveImplant")
    util.AddNetworkString("SendImplantsData")

    net.Receive("RemoveImplant", function(len, ply)
        local target = net.ReadEntity()
        local bodypart = net.ReadString()
        RemoveImplantData(target, bodypart)
    end)

    net.Receive("AddItem", function(len, ply)
        local itemname = net.ReadString()
        local inventory = ply:GetCharacter():GetInventory()
        --print("Имя предмета на сервере: ", itemname)
        local uniqueID = itemname:lower()

		if (!ix.item.list[uniqueID]) then
			for k, v in SortedPairs(ix.item.list) do
				if (ix.util.StringMatches(v.name, uniqueID)) then
					uniqueID = k

					break
				end
			end
        end

        inventory:Add(uniqueID, 1)
        --inventory:Add("medkit", 1)
    end)

elseif CLIENT then
    net.Receive("SendImplantsData", function()
        local frame = vgui.Create("DFrame")
        frame:SetSize(300, 200)
        frame:SetTitle("Меню удаления имплантов")
        frame:Center()
        frame:MakePopup()

        local client = LocalPlayer()
        local implantsData = net.ReadTable()
        local target = net.ReadEntity()
        --if target:IsValid() then
            --print("ЦЕЛЬ НАЙДЕНА")
        --end
        --PrintTable(implantsData)

        if table.IsEmpty(implantsData) then
            --print(implantsData)
            client:ChatPrint("У игрока нет установленных имплантов.")
            frame:Close()
            return
        end

        local y = 30
        for bodypart, implantInfo in pairs(implantsData) do
            print("Имя импланта: ", implantInfo[1])
            local removeButton = vgui.Create("DButton", frame)
            removeButton:SetPos(10, y)
            removeButton:SetSize(280, 20)
            removeButton:SetText("Удалить имплант из " .. bodypart)
            removeButton.DoClick = function()
                net.Start("RemoveImplant")
                net.WriteEntity(target)
                net.WriteString(bodypart)
                net.SendToServer()

                --print("Имя импланта перед отправкой: ", implantInfo[1])
                net.Start("AddItem")
                net.WriteString(implantInfo[1])
                net.SendToServer()
                frame:Close()
            end
            y = y + 30
        end
    end)
end
