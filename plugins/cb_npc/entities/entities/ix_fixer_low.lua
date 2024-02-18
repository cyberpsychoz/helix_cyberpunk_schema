AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Фиксер шестёрка"
ENT.Category = "Cyberpunk RED NPC"
ENT.Spawnable = true
ENT.AdminOnly = true
--ENT.bNoPersist = true
ENT.Armor = 3
ENT.Evasion = 20
ENT.HitChance = 25
ENT.HitPenetration = 3
ENT.Damage = 35

if SERVER then

    --[[
    function ENT:PlayWaveAnimationOnce()
        -- Установка анимации "Wave" и воспроизведение ее один раз
        self:ResetSequence("wave")
        self:SetPlaybackRate(1)
    
        -- Установка таймера для сброса анимации после ее окончания
        local animDuration = self:SequenceDuration()
        timer.Simple(animDuration, function()
            if IsValid(self) then
                -- Добавьте небольшую задержку перед сбросом анимации
                timer.Simple(0.1, function()
                    if IsValid(self) then
                        self:ResetSequence("idle")
                        self:SetPlaybackRate(1)
                    end
                end)
            end
        end)
    end    
    ]]
    --[[
    local schedule = ai_schedule.New("MySchedule")

    schedule:EngTask("TASK_TARGET_PLAYER", 0)
    schedule:EngTask("TASK_MOVE_TO_TARGET_RANGE", 60)
    schedule:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)

    function ENT:SelectSchedule()
        self:StartSchedule(schedule)
    end
    ]]

    util.AddNetworkString("UnfreezePlayer") -- Разморозка
    util.AddNetworkString("OpenDialoguePanel_fixer_low")

    net.Receive("UnfreezePlayer", function(len, ply)
        if IsValid(ply) then
            ply:Freeze(false)
        end
    end)

    local models = {
        "models/barnes/refugee/male_80.mdl",
        "models/humans/group03m/male_123.mdl",
        "models/humans/group03m/male_125.mdl",
        "models/humans/group03m/female_76.mdl",
        "models/humans/group03m/female_77.mdl",
        "models/humans/group03m/female_58.mdl",
    }

    local voices = {
        "cyberpunksounds/npc/voices/male_standard_1.ogg",
        "cyberpunksounds/npc/voices/male_standard_2.ogg",
        "cyberpunksounds/npc/voices/male_standard_3.ogg",
        "cyberpunksounds/npc/voices/male_standard_4.ogg",
        "cyberpunksounds/npc/voices/female_standard_1.ogg",
        "cyberpunksounds/npc/voices/female_standard_2.ogg",
        "cyberpunksounds/npc/voices/female_standard_3.ogg",
        "cyberpunksounds/npc/voices/female_standard_4.ogg"
    }

    local cooldownTime = 15
    local nextInteractionTime = CurTime()
    local isFollowing = false

    function ENT:Initialize()
        local randomModel = math.random(1, #models)
        self.randomVoice = voices[math.random(1, #voices)]
        self:SetModel(models[randomModel])
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()

        self:SetNPCState(NPC_STATE_IDLE)
        self:SetSolid(SOLID_BBOX)
        self:DropToFloor()

        self:SetHealth(200)
        --self:CapabilitiesAdd(CAP_MOVE_GROUND)

        self:SetMoveType(MOVETYPE_NONE)
        self:SetSchedule(SCHED_FORCED_GO_RUN)
        
        self:SetUseType(SIMPLE_USE)
        --self:CapabilitiesAdd(CAP_OPEN_DOORS)
        self:CapabilitiesAdd(CAP_ANIMATEDFACE)
        self:CapabilitiesAdd(CAP_TURN_HEAD)
        self:CapabilitiesAdd(CAP_USE)

        -- Установка таймера для воспроизведения анимации "Wave" каждые 25 секунд
        --timer.Create("WaveAnimationTimer", 5, 0, function()
        --    if IsValid(self) then
        --        self:PlayWaveAnimationOnce()
        --    end
        --end)
    end

    function ENT:Use(activator, client)
        if CurTime() < nextInteractionTime then
            
            return
        end

        local phrasesBad = {
            "Ты не похож на фиксера, нам не о чем с тобой говорить.",
            "Проваливай отсюда. Я не хочу говорить с тобой.",
            "Проваливай, пока цел. Ты не похож на моих корешей.",
            "Я буду говорить только с фиксером, ты же больше похож на уличного оборванца.",
            "Еще один ублюдошный наркоша решил доебаться до меня. Уйди с моей дороги, урод.",
            "Ты не из наших, дружок. Иди своей дорогой.",
            "Я не знаю тебя, чувак. Мы не имеем общих дел.",
            "Тебе лучше найти себе другую компанию, приятель.",  
            "Не приближайся ко мне, парень. У нас разные цели.",
            "Слушай, я тебя не знаю.",
            "Ничем не могу помочь, дружище. Я работаю только со своими.",
            "Ты явно не из нашего круга, чувак. Держись от меня подальше.",
            "У меня нет дел с посторонними, не обижайся. Просто иди мимо.",
            "Давай не будем общаться, ладно? У тебя свои дела, у меня свои.",
            "Не хочу с тобой разговаривать, незнакомец. Ничего личного.",
            "У тебя другая специализация, приятель. Мы не напарники.",
            "Найди себе другого собеседника. Моя беседа не для тебя.",
            "Не видишь, я занят? Иди своей дорогой, парень.",
            "Нет ничего общего между нами, чел. Ищи компанию поинтереснее.",
            "Не сейчас, чувак. У меня дел по горло. Шагай отсюда.",
            "Мы чужие друг другу, незнакомец. Нам не о чем трепаться.",
            "Мои дела тебя не касаются. Свали и не доставай меня.",
            "У тебя нет со мной общих интересов, ясно? Проваливай.",
            "Ищи себе другого собеседника, парень. Ты мне не компания.",
            "С такими как ты я не вожусь, ясно? Вали отсюда по-хорошему.",
            "Не чумба ты мне, гнида репликантская."
        }

        local character = client:GetCharacter()
        if character then
            --local cha = character:GetAttribute("cha", 0)
            local rit = character:GetSkill("ritorics", 0)
            --local int = character:GetAttribute("int", 0)
            local backstory = character:GetBackground()

            --print("Харизма: " .. cha, "Риторика: " .. rit, "Интеллект: " .. int)

            if backstory == "Фиксер" then
                -- Разворот поворот
                local direction = (client:GetPos() - self:GetPos()):GetNormalized()
                self:SetAngles(direction:Angle())

                --client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный торг...] говорит: \"Глянь на мои товары!\"")]]))
                net.Start("OpenDialoguePanel_fixer_low")
                net.WriteString(self.randomVoice)
                net.Send(client) -- ОТПРАВКА НА КЛИЕНТ
                client:Freeze(true) -- ЗАМОРОЗКА

                --self:CapabilitiesRemove(CAP_MOVE_GROUND)
            else
                local randomBad = math.random(1, #phrasesBad)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Стильно одетый чел...] говорит: \"%s\"")]], phrasesBad[randomBad]))

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
            local damage = math.random(1, self.Damage )

            if character then
                if hitChance > evasion then
                    if self.HitPenetration > armorclass then
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                                ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Стильно одетый чел...] атакует в ответ %s нанося ему %s урона.")]], target:GetName(), damage))
                            end
                        end
                        target:TakeDamage(damage)
                    else
                        for _, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                                ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Стильно одетый чел...] атакует в ответ %s, но пуля рикошетит.")]], target:GetName()))
                            end 
                        end
                    end
                else
                    for _, ply in ipairs(player.GetAll()) do
                        if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                            ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "**[Стильно одетый чел...] атакует в ответ %s и промахивается.")]], target:GetName())) 
                        end
                    end
                end
            end
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        local attacker = dmginfo:GetAttacker()
        local damage = dmginfo:GetDamage()
        --print(damage)
    
        self:AttackPlayer(attacker)
        self:SetHealth(self:Health() - damage)
        local phrases = {
            "Блядский рот!",
            "Ты даже не представляешь какие у меня связи, уебок!",
            "Я тебя урою, уж поверь мне гандон!",
            "А-а-а... Ай блять... Прямо в мизинчик...",
            "Если бы твоя мать была рядом, я бы ее ногами хуярил!",
            "Из какой пизды ты вылез мудак? Ай сука...",
            "Аргх... Пора заканчивать с этим...",
            "Я тебе башку оторву и в шею насру!",
            "Б-блять... Мх... Тебя твоя мамаша стрелять учила?",
            "Ебаные бустеры блять я живьем не дамся!"
        }
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                if math.random(0, 100) <= 35 then
                    local randomIndex = math.random(1, #phrases)
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Стильно одетый чел...] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Стильно одетый чел...] падает на пол без малейшего признака жизни.")]])
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

    net.Receive("OpenDialoguePanel_fixer_low", function(len)

        local randomVoice = net.ReadString()
        local ply = LocalPlayer()
        local character = ply:GetCharacter()

        --print("TEST WINDOW DIALOGUE | Ply: ", ply)
        if IsValid(ply) and ply:IsPlayer() then
            gui.EnableScreenClicker(true)
            --print("SUCCESS WINDOW DIALOGUE")
            local frame = vgui.Create("DFrame")
            frame:SetSize(600, 200) -- Увеличиваем размер окна
            frame:SetPos(ScrW() / 2 - 300, ScrH() / 2 + 300) -- Центрируем окно
            frame:SetTitle("")
            frame:ShowCloseButton(false)
            frame:SetDraggable(false)
            frame:SetMouseInputEnabled(true)
            frame.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 200))
            end

            local button1 = vgui.Create("DButton", frame)
            button1:SetText("Купить генетические карты [45.000 ED]")
            button1:SetSize(200, 40)
            button1:SetWidth(600)
            button1:SetTextColor(Color(131, 131, 131))
            button1:SetPos(frame:GetWide() / 2 - button1:GetWide() / 2, 20)
            --button1:SetFont("TTSupermolotNeue-Medium")
            button1.Paint = function(self, w, h)
                -- Убираем окантовку у кнопки
            end
            button1.DoClick = function()
                DisplayText("Пока нет в наличии брат.", randomVoice)
            end
    
            local button2 = vgui.Create("DButton", frame)
            button2:SetText("Разузнать что происходит в округе [Риторика 40]")
            button2:SetSize(200, 40)
            button2:SetWidth(600)
            button2:SetTextColor(Color(255, 165, 0))
            button2:SetPos(frame:GetWide() / 2 - button2:GetWide() / 2, 80)
            --button2:SetFont("TTSupermolotNeue-Medium")
            button2.Paint = function(self, w, h)
                -- Убираем окантовку у кнопки
            end
            button2.DoClick = function()
                local ritorics = character:GetSkill("ritorics", 0)
            
                if ritorics >= 40 then
                    -- Создаем новую панель
                    local frame = vgui.Create("DFrame")
                    frame:SetSize(600, 300)
                    frame:Center()
                    frame:SetTitle("Данные об оболочках Mega-Teck")
                    frame:MakePopup()
            
                    -- Создаем список
                    local list = vgui.Create("DListView", frame)
                    list:Dock(FILL)
                    list:AddColumn("Оболочка ")
                    list:AddColumn("Состояние ")
                    list:AddColumn("Макс. стаб. сост.")
                    list:AddColumn("Класс брони")
                    list:AddColumn("Вид оболочки")
                    list:AddColumn("Принадлежность")

            
                    -- Заполняем список информацией об игроках
                    for _, ply in ipairs(player.GetAll()) do
                        local character = ply:GetCharacter()

                        list:AddLine(ply:Nick(), ply:Health(), ply:GetMaxHealth(), character:GetData("armorclass", "Нет."), character:GetFaction(), character:GetData("affiliation", "Нет."))
                    end
            
                    DisplayText("Свежая инфа, для моего братишки...", randomVoice)
                else
                    DisplayText("Не, брат, ничё не знаю...", randomVoice)
                end
            end
            
    
            local button3 = vgui.Create("DButton", frame)
            button3:SetText("Уйти")
            button3:SetSize(200, 40)
            button3:SetPos(frame:GetWide() / 2 - button3:GetWide() / 2, 140) -- Размещаем кнопку ниже второй кнопки
            --button3:SetFont("TTSupermolotNeue-Medium")
            button3.Paint = function(self, w, h)
                -- Убираем окантовку у кнопки
            end
            button3.DoClick = function()
                frame:Close()
                gui.EnableScreenClicker(false)
                RemoveDisplayText()
                net.Start("UnfreezePlayer")
                net.SendToServer()
            end
        end
    end)
    
    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("Фиксер")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Стильно одетый человек, сразу видно что фиксер. Возможно у него можно что-то разузнать или взять заказ.")
        description:SizeToContents()
    end
end

list.Set( "NPC", "ix_fixer_low", {
    Name = "Фиксер шестёрка",
    Class = "ix_fixer_low",
    Category = "Cyberpunk RED"
})