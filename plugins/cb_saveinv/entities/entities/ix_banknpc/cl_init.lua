ENT.PrintName = "Хранитель"
ENT.Author = "gm1003 ツ"
ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
    surface.SetFont("ixIconsSmall")

    local title = tooltip:AddRow("name")
    title:SetImportant()
    title:SetText("Сотрудник компании Мега-Тек")
    title:SetBackgroundColor(ix.config.Get("color"))
    title:SizeToContents()

    local description = tooltip:AddRow("description")
    description:SetText("Типичный клерк компании, вы можете оставить ему на хранение некоторые вещи.")
    description:SizeToContents()
end