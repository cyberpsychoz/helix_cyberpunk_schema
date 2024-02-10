local PLUGIN = PLUGIN;
local ns = netstream;

PLUGIN.dialogueCurrent = PLUGIN.dialogueCurrent or {}
PLUGIN.settingsCurrent = PLUGIN.settingsCurrent or {}
PLUGIN.quests = PLUGIN.quests or {}

surface.CreateFont( "R_chatFont", {
	font = "Montserrat",
	extended = false,
	size = 23,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

surface.CreateFont( "R_chatFont_anwsers", {
	font = "Montserrat",
	extended = false,
	size = 25,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

surface.CreateFont( "R_chatFont_Bold", {
	font = "Montserrat",
	extended = false,
	size = 25,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

ns.Hook('DialogueOpen', function(globalDialogue, settings, quests)
    if (PLUGIN.dialoguePanel && PLUGIN.dialoguePanel:IsValid()) then
		PLUGIN.dialoguePanel:Close();
    end;
    PLUGIN.dialogueCurrent = globalDialogue
    PLUGIN.settingsCurrent = settings
    PLUGIN.quests = quests

    PLUGIN.dialoguePanel = vgui.Create("DialogPanel");
    PLUGIN.dialoguePanel:Populate()
end)

ns.Hook('SettingsOpen', function(globalDialogue, settings, quests)
    if (PLUGIN.dialoguePanel && PLUGIN.dialoguePanel:IsValid()) then
		PLUGIN.dialoguePanel:Close();
    end;
    PLUGIN.dialogueCurrent = globalDialogue
    PLUGIN.settingsCurrent = settings
    PLUGIN.quests = quests

    PLUGIN.dialoguePanel = vgui.Create("TalkerSettingsPanel");
    PLUGIN.dialoguePanel:Populate()
end)

local panelMeta = FindMetaTable('Panel')

    function panelMeta:GetLinesOfContent()
        local lines = 1; -- + 0.25
        local text = self.textContent:GetText();
        local enc = 0;
    
        for s in string.gmatch(text, "[%w%s]") do
            enc = enc + 1;
            if enc > 45 then
                enc = 0;
                lines = lines + 0.25;
            end;
        end
        return lines;
    end;

    function panelMeta:Adaptate(w, h, x, y)
        local sW, sH = ScrW(), ScrH()
        x = x or 0.1; y = y or 0.1
        w = w or 100; h = h or 100
    
        self:SetPos( sW * math.min(x, 1.25), sH * math.min(y, 1.25) ) 
        self:SetSize( sW * (w / 1920), sH * (h / 1080) )
    end;
    
    function panelMeta:CreateCloseDebug()
        if input.IsKeyDown( KEY_PAD_MINUS ) or input.IsMouseDown( 111 ) then
            surface.PlaySound("ui/buttonclick.wav");
            self:CloseMe();
        end;
    end;
    
    function panelMeta:CloseMe()
        self:SetVisible(false); self:Remove();
        gui.EnableScreenClicker(false);

        PLUGIN.dialogueCurrent = {};
        PLUGIN.settingsCurrent = {};
    end;

    function draw.RoundedBoxOutlined( bordersize, x, y, w, h, color, bordercol )
        x, y, w, h = math.Round( x ), math.Round( y ), math.Round( w ), math.Round( h )
        draw.RoundedBox( bordersize, x, y, w, h, color )
        surface.SetDrawColor( bordercol )
        surface.DrawTexturedRectRotated( x + bordersize/2, y + bordersize/2, bordersize, bordersize, 0 ) 
        surface.DrawTexturedRectRotated( x + w - bordersize/2, y + bordersize/2, bordersize, bordersize, 270 ) 
        surface.DrawTexturedRectRotated( x + w - bordersize/2, y + h - bordersize/2, bordersize, bordersize, 180 ) 
        surface.DrawTexturedRectRotated( x + bordersize/2, y + h - bordersize/2, bordersize, bordersize, 90 ) 
        surface.DrawLine( x + bordersize, y, x + w - bordersize, y )
        surface.DrawLine( x + bordersize, y + h - 1, x + w - bordersize, y + h - 1 )
        surface.DrawLine( x, y + bordersize, x, y + h - bordersize )
        surface.DrawLine( x + w - 1, y + bordersize, x + w - 1, y + h - bordersize )
    end;

local ply = FindMetaTable("Player")    

function ply:GetQuests()
    return self:GetLocalVar('Quests')
end;

function ply:HasQuest( id )
    local quests = self:GetLocalVar('Quests')

    for k, v in pairs(quests) do
        if v == id then
            return true;
        end;
    end;

    return false;
end

function ply:CanFinishQuest(id)
    if !self:HasQuest(id) or (!PLUGIN.quests or !PLUGIN.quests[id]) then return false end;
    local quest = PLUGIN.quests;
    local npcNeeds = self:GetLocalVar('QuestNeeds');

    if table.Count(quest) > 0 then
        local tblNPC = PLUGIN.quests[id].npcs
        local tblItems = PLUGIN.quests[id].items

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
                if !ix.item.list[itemID] then 
                    return false 
                end;
                if tonumber(inventory:GetItemCount(itemID)) < tonumber(amount) then 
                    return false 
                end;
            end;
        end;

    end;

    return true;
end;