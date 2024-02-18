AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Уличный медик"
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
    util.AddNetworkString("OpenDialoguePanel_Medic")

    local models = {
        "models/humans/group03m/male_95.mdl",
        "models/humans/group03m/female_27.mdl",
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
            "Ты меня не видел...",
            "Я не буду тебе ничего продавать...",
            "Пожалуйста, отстань от меня...",
            "Убери свои руки!",
            "Нет, я это не продаю, только показываю..."
        }

        local character = client:GetCharacter()
        if character then
            local cha = character:GetSkill("ritorics", 0)
            if cha >= 5 then
                -- Разворот поворот
                local direction = (client:GetPos() - self:GetPos()):GetNormalized()
                self:SetAngles(direction:Angle())

                --client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный торг...] говорит: \"Глянь на мои товары!\"")]]))
                net.Start("OpenDialoguePanel_Medic")
                net.Send(client)

                --self:CapabilitiesRemove(CAP_MOVE_GROUND)
            else
                local randomBad = math.random(1, #phrasesBad)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный медик...] говорит: \"%s\"")]], phrasesBad[randomBad]))

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
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный медик...] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Типичный уличный медик...] роняет все свои товары, безжизненно падая на землю.")]])
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
    net.Receive("OpenDialoguePanel_Medic", function(len)
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
            button1:SetText("Медицинская помощь")
            button1:SetSize(200, 40) -- Увеличиваем размер кнопки
            button1:SetPos(frame:GetWide() / 2 - button1:GetWide() / 2, 20) -- Центрируем кнопку по горизонтали
            --button1:SetFont("TTSupermolotNeue-Medium") -- Устанавливаем шрифт
            button1.Paint = function(self, w, h)
                -- Убираем окантовку у кнопки
            end
            button1.DoClick = function()
                -- Код для обработки выбора "Торговать"
            end
    
            local button2 = vgui.Create("DButton", frame)
            button2:SetText("Попросить скидку [Риторика 22]")
            button2:SetSize(200, 40)
            button2:SetTextColor(Color(255, 165, 0))
            button2:SetPos(frame:GetWide() / 2 - button2:GetWide() / 2, 80) -- Размещаем кнопку ниже первой кнопки
            --button2:SetFont("TTSupermolotNeue-Medium")
            button2.Paint = function(self, w, h)
                -- Убираем окантовку у кнопки
            end
            button2.DoClick = function()
                -- Код для обработки выбора "Говорить [Риторика 10]"
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
                --:CapabilitiesAdd(CAP_MOVE_GROUND)
            end
        end
    end)
    
    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("Местный доктор")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Типичный уличный медик, одет как репликант. Заштопает любые раны за скромную сумму денег.")
        description:SizeToContents()
    end
end

list.Set( "NPC", "ix_street_medic", {
    Name = "Уличный медик",
    Class = "ix_street_medic",
    Category = "Cyberpunk RED"
})