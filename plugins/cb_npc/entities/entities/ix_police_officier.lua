AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Офицер полиции"
ENT.Category = "Cyberpunk RED NPC"
ENT.Spawnable = true
ENT.AdminOnly = true
--ENT.bNoPersist = true
ENT.Armor = 0
ENT.Evasion = 10

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
    util.AddNetworkString("OpenDialoguePanel_citizen")
    util.AddNetworkString("UnfreezePlayer") -- Разморозка

    net.Receive("UnfreezePlayer", function(len, ply)
        if IsValid(ply) then
            ply:Freeze(false)
        end
    end)

    local models = {
        "models/humans/group01/male_77.mdl",
        "models/humans/group01/male_78.mdl",
        "models/humans/group01/male_80.mdl",
        "models/humans/group01/male_49.mdl",
        "models/cyberpunk/group01/female_13.mdl",
        "models/cyberpunk/group01/female_04.mdl",
        "models/humans/group01/male_127.mdl",
        --"mmodels/cyberpunk/group02/female_12.mdl",
        "models/barnes/refugee/female_77.mdl",
        "models/cyberpunk/group02/female_02.mdl",
        "models/cyberpunk/group01/female_09.mdl",
        "models/cyberpunk/group01/male_08.mdl",
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

        self:SetHealth(55)
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
            "Вам что-то нужно?",
            "Вы меня с кем-то путаете...",
            "Отойдите пожалуйста...",
            "Я не понимаю что вы хотите от меня...",
            "Да-да?"
        }

        local character = client:GetCharacter()
        if character then
            local cha = character:GetAttribute("cha", 0)
            local rit = character:GetSkill("ritorics", 0)
            local int = character:GetAttribute("int", 0)

            --print("Харизма: " .. cha, "Риторика: " .. rit, "Интеллект: " .. int)

            if int >= 1 and cha >= 5 then
                -- Разворот поворот
                local direction = (client:GetPos() - self:GetPos()):GetNormalized()
                self:SetAngles(direction:Angle())

                --client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный торг...] говорит: \"Глянь на мои товары!\"")]]))
                net.Start("OpenDialoguePanel_citizen")
                net.WriteString(self.randomVoice)
                net.Send(client) -- ОТПРАВКА НА КЛИЕНТ
                client:Freeze(true) -- ЗАМОРОЗКА

                --self:CapabilitiesRemove(CAP_MOVE_GROUND)
            else
                local randomBad = math.random(1, #phrasesBad)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Самый обыкновенный граж...] говорит: \"%s\"")]], phrasesBad[randomBad]))

                nextInteractionTime = CurTime() + cooldownTime
            end
        else
            print("Ошибка: персонаж не найден.")
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        local attacker = dmginfo:GetAttacker()
        local damage = dmginfo:GetDamage()
        --print(damage)
    
        self:SetHealth(self:Health() - damage)
        local phrases = {
            "Ой спасите, убивают!",
            "Нет! Уходи! Ай... Ай!",
            "Полиция! Полиция!",
            "Нет... Прошу...",
            "Я слишком молод чтобы умирать!",
            "Что ж за день такой, ай!",
            "Только не по лицу!",
            "А-а!... А!...",
            "Хватит, прошу! Хватит!",
            "Ай! Это будет долго заживать..."
        }
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                if math.random(0, 100) <= 35 then
                    local randomIndex = math.random(1, #phrases)
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Самый обыкновенный граж...] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Самый обыкновенный граж...] умирает в агонии, крича и умоляя о пощаде.")]])
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

    net.Receive("OpenDialoguePanel_citizen", function(len)

        local randomVoice = net.ReadString()
        local ply = LocalPlayer()
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
            button1:SetText("Говорить")
            button1:SetSize(200, 40) -- Увеличиваем размер кнопки
            button1:SetPos(frame:GetWide() / 2 - button1:GetWide() / 2, 20) -- Центрируем кнопку по горизонтали
            --button1:SetFont("TTSupermolotNeue-Medium") -- Устанавливаем шрифт
            button1.Paint = function(self, w, h)
                -- Убираем окантовку у кнопки
            end
            button1.DoClick = function()
                talkness = {
                    "Не отвлекайте меня по пустякам.",  
                    "Надеюсь с вашими документами все в порядке.",
                    "Да - да?",
                    "Слушаю вас внимательно. О чём вы хотели поговорить?",
                    "Я немного занят сейчас. Говорите быстрее.",
                    "У меня мало времени. Давайте к делу.",
                    "Хм, выглядите подозрительно. Есть документы при себе?",
                    "Не задерживайте меня надолго, у меня есть обязанности.",
                    "Говорите своё дело и идите с миром. Я занятой человек.",
                    "Да, к сожалению, преступность растёт. Мы стараемся, как можем.",
                    "Что вы хотели? Ситуация в городе не простая сейчас.",
                    "Вам стоило бы не выходить из дома лишний раз.",
                    "Понимаю вашу озабоченность положением дел. Мы работаем над этим.",
                    "Коррупция? Не верьте слухам. Полиция стоит на страже закона.",
                    "Нет, комментировать операции ГПМ я не имею права. Это закрытая информация.",
                    "Да, мы регулярно проводим рейды по третьему дистрикту. Стараемся навести порядок.",
                    "Не беспокойтесь, гражданин, район под нашим контролем. Можете чувствовать себя в безопасности.",
                    "К сожалению, мы не можем контролировать каждый уголок города. Нам не хватает людей.",
                    "Нет, я не имею права обсуждать нашу внутреннюю кадровую политику.",
                    "Рецедив? Где?"
                  }
                
                local randomsay = math.random(1, #talkness)

                DisplayText(talkness[randomsay], randomVoice)
            end
    
            local button2 = vgui.Create("DButton", frame)
            button2:SetText("Оформить контракт [Жетон ГПМ]")
            button2:SetSize(200, 40)
            button2:SetTextColor(Color(255, 165, 0))
            button2:SetPos(frame:GetWide() / 2 - button2:GetWide() / 2, 80) -- Размещаем кнопку ниже первой кнопки
            --button2:SetFont("TTSupermolotNeue-Medium")
            button2.Paint = function(self, w, h)
                -- Убираем окантовку у кнопки
            end
            button2.DoClick = function()
                local character = ply:GetCharacter()
                local ritorics = character:GetSkill("ritorics", 0)

                if ritorics >= 10 then
                    DisplayText("секс", randomVoice)
                else
                    DisplayText("Тебе нужно получить жетон ГПМ, в центральном управлении \nпрежде чем взяться за работу.", randomVoice)
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
        title:SetText("Неизвестный")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Самый обыкновенный гражданин Мондфилда, с виду непонятно репликант он или человек. Одет в повседневеную уличную одежду, выглядит не очень богато.")
        description:SizeToContents()
    end
end

list.Set( "NPC", "ix_police_officier", {
    Name = "Офицер полиции",
    Class = "ix_police_officier",
    Category = "Cyberpunk RED"
})