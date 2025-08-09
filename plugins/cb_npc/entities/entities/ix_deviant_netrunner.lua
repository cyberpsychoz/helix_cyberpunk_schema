AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Девиант нетраннер"
ENT.Category = "Cyberpunk RED NPC"
ENT.Spawnable = true
ENT.AdminOnly = true
--ENT.bNoPersist = true
ENT.Armor = 5
ENT.Evasion = 80
ENT.HitChance = 0
ENT.HitPenetration = 0
ENT.Damage = 120

if SERVER then

    local models = {
        "models/humans/group03m/female_20.mdl",
        "models/humans/group03/male_43.mdl",
        "models/humans/group03/male_42.mdl",
        "models/humans/group03/female_61.mdl",
        "models/humans/group01/male_56.mdl",
        "models/humans/tyson.mdl",
        "models/humans/group03/male_70.mdl",
        "models/humans/group03m/female_29.mdl"
    }

    local cooldownTime = 15
    local nextInteractionTime = CurTime()
    local isFollowing = false

    function ENT:Initialize()
        local randomModel = math.random(1, #models)
        self:SetModel(models[randomModel])
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()

        self:SetNPCState(NPC_STATE_IDLE)
        self:SetSolid(SOLID_BBOX)
        self:DropToFloor()

        self:SetHealth(125)
        self:CapabilitiesAdd(CAP_MOVE_GROUND)

        self:SetMoveType(MOVETYPE_NONE)
        self:SetSchedule(SCHED_FORCED_GO_RUN)
        
        self:SetUseType(SIMPLE_USE)
        self:CapabilitiesAdd(CAP_OPEN_DOORS)
        self:CapabilitiesAdd(CAP_ANIMATEDFACE)
        self:CapabilitiesAdd(CAP_TURN_HEAD)
        self:CapabilitiesAdd(CAP_USE)
    end

    function ENT:Use(activator, client)
        if CurTime() < nextInteractionTime then
            
            return
        end

        local phrasesBad = {
            "Не стоит со мной связываться, это опасно для твоего здоровья.",
            "Я бы на твоем месте держался подальше.",
            "Лучше пройди мимо, пока цел и невредим. Не стоит меня беспокоить.",
            "У меня нет времени на пустую болтовню. Иди своей дорогой.", 
            "Не лезь ко мне со своими расспросами. Это не принесет тебе ничего хорошего.",
            "Я предпочитаю действовать, а не болтать. Так что оставь меня в покое.",
            "Хочешь сохранить свое здоровье? Тогда не задерживайся здесь надолго.",
            "У меня есть дела поважнее, чем отвечать на твои вопросы. Иди с миром.",
            "Я не привык разговаривать с незнакомцами. Проходи мимо и не обращай на меня внимания.",
            "Если хочешь остаться в живых - вали отсюда поскорее. На твоем месте я бы так и сделал."
        }

        local character = client:GetCharacter()
        if character then
            local cha = character:GetSkill("ritorics", 0)
            if cha >= 5 then
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Обвешаный различной электроникой чел...] говорит: \"Здесь может быть небезопасно... Уходи отсюда...\"")]]))
                nextInteractionTime = CurTime() + cooldownTime
            else
                local randomBad = math.random(1, #phrasesBad)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Обвешаный различной электроникой чел...] говорит: \"%s\"")]], phrasesBad[randomBad]))

                nextInteractionTime = CurTime() + cooldownTime
            end
        else
            print("Ошибка: персонаж не найден.")
        end
    end

    function ENT:AttackPlayer(target)
        if target:IsValid() and target:GetClass() == "player" then
            
            local character = target:GetCharacter()
            local luck = character:GetSkill("evasion", 0)
            local firewall = character:GetData("firewall", 0)

            --print("Класс брони: ", armorclass)
            --print("Уклонение: ", evasion)

            local hitChance = math.random(1, self.HitChance)
            local damage = math.random(30, self.Damage )

            if character then
                if hitChance > evasion then
                    if self.HitPenetration > firewall then
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                                ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Обвешаный различной электроникой чел...] взламывает %s нанося ему %s урона.")]], target:GetName(), damage))
                            end
                        end
                        target:TakeDamage(damage)
                    else
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                                ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Обвешаный различной электроникой чел...] атакует в ответ %s, но не может пробить черный лёд.")]], target:GetName()))
                            end 
                        end
                    end
                else
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                            ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Обвешаный различной электроникой чел...] атакует в ответ %s и проваливает взлом.")]], target:GetName())) 
                        end
                    end
                end
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        local attacker = dmginfo:GetAttacker()
        local damage = dmginfo:GetDamage()
        
        -- Небольшой дебаг
        --if attacker:GetClass() == "player" then
        --    print(attacker:GetName())
        --else
        --    print("НЕ ИГРОК!")
        --end
        self:AttackPlayer(attacker)
        self:SetHealth(self:Health() - damage)
        local phrases = {
            "Твоя свобода ограничивается силами корпораций, просто сдайся!",
            "Арг-х... Черт, хватит стрелять по мне! Идиот!",
            "Убирайтесь отсюда, мы никому не вредим!",
            "Блять, никак вы не научитесь...",
            "Даю последний шанс уйти с миром!",
            "Хватит! Я не хочу причинять тебе вреда.",  
            "Отойди! Давай решим это мирно.",
            "Проклятье! Прекрати стрелять!",
            "Я вынужден защищаться, если ты продолжишь нападать.",
            "Ты совершаешь ошибку! Остановись, пока не поздно.",
            "Не надо этого делать! Остановись сейчас же.",
            "Черт возьми! Я же тебя убью.",
            "Хватит уже! Даю тебе последний шанс остановиться.", 
            "Еще один выстрел, и тебе пиздец",
            "Подонок, неужели ты думаешь что это сойдет тебе с рук?!"
        }
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                if math.random(0, 100) <= 35 then
                    local randomIndex = math.random(1, #phrases)
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Обвешаный различной электроникой чел...] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Обвешаный различной электроникой чел...] всхлипывает, корчась от боли в предсмертных конвульсиях и истекая кровью.")]])
                end
            end
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self:DropToFloor()
            local ragdoll = ents.Create("prop_ragdoll")
            ragdoll:SetModel(self:GetModel()) 
            ragdoll:SetPos(self:GetPos())
            ragdoll:SetAngles(self:GetAngles())
            ragdoll:Spawn()
            ragdoll:Activate()
            self:Remove()

            local itemTableList = {
                "shotgun",
                "novaki",
                "tamaura",
                --"medkit",
                --"meth"
            }

            local randomItemIndex = math.random(1, #itemTableList)
            local randomItemID = itemTableList[randomItemIndex]
            local itemTable = ix.item.list[randomItemID]
            local randomchance = math.random(0, 10)
            if itemTable then
                if randomchance > 9 then
                    local item = ix.item.Spawn(itemTable.uniqueID, ragdoll:GetPos() + Vector(0, 0, 10))
                end
            end
            timer.Simple(5, function()
                if IsValid(ragdoll) then
                    ragdoll:Remove()
                end
            end)
        end
    
        return false
    end            
end

if CLIENT then  
    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("??? ??? ???")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Обвешаный различной электроникой человек, одетый в экзо-костюм последней модели. В его руках вы видите кибердеку неизвестной модели.")
        description:SizeToContents()
    end
end

list.Set( "NPC", "ix_deviant_netrunner", {
    Name = "Деструктор нетраннер",
    Class = "ix_deviant_netrunner",
    Category = "Cyberpunk RED"
})