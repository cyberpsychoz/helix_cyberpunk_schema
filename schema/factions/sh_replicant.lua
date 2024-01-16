FACTION.name = "Репликант"
FACTION.description = "Начальная фракция"
FACTION.isDefault = true
FACTION.color = Color(168, 218, 220)

function FACTION:GetDefaultName(client)
	return "E-" .. math.random(1000, 9999), true
end

FACTION_REPLICANT = FACTION.index