FACTION.name = "Репликант"
FACTION.description = "Начальная фракция"
FACTION.isDefault = true
FACTION.color = Color(168, 218, 220)
FACTION.Ranks = {
    [1] = {"Непрошитый", "icons/nothing.png", CLASS_REPNO},
    [2] = {"Обслуживающий", "icons/clean.png", CLASS_REPCLEAN},
    [3] = {"Охранный", "icons/war.png", CLASS_REPWAR},
    [4] = {"Медицинский", "icons/medical.png", CLASS_REPMED},
    [5] = {"Научный", "icons/scine.png", CLASS_REPSMART}
    -- [6] = {"Sergeant Major", "icon16/medal_gold_1.png", CLASS_SENIOR, true}
}

FACTION.models = {
    "models/cyberpunk/group01/female_01.mdl",
    "models/cyberpunk/group01/female_02.mdl",
    "models/cyberpunk/group01/female_03.mdl",
    "models/cyberpunk/group01/female_04.mdl",
    "models/cyberpunk/group01/female_05.mdl",
    "models/cyberpunk/group01/female_06.mdl",
    "models/cyberpunk/group01/female_07.mdl",
    "models/cyberpunk/group01/female_08.mdl",
    "models/cyberpunk/group01/female_09.mdl",
    "models/cyberpunk/group01/female_10.mdl",
    "models/cyberpunk/group01/female_11.mdl",
    "models/cyberpunk/group01/female_12.mdl",
    "models/cyberpunk/group01/female_13.mdl",
    "models/cyberpunk/group01/female_14.mdl",
    "models/cyberpunk/group01/male_01.mdl",
    "models/cyberpunk/group01/male_02.mdl",
    --"models/cyberpunk/group01/male_03.mdl",
    --"models/cyberpunk/group01/male_04.mdl",
    "models/cyberpunk/group01/male_05.mdl",
    "models/cyberpunk/group01/male_06.mdl",
    "models/cyberpunk/group01/male_07.mdl",
    "models/cyberpunk/group01/male_08.mdl",
    "models/cyberpunk/group01/male_09.mdl",
    "models/cyberpunk/group01/male_10.mdl",
    "models/cyberpunk/group01/male_11.mdl",
    "models/cyberpunk/group01/male_12.mdl",
    "models/cyberpunk/group01/male_13.mdl",
    "models/cyberpunk/group01/male_14.mdl",
    "models/cyberpunk/group01/male_15.mdl",
    "models/cyberpunk/group01/male_16.mdl"
}

function FACTION:GetDefaultName(client)
	return "E-" .. math.random(1000, 9999), true
end

FACTION_REPLICANT = FACTION.index