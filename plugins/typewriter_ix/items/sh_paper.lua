ITEM.name = "Электронная книга"
ITEM.description = "Старая электронная книга, один из самых надежных переносчиков информации."
ITEM.model = "models/lt_c/tech/tablet_civ.mdl"
ITEM.skin = 1
ITEM.width = 1
ITEM.height = 1

ITEM.functions.View = {
	name = "Включить",
	OnClick = function(item)
		MascoTypeWriter.Document = vgui.Create("ixDocument")
		MascoTypeWriter.Document:SetDocument(item)
	end,
	OnRun = function(item) return false end,
	OnCanRun = function(item)
		if IsValid(item.entity) or item:GetData("DocumentBody") == nil then
            return false
        end
	end,
}

function ITEM:GetName()
	return self:GetData("DocumentName", self.name)
end

function ITEM:GetDescription()
	return Format(
		"%s %s %s",
		self.description,
		self:GetData("DocumentBody") and "Информация присутствует на этом электронном устройстве." or "Информация отсутствует на этом электронном устройстве.",
		LocalPlayer():IsAdmin() and ("Информация была загружена "..self:GetData("оболочкой: ", "N/A")) or ""
	)
end