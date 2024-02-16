hook.Add("CreateCharacterInfo", "ImplantsCharacterInfo", function( PANEL )
	local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	PANEL.implants = PANEL:Add("ixListRow")
	PANEL.implants:SetList(PANEL.list)
	PANEL.implants:Dock(TOP)
end)

function ViewImplants(implants)
    local implantsText = ""

    if type(implants) == "table" then
        for category, implantData in pairs(implants) do
            local implantName = implantData[1] or "Нет названия"
            implantsText = implantsText .. category .. " - " .. implantName .. "\n"
        end
    else
        implantsText = "Ошибка: неверный тип данных для имплантов"
    end

    return implantsText
end

hook.Add("UpdateCharacterInfo", "UpdateImplantsInfo", function( PANEL, character )
    local implantsData = character:GetData("implants", nil)
    if implantsData then
        local implantsText = ViewImplants(implantsData)
        PANEL.implants:SetLabelText(L("Импланты: "))
        PANEL.implants:SetText(implantsText)
    else
        PANEL.implants:SetLabelText(L("Импланты: "))
        PANEL.implants:SetText(L("Не имеется."))
    end
    PANEL.implants:SizeToContents()
end)

