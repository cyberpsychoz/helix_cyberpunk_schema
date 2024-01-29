PLUGIN.npcPools = {}

util.AddNetworkString("npcSpawnerOpen")
util.AddNetworkString("npcSpawnerSaveChanges")

ix.log.AddType("npcSpawner", function(client, ...)
    local arg = {...}
    return L("npcSpawnerLog", client[1], client[1]:Name(), arg[1])
end, FLAG_WARNING)

function PLUGIN:SaveData()
    local data = {}

    for _, entity in ipairs(ents.FindByClass("npc_spawner")) do
        data[#data + 1] = {
            pos = entity:GetPos(),
            angles = entity:GetAngles(),
            model = entity:GetModel(),
            enabled = entity:GetEnabled(),
            maxNPCs = entity:GetMaxNPCs(),
            spawnInterval = entity:GetSpawnInterval(),
            npcRadius = entity:GetNPCSpawnRadius(),
            playerRadius = entity:GetPlayerRadius(),
            spawnAmount = entity:GetSpawnAmount(),
            npcClass = entity:GetNPCClass(),
            weaponClass = entity:GetWeaponClass()
        }
    end

    self:SetData(data)
end

function PLUGIN:LoadData()
    for _, v in ipairs(self:GetData() or {}) do
        local entity = ents.Create("npc_spawner")
        entity:SetPos(v.pos)
        entity:SetAngles(v.angles)

        entity:SetModel(v.model)
        entity:SetSolid(SOLID_BBOX)
        entity:PhysicsInit(SOLID_BBOX)

        local physObj = entity:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        entity:SetEnabled(v.enabled)
        entity:SetMaxNPCs(v.maxNPCs)
        entity:SetSpawnInterval(v.spawnInterval)
        entity:SetNPCSpawnRadius(v.npcRadius)
        entity:SetPlayerRadius(v.playerRadius)
        entity:SetSpawnAmount(v.spawnAmount)
        entity:SetNPCClass(v.npcClass)
        entity:SetWeaponClass(v.weaponClass)
        entity:Spawn()
    end
end

net.Receive("npcSpawnerSaveChanges", function(len, client)
    local changes = {}
    local changeString = ""
    if (!client:CanUseNPCSpawner()) then return end
    local entity = net.ReadEntity()
    local enabledBool = net.ReadBool()
    local npcClass = net.ReadString()
    local weaponClass = net.ReadString()
    local playerRadius = net.ReadUInt(14)
    local npcSpawnRadius = net.ReadUInt(14)
    local maxNPCs = net.ReadUInt(8)
    local spawnInterval = net.ReadUInt(16)
    local spawnAmount = net.ReadUInt(8)

    if (entity:GetEnabled() != enabledBool) then
        changes[#changes + 1] = "Enabled: " .. tostring(entity:GetEnabled()) .. " > " .. tostring(enabledBool)
        entity:SetEnabled(enabledBool)
    end
    if (entity:GetNPCClass() != npcClass) then
        changes[#changes + 1] = "NPC Class: " .. entity:GetNPCClass() .. " > " .. npcClass
        entity:SetNPCClass(npcClass)
    end
    if (entity:GetWeaponClass() != weaponClass) then
        changes[#changes + 1] = "Weapon Class : " .. entity:GetWeaponClass() .. " > " .. weaponClass
        entity:SetWeaponClass(weaponClass)
    end
    if (entity:GetPlayerRadius() != playerRadius) then
        changes[#changes + 1] = "Player Radius: " .. entity:GetPlayerRadius() .. " > " .. playerRadius
        entity:SetPlayerRadius(playerRadius)
    end
    if (entity:GetNPCSpawnRadius() != npcSpawnRadius) then
        changes[#changes + 1] = "NPC Radius: " .. entity:GetNPCSpawnRadius() .. " > " .. npcSpawnRadius
        entity:SetNPCSpawnRadius(npcSpawnRadius)
    end
    if (entity:GetMaxNPCs() != maxNPCs) then
        changes[#changes + 1] = "Max NPCs: " .. entity:GetMaxNPCs() .. " > " .. maxNPCs
        entity:SetMaxNPCs(maxNPCs)
    end
    if (entity:GetSpawnInterval() != spawnInterval) then
        changes[#changes + 1] = "Spawn Interval: " .. entity:GetSpawnInterval() .. " > " .. spawnInterval
        entity:SetSpawnInterval(spawnInterval)
    end
    if (entity:GetSpawnAmount() != spawnAmount) then
        changes[#changes + 1] = "Spawn Amount: " .. entity:GetSpawnAmount() .. " > " .. spawnAmount
        entity:SetSpawnAmount(spawnAmount)
    end

    for _, v in pairs(changes) do
        changeString = changeString .. v .. "\n"
    end

    if (changeString != "") then
        CAMI.GetPlayersWithAccess("Helix - NPC Spawner", function(ply)
            ix.log.Add(ply, "npcSpawner", changeString)
        end)
    end
end)
