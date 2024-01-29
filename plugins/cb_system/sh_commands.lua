-- [[ COMMANDS ]] --


--[[
	COMMAND: /Roll
	DESCRIPTION: Allows the player to roll an arbitrary amount of dice and apply bonuses as needed.
]]--

ix.command.Add("Roll", {
	syntax = "<бросок кубика (1d6 например)>",
	description = "Вычисляет бросок кости (например, 2d6 + 2) и показывает результат.",
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, rolltext)
		result, rolltext = ix.dice.Roll( rolltext, client )

		ix.chat.Send( client, "rollgeneric", tostring( result ), nil, nil,{
			roll = "( "..rolltext.." )"
		} )
	end
})

--[[
	COMMAND: /RollStat
	DESCRIPTION: Rolls a d20 and applies modifiers to the dice roll for the stat provided.
]]--

ix.command.Add("RollStat", {
	syntax = "<атрибут>",
	description = "Запускает и добавляет бонус за предоставленное состояние.",
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, stat)
		local character = client:GetCharacter()
		local statname
		local bonus = 0

		for k, v in pairs(ix.attributes.list) do
			if ix.util.StringMatches(k, stat) or ix.util.StringMatches(v.name, stat) then
				stat = k
				statname = v.name
				bonus = character:GetAttribute(stat, 0)
			end
		end

		if not (statname) then
			for k, v in pairs(ix.skills.list) do
				if ix.util.StringMatches(k, stat) or ix.util.StringMatches(v.name, stat) then
					stat = k
					statname = v.name
					bonus = character:GetSkill(stat, 0)
				end
			end
		end

		if not statname then client:Notify( "Предоставленное состояние является недействительным." ) return end

		if (character and character:GetAttribute(stat, 0)) then
			local roll = tostring(math.random(1, 20))

			ix.chat.Send(client, "roll20", (roll + bonus).." ( "..roll.." + "..bonus.." )", nil, nil, {
				rolltype = statname
			})
		end
	end
})

--[[
	COMMAND: /RollAttack
	DESCRIPTION: Automatically makes an attack roll based on the weapon that the player is holding.

ix.command.Add("RollAttack", {
	syntax = nil,
	description = "Выполняет бросок атаки и добавляет любые модификаторы.",
	arguments = nil,
	OnRun = function(self, client, stat)
		local critcolor = Color( 255, 30, 30 )
		local character = client:GetCharacter()
		local weapon = client:GetActiveWeapon()
		if IsValid(weapon) and weapon.ixItem then
			local statTable = weapon.ixItem.HRPGStats or weapon.HRPGStats

			if (character and statTable) then
				local bonus = character:GetAttribute( statTable.mainAttribute, 0 )
				local roll = math.random(1, 20)
				local dmg = calcDice( statTable.rollDamage )

				local chatdata = {
					damage = dmg,
					color = nil
				}

				if ( roll == 20 ) then 
					chatdata.damage = dmg * 2
					chatdata.color = critcolor 
				end

				ix.chat.Send(client, "roll20attack", (roll + bonus).." ( "..roll.." + "..bonus.." )", nil, nil, chatdata)
			end
		else
		    client:Notify("У вас нет подходящего оружия.")
		end
	end
})
]]--

-- Функция для расчета броска кубика с учетом формата "XdY"
function calcDice(diceFormat)
    local numDice, numSides = string.match(diceFormat, "(%d+)d(%d+)")
    numDice = tonumber(numDice) or 1
    numSides = tonumber(numSides) or 6

    local result = 0
    for i = 1, numDice do
        result = result + math.random(1, numSides)
    end

    return result
end

ix.command.Add("GetSkill", {
	syntax = "<skill>",
	description = "Получает навык.",
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, skill)
		--[[for k, v in pairs( ix.skills.list ) do
			print(k)
			print(v)
		end]]
		char = client:GetCharacter()

		skilltab = char:GetAttributes()

		if ( table.IsEmpty(skilltab) ) then
			print( "Таблица умений пуста!")
		else
			for k, v in pairs( skilltab ) do 
				print(k)
				print(v)
			end
		end
	end
})

