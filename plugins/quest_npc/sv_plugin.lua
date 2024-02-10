
local PLUGIN = PLUGIN;

resource.AddFile( "resource/fonts/MontserratBold.ttf" )
resource.AddFile( "resource/fonts/MontserratRegular.ttf" )
resource.AddFile( "materials/quest_icon/quest_item.png" )

PLUGIN.DialoguesList = PLUGIN.DialoguesList or {}
PLUGIN.QuestList = PLUGIN.QuestList or {}

function PLUGIN:SaveData()
    local Data = {};

    for id, entity in pairs( ents.FindByClass('talker_npc') ) do
        Data[ #Data + 1 ] = {
            position = entity:GetPos(),
            angles = entity:GetAngles(),
            dataTable = entity.informationTable
        }
    end;

    self:SetData( Data )
    ix.data.Set("Dialogues", PLUGIN.DialoguesList)
    ix.data.Set("Quests", PLUGIN.QuestList)
end;

function PLUGIN:LoadData()
    for id, entity in pairs(self:GetData() or {}) do
        local talker = ents.Create( 'talker_npc' )
        talker:SetPos( entity.position )
        talker:SetAngles( entity.angles )
        talker.informationTable = entity.dataTable

        talker:Spawn();
    end;

    if !ix.data.Get("Dialogues") then ix.data.Set("Dialogues", {}) end;
    if !ix.data.Get("Quests") then ix.data.Set("Quests", {}) end;

    PLUGIN.DialoguesList = ix.data.Get("Dialogues");
    PLUGIN.QuestList = ix.data.Get("Quests");
end;

-- serverside netstream;
netstream.Hook('SendToTalker_add', function(player, formed) 
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class or !(player:IsAdmin() or player:IsSuperAdmin()) then return end;
    local type = formed['type'];
    local id = formed['ID'];
    local entityID = entity:GetDialogueID();

    PLUGIN.DialoguesList[ entityID ][ type ][ id ] = {};

    for k, v in pairs(formed[type]) do
        PLUGIN.DialoguesList[ entityID ][ type ][ id ][ k ] = v;
    end;

    if formed['showFirst'] then
        table.insert(PLUGIN.DialoguesList[ entityID ][ 'callByDefault' ][ type ], id);
    end;

end)

netstream.Hook('SendToTalker_edit', function(player, formed) 
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class or !(player:IsAdmin() or player:IsSuperAdmin()) then return end;
    local type = formed['type'];
    local id = formed['ID'];
    local entityID = entity:GetDialogueID();
    
    if PLUGIN.DialoguesList[ entityID ][ type ][ id ] then
        for k, v in pairs(formed[type]) do
            PLUGIN.DialoguesList[ entityID ][ type ][ id ][ k ] = v;
        end;

        if formed['showFirst'] && !table.HasValue(PLUGIN.DialoguesList[ entityID ][ 'callByDefault' ][ type ], id) then
            table.insert(PLUGIN.DialoguesList[ entityID ][ 'callByDefault' ][ type ], id);
        end;
    end;
end);

netstream.Hook('SendToTalker_remove', function(player, type, id) 
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class or !(player:IsAdmin() or player:IsSuperAdmin()) then return end;
    local entityID = entity:GetDialogueID();
    
    if PLUGIN.DialoguesList[ entityID ][ type ][ id ] then
        PLUGIN.DialoguesList[ entityID ][ type ][ id ] = nil;

        for k, v in pairs(PLUGIN.DialoguesList[ entityID ]['callByDefault'][type]) do
            if v == id then
                PLUGIN.DialoguesList[ entityID ]['callByDefault'][type][k] = nil;
            end;
        end;
    end;
end);

netstream.Hook('Talker_Edit', function(player, name, model, sequence, skin, body)
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class or !(player:IsAdmin() or player:IsSuperAdmin()) then return end;

    entity.informationTable['name'] = name;
    entity.informationTable['model'] = model;
    entity.informationTable['sequence'] = sequence;
    entity.informationTable['skin'] = skin;
    entity.informationTable['bodyString'] = body;
    local infotable = entity.informationTable;

    entity:SetDefaultName( infotable['name'] );
	entity:SetModel( infotable['model'] );
    entity:SetSequence( infotable['sequence'] );
    entity:SetSkin( infotable['skin'] );
    entity:SetBodyGroups( infotable['bodyString'] );
end)

netstream.Hook('Talker_createQuest', function(player, formTable)
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class or !(player:IsAdmin() or player:IsSuperAdmin()) then return end;

    PLUGIN.QuestList[ formTable['id'] ] = formTable;
end)

netstream.Hook('AddQuestToPlayer', function(player, id)
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class then return end;
    local questsList = player:GetCharacter():GetData('QuestsDone')
 
    if PLUGIN.QuestList[id].ShowOnce && table.HasValue(questsList, id) then
        return
    end;

    player:AddQuest( id )
end)

netstream.Hook('FinishQuest', function(player, id)
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class then return end;
   
    player:FinishQuest(id) 
end)

netstream.Hook('RemoveQuest', function(player, id)
    local trace = player:GetEyeTraceNoCursor();
    local entity = trace.Entity;
    local class = entity && entity:GetClass() == 'talker_npc'
    if !class or !(player:IsAdmin() or player:IsSuperAdmin()) then return end;
   
    if PLUGIN.QuestList[ id ] then
        PLUGIN.QuestList[ id ] = nil;
    end;
end)

