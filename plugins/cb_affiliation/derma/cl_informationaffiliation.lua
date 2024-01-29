hook.Add("CreateCharacterInfo", "AffiliationCharacterInfo", function( PANEL )
	local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	PANEL.affiliation = PANEL:Add("ixListRow")
	PANEL.affiliation:SetList(PANEL.list)
	PANEL.affiliation:Dock(TOP)
end)

hook.Add("UpdateCharacterInfo", "UpdateAffiliationInfo", function( PANEL, character )
	PANEL.affiliation:SetLabelText(L("Организация: "))
	PANEL.affiliation:SetText(L(character:GetData("affiliation", "Не имеется.")))
	PANEL.affiliation:SizeToContents()
end)