AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Бустер шестёрка"
ENT.Category = "Cyberpunk RED NPC"
ENT.Spawnable = true
ENT.AdminOnly = true
--ENT.bNoPersist = true
ENT.Armor = 1
ENT.Evasion = 5
ENT.HitChance = 35
ENT.HitPenetration = 2
ENT.Damage = 20

if SERVER then

    local models = {
        "models/cyberpunk/mutants/mutant1.mdl",
        "models/cyberpunk/mutants/mutant2.mdl",
        "models/cyberpunk/mutants/mutant3.mdl",
        "models/thespireroleplay/humans/group009/male.mdl",
        "models/humans/group01/female_38.mdl",
        "models/humans/group01/male_32.mdl",
        "models/humans/group03/coalition_female.mdl",
        "models/humans/group03/coalition_male.mdl"
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

        self:SetHealth(75)
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
            "Я... А-ай бля-я!",
            "У меня есть доза, но только не для тебя!",
            "Пошел нахуй отсюда!",
            "Это моя территория, какого хуя ты тут шляешься?",
            "Ебучие сучки корпоратов, съебались отсюда!",
            "Съеби нахрен отсюда пока цел!",
            "Деньги или жизнь, уёбок. Быстро определяйся!",  
            "Ты чо, ко мне лезешь? Сh'wаhа оторву!",
            "Ща морду твою на куски порежу, еще раз сунешься!",
            "Завали ебало, пока не пристрелил тут же.",
            "У меня терпение на исходе, сучонок. Вали отсюда!",
            "Не суй свой нос куда не надо, ясно? А то плохо будет.",
            "Отвали и не выебывайся, петушок. Проходи мимо.",
            "Еще одно слово, и я вырву твой ебаный язык!",
            "Слышь, мудила, я тебе морду нахер разобью сейчас.",
            "Завались и не высовывайся, пока я добрый.",
            "Ты чо, охуел тут рот открывать? Закрой его нахуй.",
            "Вали отсюда пока цел, урод ёбаный.",
            "Не беси меня, сучёнок, а то херово будет.",
            "Я тебя на кусочки порежу и собакам скормлю, понял?",
            "Долго ещё пиздеть будешь? Отъебись, пока голова на плечах."
        }

        local character = client:GetCharacter()
        if character then
            local cha = character:GetSkill("ritorics", 0)
            if cha >= 5 then
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Среднестатистический бустер, отброс общес...] говорит: \"Здесь может быть небезопасно... Уходи отсюда...\"")]]))
                nextInteractionTime = CurTime() + cooldownTime
            else
                local randomBad = math.random(1, #phrasesBad)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Среднестатистический бустер, отброс общес...] говорит: \"%s\"")]], phrasesBad[randomBad]))

                nextInteractionTime = CurTime() + cooldownTime
            end
        else
            print("Ошибка: персонаж не найден.")
        end
    end

    function ENT:AttackPlayer(target)
        if target:IsValid() and target:GetClass() == "player" then
            
            local character = target:GetCharacter()
            local evasion = character:GetSkill("evasion", 0)
            local armorclass = character:GetData("armorclass", 0)

            --print("Класс брони: ", armorclass)
            --print("Уклонение: ", evasion)

            local hitChance = math.random(1, self.HitChance)
            local damage = math.random(3, self.Damage )

            if character then
                if hitChance > evasion then
                    if self.HitPenetration > armorclass then
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                                ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Среднестатистический бустер, отброс общес...] атакует в ответ %s нанося ему %s урона.")]], target:GetName(), damage))
                            end
                        end
                        target:TakeDamage(damage)
                    else
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                                ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Среднестатистический бустер, отброс общес...] атакует в ответ %s, но пуля рикошетит.")]], target:GetName()))
                            end 
                        end
                    end
                else
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                            ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Среднестатистический бустер, отброс общес...] атакует в ответ %s и промахивается.")]], target:GetName())) 
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
            "ТВАРЬ! ТЫ НЕ ПРЕДСТАВЛЯЕШЬ ЧТО ТЕБЕ ЗА ЭТО БУДЕТ!",
            "НАХУЙ НАХУЙ НАХУЙ! БЛЯТЬ, БЛЯТЬ, БЛЯТЬ!",
            "КОРПОРАТИВНЫЕ ВЫБЛЯДКИ!",
            "А-А-А-А! А-а-а! А-а-а-а-а...",
            "Я НЕ СДОХНУ ВОТ ТАК!",
            "Аргх... Мх-х... С-суки...",
            "И это... Арх... И это все что ты можешь?!",
            "А-а!... А!...",
            "Ладно, я сдаюсь! Хватит! Хватит!",
            "Сука! Да за что?!"
        }
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                if math.random(0, 100) <= 35 then
                    local randomIndex = math.random(1, #phrases)
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Среднестатистический бустер, отброс общес...] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Среднестатистический бустер, отброс общес...] всхлипывает, корчась от боли в предсмертных конвульсиях и истекая кровью.")]])
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
                "paracetamol",
                "paracetamol",
                "paracetamol",
                "paracetamol",
                "polimerpistol",
                "meth"
            }

            local randomItemIndex = math.random(1, #itemTableList)
            local randomItemID = itemTableList[randomItemIndex]
            local itemTable = ix.item.list[randomItemID]
            local randomchance = math.random(0, 10)
            if itemTable then
                if randomchance > 7 then
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
        title:SetText("Бустер - шестёрка")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Среднестатистический бустер, отброс общества, одет как попало, склыдвается ощущение что он под кайфом. Навряд-ли он сможет дать отпор.")
        description:SizeToContents()
    end
end

list.Set( "NPC", "ix_booster_low", {
    Name = "Бустер шестёрка",
    Class = "ix_booster_low",
    Category = "Cyberpunk RED"
})