if SERVER then
	util.AddNetworkString( "ixTestDerma" )
else
	net.Receive( "ixTestDerma", function()
		local frame = vgui.Create( "DFrame" )
		frame:SetPos( 500, 500 )
		frame:SetSize( 200, 300 )
		frame:SetTitle( "Frame" )
		frame:MakePopup()
		 
		local grid = vgui.Create( "DGrid", frame )
		grid:SetPos( 10, 30 )
		grid:SetCols( 5 )
		grid:SetColWide( 36 )
		 
		for i = 1, 30 do
			local but = vgui.Create( "DButton" )
			but:SetText( i )
			but:SetSize( 30, 20 )
			grid:AddItem( but )
		end
	end)
end

ix.command.Add("DermaTest", {
	syntax = "",
    adminOnly = true,
	description = "Tests Derma",
	OnRun = function(self, client, skill)
		net.Start( "ixTestDerma" )
		net.Send(client)
	end
})

--Команда дебага
ix.command.Add("Implants", {
	adminOnly = true,
    syntax = "<имя персонажа>",
    description = "Показывает информацию об экипированных имплантах",
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        local character = target:GetCharacter()
        if character then
            local implantsData = character:GetData("implants", {})
            print("=== ДЕБАГ ИМПЛАНТОВ ===")
            -- Проверяем, есть ли у персонажа установленные импланты
            if table.IsEmpty(implantsData) then
                print("У игрока не обнаружено установленных имплантов у " .. character:GetName() .. ".")
            else
                -- Выводим информацию об установленных имплантах
                for bodypart, implantInfo in pairs(implantsData) do
                    if type(implantInfo) == "table" then
                        print(bodypart .. ": " .. implantInfo[1] .. " - " .. implantInfo[2] .. " для характеристики " .. implantInfo[3])
                    else
                        print("Некорректные данные об импланте: " .. tostring(implantInfo))
                    end
                end
            end
        else
            print("Персонаж с таким именем не найден.")
        end
    end
})

ix.command.Add("extremeImplants", {
	adminOnly = true,
    syntax = "<имя персонажа>",
    description = "Показывает информацию об экипированных имплантах",
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        local character = target:GetCharacter()
        if character then
            local implantsData = character:GetData("implants", {})
            print("=== ЭКСТРЕМАЛЬНЫЙ ДЕБАГ ИМПЛАНТОВ ===")
            -- Проверяем, есть ли у персонажа установленные импланты
            if table.IsEmpty(implantsData) then
                print("У игрока не обнаружено установленных имплантов у " .. character:GetName() .. ".")
            else
                PrintTable(implantsData)  
            end
        else
            print("Персонаж с таким именем не найден.")
        end
    end
})

ix.command.Add("removeImplants", {
	adminOnly = true,
	syntax = "<имя персонажа>",
    description = "Удаляет все импланты у персонажа",
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        local character = target:GetCharacter()
        if character then
            local implantsData = character:GetData("implants", {})
            if table.IsEmpty(implantsData) then
                print("У игрока не обнаружено установленных имплантов у " .. character:GetName() .. ".")
            else
                -- Удаляем все импланты
                for bodypart, implantInfo in pairs(implantsData) do
                    local boostname = implantInfo[3]
                    local boostbonus = implantInfo[2]
                    local skillname = implantInfo[5]
                    local skillbonus = implantInfo[4]
                    local currentAttr = character:GetAttribute(boostname, 0)
                    character:SetAttrib(boostname, currentAttr - boostbonus)
                    local currentSkill = character:GetSkill(skillname, 0)
                    character:SetSkill(skillname, currentSkill - skillbonus)
                end
                -- Очищаем данные об имплантах
                character:SetData("implants", {})
                print("Все импланты были удалены у " .. character:GetName() .. ".")
            end
        else
            print("Персонаж с таким именем не найден.")
        end
    end
})

