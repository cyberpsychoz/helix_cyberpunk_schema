hook.Add("CreateCharacterInfo", "ImplantsCharacterInfo", function( PANEL )
	local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	PANEL.implants = PANEL:Add("ixListRow")
	PANEL.implants:SetList(PANEL.list)
	PANEL.implants:Dock(TOP)
end)

hook.Add("UpdateCharacterInfo", "UpdateImplantsInfo", function( PANEL, character )
	PANEL.implants:SetLabelText(L("Импланты: "))
	PANEL.implants:SetText(L(character:GetData("implants", "Отсутствуют.")))
	PANEL.implants:SizeToContents()
end)
