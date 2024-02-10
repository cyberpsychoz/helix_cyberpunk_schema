hook.Add("CreateCharacterInfo", "ImplantsCharacterInfo", function( PANEL )
	local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	PANEL.implants = PANEL:Add("ixListRow")
	PANEL.implants:SetList(PANEL.list)
	PANEL.implants:Dock(TOP)
end)

function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[нереализуемый тип данных:" .. type(val) .. "]\""
    end

    return tmp
end

hook.Add("UpdateCharacterInfo", "UpdateImplantsInfo", function( PANEL, character )
	local implantsData = character:GetData("implants", {})
	local implantsText = table.ToString(implantsData, "Установленные импланты", true)
	PANEL.implants:SetLabelText(L("Импланты: "))
	PANEL.implants:SetText(L(implantsText))
	PANEL.implants:SizeToContents()
end)