ix.command.Add("extremeRemoveImplants", {
	adminOnly = true,
	syntax = "<имя персонажа>",
    description = "Экстренно очищает таблицу имплантов! (ИСПОЛЬЗОВАТЬ ТОЛЬКО В КРАЙНЕМ СЛУЧАЕ)",
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        local character = target:GetCharacter()
        character:SetData("implants", {})
    end
})

ix.command.Add("tpDeathPos", {
	adminOnly = true,
    description = "Телепоритрует на место смерти: ДЕБАГ",
    OnRun = function(self, client)
    	client:SetPos(Vector(-1654.919800, 739.729248, -141.836304))
    end
})

ix.command.Add("characterData", {
	adminOnly = true,
    syntax = "<имя персонажа>",
    description = "Показывает информацию об персонаже в консоль.",
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        local character = target:GetCharacter()
        if character then
        	print("=== ДАННЫЕ ПЕРСОНАЖА ===")
            PrintTable(character)  
        else
            print("Персонаж с таким именем не найден.")
        end
    end
})

ix.command.Add("CharGetArmor", {
	adminOnly = true,
    syntax = "<имя персонажа>",
    description = "Показывает информацию об классе брони персонажа.",
    arguments = {ix.type.player},
    OnRun = function(self, client, target)
        local character = target:GetCharacter()
        if character then
            local armorData = character:GetData("armorclass", "None")
            print("=== ЭКСТРЕМАЛЬНЫЙ ДЕБАГ БРОНИ ===")
            -- Проверяем, есть ли у персонажа установленные импланты
            --if armorData then
            --    print("Бронежилет отсутствует у " .. character:GetName() .. ".")
            --else
                print(armorData)
            --end
        else
            print("Персонаж с таким именем не найден.")
        end
    end
})

ix.command.Add("CharSetArmor", {
    adminOnly = true,
    syntax = "<имя персонажа> <класс брони>",
    description = "Устанавливает класс брони для персонажа",
    arguments = {ix.type.player, ix.type.string},
    OnRun = function(self, client, target, armorClass)
        local character = target:GetCharacter()
        if character then
            character:SetData("armorclass", armorClass)
            client:Notify("Класс брони установлен на " .. armorClass .. " для " .. target:Name())
        else
            client:Notify("Персонаж с таким именем не найден.")
        end
    end
})

ix.command.Add("CharSetSkill", {
    description = "Установить значение скилла игрока",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.string , ix.type.number},
    OnRun = function(self, client, target, skillName, skillValue)
        if (IsValid(target) and target:GetCharacter()) then
            target:GetCharacter():SetSkill(skillName, skillValue)
            client:Notify("Значение скилла" .. skillName .. " установлено на " .. skillValue .. " для " .. target:Name())
        end
    end
})

--Дебаг ХП
ix.command.Add("hp", {
    adminOnly = true,
    description = "Показывает максимальное и текущее количество HP игрока.",
    OnRun = function(self, client)
        local maxHP = client:GetMaxHealth()
        local currentHP = client:Health()
        client:PrintMessage(HUD_PRINTTALK, "Ваше максимальное количество HP: " .. maxHP)
        client:PrintMessage(HUD_PRINTTALK, "Ваше текущее количество HP: " .. currentHP)
    end
})


--[[
concommand.Add("trace_test", function(ply)
    local target = ply:GetCharacter():GetData("target", ent)
    local targetPos = target:GetPos()
    local plyPos = ply:GetPos()
    local direction = (targetPos - plyPos):GetNormalized()

    local trace = util.TraceHull({
        start = plyPos,
        endpos = plyPos + direction * weaponRange,
        filter = ply,
        mask = MASK_SHOT_HULL
        mins = Vector(-10, -10, -10), -- Размеры "коробки" для трассировки
        maxs = Vector(10, 10, 10)
    })



end)
]]