function PLUGIN:OnNPCKilled(npc, attacker, weapon)
    if attacker:IsPlayer() && attacker:Alive() && attacker:IsValid() then
        attacker:AddNPCKill(npc:GetClass(), 1)
    end;
end;

function PLUGIN:OnCharacterCreated(client, character)
    character:SetData("Quests", {})
    character:SetData("QuestsDone", {})
end

function PLUGIN:PlayerLoadedCharacter(client, character)
    timer.Simple(0.25, function()
        client:SetLocalVar("Quests", character:GetData("Quests", {}))
        client:SetLocalVar("QuestsDone", character:GetData("QuestsDone", {}))

        client:SetLocalVar('QuestNeeds', {})
        character:SetData('QuestNeeds', {})
    end)
end

function PLUGIN:CharacterPreSave(character)
    local client = character:GetPlayer()
    if (IsValid(client)) then
        character:SetData("Quests", client:GetLocalVar("Quests", {}))
        character:SetData("QuestsDone", client:GetLocalVar("QuestsDone", {}))
    end
end

--[[ meta ]]--
local ply = FindMetaTable("Player")

function ply:GetQuests()
    local character = self:GetCharacter()

    return character:GetData('Quests');
end;

function ply:AddQuest( id )
    if self:HasQuest( id ) then return end;

    local quests = self:GetQuests();
    quests[#quests + 1] = id;

    self:GetCharacter():SetData('Quests', quests);
    self:SetLocalVar('Quests', quests)
end

function ply:RemoveQuest( id )
    local quests = self:GetQuests();

    for k, v in pairs(quests) do
        if v == id then
            quests[k] = nil;
        end;
    end;

    self:GetCharacter():SetData('Quests', quests);
    self:SetLocalVar('Quests', quests)

    if !PLUGIN.QuestList[id].ShowOnce then return end;

    local questsDone = self:GetCharacter():GetData('QuestsDone')
    questsDone[#questsDone + 1] = id;

    self:GetCharacter():SetData('QuestsDone', questsDone);
    self:SetLocalVar('QuestsDone', questsDone)
end

function ply:HasQuest( id )
    local quests = self:GetQuests();

    for k, v in pairs(quests) do
        if v == id then
            return quests[k];
        end;
    end;

    return false;
end

--[[
    TODO:
    Доделать панели и настройки квестов.
    Сделать удаление квестов.
    Сделать зависимость появления диалога от квестов.
    По сути - все
]]

function ply:FinishQuest( id )
    
    if !self:HasQuest( id ) or !self:CanFinishQuest( id ) then
        return;
    end;
    local quest = PLUGIN.QuestList;
    local invlegal = self:GetCharacter():GetInventory()

    local tblNPC = quest[id].npcs
    local tblItems = quest[id].items

    if table.Count(tblNPC) > 0 then
        for npcID, amount in pairs(tblNPC) do
            self:AddNPCKill(npcID, 0, true)
        end;
    end;

    if table.Count(tblItems) > 0 then
        for itemID, amount in pairs(tblItems) do
            if !ix.item.list[itemID] then return false end;
            if invlegal:GetItemCount(itemID) < amount then return false end;
            
            for i = 1, amount do
                invlegal:Remove(invlegal:HasItem(itemID).id)
            end;
        end;
    end;    
    
    for k, v in pairs(quest[id].reward) do
        for i = 1, v do
            invlegal:Add(k)
        end;
    end;

   

    self:GetCharacter():GiveMoney( quest[id].money )

    self:RemoveQuest( id )
end

function ply:AddNPCKill(npc, amount, nullify)
    local questNeeds = self:GetCharacter():GetData('QuestNeeds', {})
    if !questNeeds[npc] then questNeeds[npc] = 0; end;

    if !nullify then
        questNeeds[npc] = questNeeds[npc] + amount;
    elseif nullify then
        questNeeds[npc] = 0;
    end;
    
    self:GetCharacter():SetData('QuestNeeds', questNeeds);
    self:SetLocalVar('QuestNeeds', questNeeds)
end;

function ply:CanFinishQuest(id)
    if !self:HasQuest(id) or !PLUGIN.QuestList or !PLUGIN.QuestList[id] then return false end;
    local quest = PLUGIN.QuestList;
    local npcNeeds = self:GetLocalVar('QuestNeeds');

    if table.Count(quest) > 0 then
        local tblNPC = quest[id].npcs
        local tblItems = quest[id].items

        if table.Count(tblNPC) > 0 then
            for npcID, amount in pairs(tblNPC) do
                if !npcNeeds[npcID] then return false end;
                for npc, num in pairs(npcNeeds) do
                    if npc == npcID && amount > num then
                        return false;
                    end;
                end;
            end;
        end;

        if table.Count(tblItems) > 0 then
            local inventory = self:GetCharacter():GetInventory();
            for itemID, amount in pairs(tblItems) do
                if !ix.item.list[itemID] then return false end;
                if inventory:GetItemCount(itemID) < amount then return false end;
            end;
        end;

    end;

    return true;
end;