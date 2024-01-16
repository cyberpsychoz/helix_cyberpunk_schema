
CLASS.name = "Человек обыкновенный"
CLASS.description = "Описание себя исчерпывает"
CLASS.faction = FACTION_HUMAN
CLASS.isDefault = true

function CLASS:OnCanBe(client)
	return false
end

CLASS_HUMAN1 = CLASS.index
