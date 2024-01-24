AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Уличный торговец"
ENT.Category = "Cyberpunk RED"
ENT.Spawnable = true
ENT.AdminOnly = true
--ENT.bNoPersist = true
ENT.Armor = 0
ENT.Evasion = 20

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

    local models = {
        "models/humans/group01/male_77.mdl",
        "models/humans/group01/male_78.mdl",
        "models/humans/group01/male_80.mdl",
        "models/humans/group01/male_49.mdl",
        "models/barnes/refugee/female_01.mdl",
        "models/cyberpunk/group01/female_13.mdl",
        "models/cyberpunk/group01/female_04.mdl",
        "models/barnes/refugee/female_44.mdl"
    }

    local cooldownTime = 15
    local nextInteractionTime = CurTime()
    local isFollowing = false
    local randomModel = math.random(1, #models)

    function ENT:Initialize()
        self:SetModel(models[randomModel])
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()

        self:SetNPCState(NPC_STATE_IDLE)
        self:SetSolid(SOLID_BBOX)
        self:DropToFloor()

        self:SetHealth(220)
        self:CapabilitiesAdd(CAP_MOVE_GROUND)

        self:SetMoveType(MOVETYPE_STEP)
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
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный торг...] говорит: \"Глянь на мои товары!\"")]]))
            else
                local randomBad = math.random(1, #phrasesBad)
                client:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный торг...] говорит: \"%s\"")]], phrasesBad[randomBad]))

                nextInteractionTime = CurTime() + cooldownTime
            end
        else
            print("Ошибка: персонаж не найден.")
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        local attacker = dmginfo:GetAttacker()
        local damage = dmginfo:GetDamage()
        print(damage)
    
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
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный торг...] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Типичный уличный торг...] роняет все свои товары, безжизненно падая на землю.")]])
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
    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("Уличный торговец")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Типичный уличный торговец, одет как репликант. Возможно получится у него что-то прикупить.")
        description:SizeToContents()
    end
end

list.Set( "NPC", "ix_trader", {
    Name = "Уличный торговец",
    Class = "ix_trader",
    Category = "Cyberpunk RED"
})