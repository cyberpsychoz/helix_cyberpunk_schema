local PLUGIN = PLUGIN
--local totalPoints = 30

function OpenUpgradeMenu(ply)
    local totalPoints = 10 
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 500)
    frame:Center()
    frame:SetTitle("Распределите навыки")
    frame:MakePopup()

    local label = vgui.Create("DLabel", frame)
    label:SetPos(20, 30)
    label:SetSize(460, 20)
    label:SetText("Всего навыков: " .. totalPoints)

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(20, 60)
    scroll:SetSize(460, 430)

    local y = 10
    local character = ply:GetCharacter()
    local skillsList = character:GetData(skills, nil)
    PrintTable(skillsList)
    --[[
    for skill, data in pairs(SKILLS) do
        local button = vgui.Create("DButton", scroll)
        button:SetPos(10, y)
        button:SetSize(440, 30)
        button:SetText(data.translation .. ": " .. points)
        button.DoClick = function()
            if totalPoints > 0 and points < data.maxpoints then
                points = points + 1
                totalPoints = totalPoints - 1
                button:SetText(data.translation .. ": " .. points)
                label:SetText("Всего навыков: " .. totalPoints)
                character:SetVar(skill, points)
            elseif points >= data.maxpoints then
                ply:ChatPrint("Вы не можете прокачать этот навык выше текущего значения!")
            end
        end

        y = y + 40
    end
    ]]
end

