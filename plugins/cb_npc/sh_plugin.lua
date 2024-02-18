local PLUGIN = PLUGIN

PLUGIN.name = "Cyberpunk NPC's"
PLUGIN.author = "Крыжовник"
PLUGIN.description = "Ебануться туфли гнуться, а у нас и такое есть!"

if SERVER then
    concommand.Add("idiot", function()
        if IsValid(ply) then
            ply:Freeze(false)
        end
    end)
end

if CLIENT then
    local displayText = nil -- объявляем displayText здесь

    function GetMultiLineTextSize(text, font)
        surface.SetFont(font)
        local _, textHeight = surface.GetTextSize("W") -- высота строки
    
        local lines = string.Explode("\n", text)
        local maxWidth = 0
    
        for _, line in ipairs(lines) do
            local textWidth = surface.GetTextSize(line)
            if textWidth > maxWidth then
                maxWidth = textWidth
            end
        end
    
        return maxWidth, textHeight * #lines
    end

    function DrawTextMultiline(text, x, y, font)
        surface.SetFont(font)
        local _, textHeight = surface.GetTextSize("W") -- высота строки

        for i, line in ipairs(string.Explode("\n", text)) do
            surface.SetTextPos(x, y + (i - 1) * textHeight)
            surface.DrawText(line)
        end
    end

    function DisplayText(text, soundFile)
        local counter = 0
        displayText = text -- устанавливаем displayText здесь

        timer.Create("TextDisplay", 0.01, #text, function() -- здесь определяем скорость текста
            counter = counter + 1
            displayText = string.sub(text, 1, counter)
            if soundFile and counter % 7 == 0 then
                surface.PlaySound(soundFile)
            end
        end)

        hook.Add("HUDPaint", "DrawNpcText", function()
            if displayText and #displayText > 0 then -- проверяем, что displayText не пуст
                local _, textHeight = GetMultiLineTextSize(displayText, "ixMediumFont") -- используем новую функцию здесь
                local lines = #string.Explode("\n", displayText)
                draw.RoundedBox(5, ScrW() / 2 - 300, ScrH() / 2 + 250 - (lines - 1) * textHeight / 4, 600, textHeight * lines + 6 - (lines - 1) * textHeight, Color(0, 0, 0, 200)) -- заменили textWidth на 600 здесь
                DrawTextMultiline(displayText, ScrW() / 2 - 300, ScrH() / 2 + 250 - (lines - 1) * textHeight / 4, "ixMediumFont")
            end
        end)
    end

    function RemoveDisplayText()
        hook.Remove("HUDPaint", "DrawNpcText")
        displayText = nil -- устанавливаем displayText в nil здесь
        timer.Remove("TextDisplay")
    end

    concommand.Add("remove_text", function()
        RemoveDisplayText()
    end)
end

ix.util.Include("sv_plugin.lua")