AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Неизвестный Соло"
ENT.Category = "Cyberpunk RED NPC"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Model = "models/cyberpunk/group03/male_09.mdl"
ENT.Armor = 3
ENT.Evasion = 10

if SERVER then
    --[[
    local schedule = ai_schedule.New("MySchedule")

    schedule:EngTask("TASK_TARGET_PLAYER", 0)
    schedule:EngTask("TASK_MOVE_TO_TARGET_RANGE", 60)
    schedule:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)

    function ENT:SelectSchedule()
        self:StartSchedule(schedule)
    end
    ]]

    local cooldownTime = 15
    local nextInteractionTime = CurTime()
    local isFollowing = false
    

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()

        self:SetNPCState(NPC_STATE_IDLE)
        self:SetSolid(SOLID_BBOX)
        self:DropToFloor()

        self:SetHealth(220)
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

        local phrasesGood = {
            "Дам тебе совет, купи себе лицензию на оружие, обзаведись стволом...",
            "В городе куча магазинов с одеждой, приведи себя в порядок.",
            "Есть районы, в которые лучше не соваться, понимаешь о чем я?",
            "Проклятые корпораты, не доверяй никому из них!",
            "Видят ли репликанты сны? Я - нет.",
            "Умение говорить намного больше ценится, чем...",
            "Авторейвы заражаются какой-то хренью, будь осторожен...",
            "Стоя в проходах, всегда прислоняйся спиной к стене, всегда!",
            "Не экономь на стимуляторах и аптечках.",
            "И зачем люди создали нас?"
        }

        local phrasesBad = {
            "Проваливай.",
            "Я не хочу с тобой говорить.",
            "Беги пока цел.",
            "Прочь с дороги, соплячок.",
            "Откуда тут такие клоуны как ты берутся..."
        }

        local character = client:GetCharacter()
        if character then
            local cha = character:GetAttribute("cha", 0)
            if cha >= 7 then
                local randomGood = math.random(1, #phrasesGood)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Странный мужчина в кож..] говорит: \"%s\"")]], phrasesGood[randomGood]))
                self:StartFollowing(client)
                self:CapabilitiesRemove(CAP_MOVE_GROUND)
                nextInteractionTime = CurTime() + cooldownTime
            else
                local randomBad = math.random(1, #phrasesBad)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Странный мужчина в кож..] говорит: \"%s\"")]], phrasesBad[randomBad]))

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
            "Блять, помогите! Ебут!",
            "Нахуй ты это делаешь?",
            "Что за хрень творится?!",
            "Ой, блять, болит!",
            "Эй, кто-нибудь, помогите!",
            "Ай сука, это больно!",
            "Уф-х, это было неожиданно!",
            "Моя рука! Бля!",
            "Черт, это неприятно!",
            "А-а-ай, сука, что происходит?!"
        }
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                if math.random(0, 100) <= 35 then
                    local randomIndex = math.random(1, #phrases)
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Странный мужчина в кож..] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Странный мужчина в кож..] издает предсмертный хрип, вываливая внутренности наружу.")]])
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
        else
            -- Если НПС еще жив, он начинает хуярить игрока
            if attacker:IsPlayer() and self:GetNWBool("IsInCombat") and self:GetNWBool("MyTurn") then
                local dmgrand = math.random(0, 10)
                attacker:TakeDamage(dmgrand, self, self) -- НПС наносит игроку 10 единиц урона
                for _, ply in ipairs(player.GetAll()) do
                    if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                        ply:ChatPrint(self:GetName() .. " атакует " .. attacker:GetName() .. " нанося ему".. dmgrand .." урона!")
                    end
                end
                self:SetNWBool("MyTurn", false)
            end
        end
    
        return false
    end                   
    
    function ENT:StartFollowing(client)
        if not isFollowing then -- Проверяем, не следует ли NPC уже за игроком
            isFollowing = true -- Устанавливаем флаг следования за игроком
            self:SetLastPosition(client:GetPos()) -- Устанавливаем позицию игрока как цель для следования
            local schedule = ai_schedule.New("FollowPlayerSchedule")
            schedule:EngTask("TASK_SET_ROUTE_SEARCH_TIME", 0)
            schedule:EngTask("TASK_GET_PATH_TO_LASTPOSITION", 0)
            schedule:EngTask("TASK_WALK_PATH", 0)
            schedule:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
            schedule:EngTask("TASK_FACE_TARGET", 0)
            schedule:EngTask("TASK_SET_ROUTE_SEARCH_TIME", 5)
            schedule:EngTask("TASK_SET_ROUTE_SEARCH_TYPE", 0)
            schedule:EngTask("TASK_GET_PATH_TO_LASTPOSITION", 0)
            schedule:EngTask("TASK_WALK_PATH", 0)
            schedule:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
            self:StartSchedule(schedule)
        end
    end

    function ENT:StopFollowing()
        isFollowing = false -- Сбрасываем флаг следования за игроком
        self:ClearSchedule() -- Очищаем расписание, чтобы прекратить следование
    end
    
end

if CLIENT then
    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("Неизвестный Соло")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Странный мужчина в кожанном плаще, возможно стоит попытаться поговорить с ним.")
        description:SizeToContents()
    end
end

list.Set( "NPC", "ix_solo", {
    Name = "Неизвестный Соло",
    Class = "ix_solo",
    Category = "Cyberpunk RED"
})