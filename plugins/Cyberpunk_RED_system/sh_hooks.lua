-- [[ HOOKS ]] --

function PLUGIN:GetMaximumAttributePoints()

	return ix.config.Get( "maxAttributes", 10 )

end

function PLUGIN:GetMaximumSkillPoints()

	return ix.config.Get( "maxSkills", 10 )

end

function PLUGIN:GetDefaultTraitPoints()

	return ix.config.Get( "maxTraits", 1 )

end

function PLUGIN:GetDefaultAttributePoints( client )

	return ix.config.Get( "startingAttributePoints", 10 )

end

function PLUGIN:GetDefaultSkillPoints( client )

	return ix.config.Get( "startingSkillPoints", 20 )

end

-- Таблица с сообщениями о смерти
local deathMessages = {
    "Персонаж %s умер.",
    "Персонаж %s больше не с нами.",
    "Персонаж %s покинул этот мир.",
    "Персонаж %s умер обоссавшись и обосравшись.",
    "Персонаж %s больше не вернется.",
    "%s впервые за долгое время посмотрел на небо...",
    "Дети, не берите шприцы с улицы, а то станете такими как %s.",
    "%s прожил хорошую жизнь.",
    "%s прожил ужасную жизнь.",
    "%s прожил счастливую жизнь.",
    "Сообщение для друзей %s, ПОРА МСТИТЬ!",
    "Нечего %s, в следующий раз получится.",
    "В сети начали всплывать фото мёртвого %s.",
    "%s теперь загадка для хирурга.",
    "%s скоропостижнулся.",
    "А %s надо было меньше играть в компьютер.",
    "Теперь %s знает, есть ли жизнь после смерти.",
    "Урод, который убил %s, тебе привет передают :)",
    "Урод, который убил %s, спасибо.",
    "Ну теперь %s импланты не понадобятся.",
    "В новостях говорят, что %s догрызают собаки.",
    "Вы слышите крик о помощи от %s, а, наверное, уже не важно.",
    "%s не успел оформить страховку на жизнь.",
    "Тело %s теперь не отличается от мусора в округе.",
    "%s стал ещё одной жертвой этого города.",
    "И какого хрена звонок в больничку платный? Тут %s сдох!",
    "А помогите, тут Блэкхенда убили, а не это просто %s.",
    "У бомжей сегодня будет хороший ужин, спасибо %s.",
    "Кто-нибудь видел %s? Он на звонки не отвечает... Может умер?",
}

function PLUGIN:PlayerDeath( victim, inflictor, attacker )
	local character = victim:GetCharacter()
	local bonus = character:GetAttribute("phy", 0) + character:GetAttribute("ref", 0)
	local total = bonus - character:GetAttribute("luck", 0)
	local roll = math.random(0, 10)
	local maxroll = math.random(0, 20) + total

	local receivers = {}

	for _, v in ipairs(player.GetAll()) do
		if v:IsAdmin() or v:IsSuperAdmin() then
			table.insert(receivers, v)
		end
	end

	ix.chat.Send(victim, "roll", (roll + bonus).." ( "..roll.." + "..bonus.." ) спасбросок", nil, receivers, { max = maxroll })

	-- Проверяем, превышает ли бросок maxroll
	if (roll + bonus) > maxroll then
		-- Сохраняем местоположение смерти
		local deathPos = victim:GetPos()
		print("ДЕБАГ ПОЗИЦИИ СМЕРТИ: " .. tostring(deathPos))
		-- Воскрешаем персонажа
		victim:SetNetVar("deathTime", CurTime() + .1)
		-- Создаем таймер с задержкой в 3 секунды
		timer.Simple(1.5, function()
			-- Проверяем, все ли еще в порядке с персонажем
			if IsValid(victim) then
				-- Перемещаем персонажа на место смерти
				victim:SetPos(deathPos)
			end
		end)
	else
		-- "Баним" персонажа
		character:Ban()
		--character:SetData()
		-- Выбираем случайное сообщение о смерти
		local message = deathMessages[math.random(#deathMessages)]
		for _, ply in ipairs(player.GetAll()) do
		    ply:ChatPrint(string.format("*" .. message .. "*", character:GetName()))
		end
	end
end

