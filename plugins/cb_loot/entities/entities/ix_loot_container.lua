local PLUGIN = PLUGIN

AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Лутабельный контейнер"
ENT.Author = "Крыжовник"
ENT.Category = "Cyberpunk RED"

ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "ContainerClass")
end

if ( SERVER ) then
    function ENT:Initialize()
        self:SetModel("models/hunter/blocks/cube075x1x075.mdl")
        self:PhysicsInit(SOLID_VPHYSICS) 
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
    
        local phys = self:GetPhysicsObject()
        if ( phys:IsValid() ) then
            phys:Wake()
            phys:EnableMotion(false)
        end
    end

    function ENT:SpawnFunction(ply, trace)
        local angles = ply:GetAngles()

        local entity = ents.Create("ix_loot_container")
        entity:SetPos(trace.HitPos)
        entity:SetAngles(Angle(0, (entity:GetPos() - ply:GetPos()):Angle().y - 180, 0))
        entity:Spawn()
        entity:Activate()

        --Schema:SaveData()
        return entity
    end

    function ENT:OnRemove()
       --Schema:SaveData()
    end
    
    function ENT:Use(ply, call)
        local char = ply:GetCharacter()
        local inv = char:GetInventory()
        local loot = ix.loot.containers[self:GetContainerClass()]

        if not ( loot ) then return end

        if ( char:GetFaction() == FACTION_AUTORAVE ) then
            ply:Notify("Вы не можете ограбить этот контейнер.")
            return false
        end

        if not ( timer.Exists("ixLootSearch."..self:EntIndex()) ) then
            local lootTime = loot.lootTime

            if ( istable(lootTime) ) then
                lootTime = lootTime[math.random(1, #lootTime)]
            end

            loot.onStart(ply, self)
            ply:SetAction("Поиск полезных материалов...", lootTime)
            ply:DoStaredAction(self, function()
                if not ( IsValid(ply) or ply:Alive() ) then return end

                local maxItems = 1
                if ( math.random(1, 10) == 1 ) then
                    maxItems = math.random(1, #loot.maxItems)
                end

                for i = 1, maxItems do
                    local item = loot.items[math.random(1, #loot.items)]
                    if ( loot.rareItems and istable(loot.rareItems) ) and ( math.random(1, 10) == 1 ) then
                        item = loot.rareItems[math.random(1, #loot.rareItems)]
                    end

                    if not ( inv:Add(item, amount) ) then
                        ix.item.Spawn(v, self)
                    end

                    ply:Notify("Вы нашли: "..ix.item.list[item].name..".")
                end
            end, lootTime, function()
                if ( IsValid(ply) ) then
                    ply:SetAction()

                    if ( IsValid(self) ) then
                        timer.Remove("ixLootSearch."..self:EntIndex())
                        loot.onEnd(ply, self)
                    end
                end
            end)

            timer.Simple(lootTime, function()
                if ( IsValid(self) ) then
                    loot.onEnd(ply, self)
                end
            end)

            timer.Create("ixLootSearch."..self:EntIndex(), loot.delay, 1, function()
            end)
        else
            ply:Notify("Ты должен подождать "..string.NiceTime(timer.TimeLeft("ixLootSearch."..self:EntIndex())).." прежде чем вы сможете снова выполнить поиск в этом контейнере.")
        end
    end
end