ITEM.name = "Полимерник"
ITEM.description = "Собранный на коленке пистолет, выглядит так же ужасно как и стреляет."
ITEM.model = "models/cyberpunk/weapons/w_pistol.mdl"
ITEM.category = "CyberWeapons"
ITEM.flag = "V"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 200

ITEM.weaponSkill = "pistols" -- уровень навыка можно получить командой GetSkill(), их значение должно прибавляться к броску
ITEM.weaponDestination = 60000 -- расстояние на котрое будет пускаться луч, если он достает до цели, то будет попадание, если нет, то будет промах 
ITEM.weaponEffect = nil -- если эффект стоит nil, то оружие не накладывает никакого эффекта на игрока
ITEM.weaponPenetration = 1 -- максимальный класс брони, которую может пробить оружие, можно проверить через GetData(armorclass)
ITEM.weaponDamage = 8

-- ITEM.rollDamage = "1d" .. weaponSkill -- влияет на урон