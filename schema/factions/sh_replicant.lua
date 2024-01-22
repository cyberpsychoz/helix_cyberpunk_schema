FACTION.name = "Репликант"
FACTION.description = "Начальная фракция"
FACTION.isDefault = true
FACTION.color = Color(168, 218, 220)
FACTION.Ranks = {
    [1] = {"Непрошитый", "icon16/medal_bronze_1.png", CLASS_REPNO},
    [2] = {"Обслуживающий", "icon16/medal_bronze_1.png", CLASS_REPCLEAN},
    [3] = {"Охранный", "icon16/medal_bronze_1.png", CLASS_REPWAR},
    [4] = {"Медицинский", "icon16/medal_bronze_1.png", CLASS_REPMED},
    [5] = {"Научный", "icon16/medal_silver_1.png", CLASS_REPSMART}
    -- [6] = {"Sergeant Major", "icon16/medal_gold_1.png", CLASS_SENIOR, true}
}

function FACTION:GetDefaultName(client)
	return "E-" .. math.random(1000, 9999), true
end

FACTION_REPLICANT = FACTION.index