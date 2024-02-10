local PANEL = {};
local PLUGIN = PLUGIN;

function PANEL:Init()
    self:SetFocusTopLevel( true )
    self:MakePopup()
    self:Adaptate(650, 780, 0.32, 0.15)
    gui.EnableScreenClicker(true);

    self:SetAlpha(0)

    self:AlphaTo(255, 0.3, 0, function(alpha, pnl)
        pnl:SetAlpha(255)
    end);
end;

function PANEL:Paint( w, h )
    Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
    draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(20, 20, 20, 100), Color(100, 100, 100) )
    self:CreateCloseDebug()
end;


function PANEL:Populate()
    local Dialogues = PLUGIN.dialogueCurrent
    local TalkerSettings = PLUGIN.settingsCurrent
    local Dialogues_def_call = Dialogues['callByDefault']

    local QUESTS = PLUGIN.quests

    local dialogue = Dialogues['Dialogues']
    local anwser = Dialogues['Anwsers']

    self.dialoguesPanel = self:Add('DScrollPanel')
    self.dialoguesPanel:Dock(TOP);
    self.dialoguesPanel:SetTall(325)

    self.AnwsersList = self:Add('DScrollPanel')
    self.AnwsersList:Dock(FILL);
    self.AnwsersList:SetTall(325)


    for id, number in pairs(Dialogues_def_call['Dialogues'] or {}) do
        for dialogue_id, data in pairs(dialogue) do
            if number == dialogue_id then
                local dialogue = self.dialoguesPanel:Add('Dialogue')
                dialogue:DialogueOwner(true);
                dialogue:DialogueText(data.text)
                dialogue:Populate();

                if data.callQuest && data.callQuest > 0 && QUESTS[data.callQuest] then
                    if QUESTS[data.callQuest].ShowOnce && table.HasValue(LocalPlayer():GetLocalVar('QuestsDone', {}), data.callQuest) then break end;
                    local quest = self.dialoguesPanel:Add('Quest')
                    quest:Dock(TOP)
                    quest:AddTitle( QUESTS[data.callQuest].title )
                    quest:AddDescription( QUESTS[data.callQuest].description )
                    quest:SetQuestID( data.callQuest )
                    quest:Populate()
                end;
            end;
        end;
    end;

    for id, number in pairs(Dialogues_def_call['Anwsers'] or {}) do
        for anwser_id, data in pairs(anwser) do
            if number == anwser_id then
                local anwser = self.AnwsersList:Add('Anwser')
                anwser:GetAnwserText(data.text)
                anwser:GetUniqueID(anwser_id)
                anwser.defaultParent = self;
                anwser:Populate()
            end;
        end;
    end;
end;

vgui.Register( "DialogPanel", PANEL, "EditablePanel" )