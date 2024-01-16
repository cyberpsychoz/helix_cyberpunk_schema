function OpenRollPanel(ply)
    if IsValid(frame) then return end

    frame = vgui.Create("DFrame")
    frame:SetSize(300, 400)
    frame:Center()
    frame:SetTitle("Ваши навыки")
    frame:MakePopup()

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)

    local character = ply:GetCharacter()

    if character then
        for k, v in SortedPairsByMemberValue(ix.skills.list, "name") do
            local btn = scroll:Add("DButton")
            btn:SetText(v.name)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 5)

            btn.DoClick = function()
                local skillName = v.uniqueID
                ix.command.Run(ply, "RollStat", skillName)
            end
        end
    end

    frame.OnRemove = function()
        frame = nil
    end
end

hook.Add("PlayerButtonDown", "OpenRollPanel", function(ply, button)
    if button == KEY_K then
        OpenRollPanel(ply)
    end
end)

concommand.Add("debug_openrollpanel", function(ply)
    OpenRollPanel(ply)
end)
