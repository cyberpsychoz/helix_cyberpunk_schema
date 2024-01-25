-- [[ CONFIGURATION OPTIONS ]] --

ix.config.Add("startingAttributePoints", 15, "Начальное количество очков атрибутов, имеющихся у персонажа при создании.", nil, {
	data = { min = 0, max = 30 },
	category = "characters"
})

ix.config.Add("startingSkillPoints", 25, "Начальное количество очков навыков, имеющихся у персонажа при создании.", nil, {
	data = { min = 0, max = 100 },
	category = "characters"
})

ix.config.Add("startingTraits", 2, "Начальное количество очков черт, имеющихся у персонажа при создании.", nil, {
	data = { min = 0, max = 10 },
	category = "characters"
})

ix.config.Add("maxAttributes", 20, "Максимальное количество очков, которое может иметь атрибут по умолчанию.", nil, {
	data = {min = 0, max = 100},
	category = "characters"
})

ix.config.Add("maxSkills", 100, "Максимальное количество очков, которое может иметь навык по умолчанию.", nil, {
	data = { min = 0, max = 100 },
	category = "characters"
})