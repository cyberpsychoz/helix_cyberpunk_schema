local PLUGIN = PLUGIN;
local PANEL = {};

function PANEL:Init()
    self:SetFocusTopLevel( true )
    
    self:Adaptate(1100, 750, 0.25, 0.15)

	self:MakePopup()
    gui.EnableScreenClicker(true);
end;

function PANEL:Paint( w, h )
    Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
    draw.RoundedBox(0, 0, 0, w, h, Color(12, 12, 12, 150))

    self:CreateCloseDebug()
end;


function PANEL:Populate()
    local D = PLUGIN.dialogueCurrent
    local TalkerSettings = PLUGIN.settingsCurrent
    local quests = PLUGIN.quests;
    
    self.CloseButton = self:Add("DButton")
    self.CloseButton:Dock(BOTTOM);
    self.CloseButton:SetText('CLOSE')
    self.CloseButton:SetColor( Color(100, 255, 100) )
    self.CloseButton.Paint = function(s, w, h) end;

    self.CloseButton.DoClick = function(btn)
        self:CloseMe();

        local bText = table.concat( self.TalkerSettings.bodyGroupText );
        PLUGIN.settingsCurrent['bodyString'] = bText;
        
        netstream.Start('Talker_Edit', 
        self.TalkerSettings.talkerName:GetText(), 
        self.TalkerSettings.modelPath:GetText(), 
        self.TalkerSettings.sequenceWang:GetValue(),
        self.TalkerSettings.skinSelector:GetValue(),
        PLUGIN.settingsCurrent['bodyString'])
    end;

    self.ContainInfo = self:Add("Panel")
    self.ContainInfo:Dock(LEFT)
    self.ContainInfo:SetWidth(350)

    self.SettingsPlate = self:Add("Panel")
    self.SettingsPlate:Dock(LEFT)
    self.SettingsPlate:SetWidth(400)

    self.QuestPlate = self:Add("QuestPanel")
    self.QuestPlate:Dock(LEFT)
    self.QuestPlate:SetWidth(350)

    self.AddNewInfo = self.SettingsPlate:Add('Panel')
    self.AddNewInfo:Dock(TOP)
    self.AddNewInfo:SetTall(250)
    self.AddNewInfo:DockMargin(5, 5, 5, 5)
    self.AddNewInfo.Paint = function(s, w, h)
        draw.RoundedBox(1, 0, 0, w, h, Color( 40, 40, 40 ))
    end;

    self.TalkerSettings = self.SettingsPlate:Add('TalkerSettings_Settings')
    self.TalkerSettings:Dock(FILL)
    self.TalkerSettings:SetTall(250)
    self.TalkerSettings:DockMargin(5, 5, 5, 5)
    self.TalkerSettings.Paint = function(s, w, h)
        draw.RoundedBox(1, 0, 0, w, h, Color( 40, 40, 40 ))
    end;
    self.TalkerSettings:SetBaseData( TalkerSettings['name'], TalkerSettings['model'], TalkerSettings['sequence'], TalkerSettings['skin'], TalkerSettings['bodyString'] )

    local leftPanel = self.AddNewInfo:Add('Panel')
    leftPanel:Dock(LEFT)
    leftPanel:SetWidth(100)

    local rightPanel = self.AddNewInfo:Add('Panel')
    rightPanel:Dock(FILL)

    self.ContainTree = self.ContainInfo:Add('DTree')
    self.ContainTree:Dock(TOP)
    self.ContainTree:SetTall(250)
    self.ContainTree:DockMargin(5, 5, 5, 5)
    self.ContainTree.Paint = function(s, w, h)
        draw.RoundedBox(1, 0, 0, w, h, Color( 40, 40, 40 ))
    end;

    local addButton = leftPanel:Add('DButton')
    addButton:SetText('Add...')
    addButton:Center()
    addButton:AlignTop( 60 )

    addButton.DoClick = function(btn)
        if self.RemovePanel then self.RemovePanel:Remove(); self.RemovePanel = nil; end;
        if self.EditPanel then self.EditPanel:Remove() self.EditPanel = nil end;

        if !self.AddPanel then
            self.AddPanel = rightPanel:Add('TalkerSettingsPanel_ADD')
            self.AddPanel:Dock(FILL)

            self.AddPanel.MainParent = self;
        end;

    end;

    local editButton = leftPanel:Add('DButton')
    editButton:SetText('Edit...')
    editButton:Center()
    editButton:AlignTop( 85 )

    editButton.DoClick = function(btn)
        if self.RemovePanel then self.RemovePanel:Remove(); self.RemovePanel = nil; end;
        if self.AddPanel then self.AddPanel:Remove(); self.AddPanel = nil; end;

        if !self.EditPanel then
            self.EditPanel = rightPanel:Add('TalkerSettingsPanel_EDIT')
            self.EditPanel:Dock(FILL)
            self.EditPanel.MainParent = self;
        end;
    end;

    local removeButton = leftPanel:Add('DButton')
    removeButton:SetText('Remove...')
    removeButton:Center()
    removeButton:AlignTop( 110 )
    
    removeButton.DoClick = function(btn)
        if self.EditPanel then self.EditPanel:Remove() self.EditPanel = nil end;
        if self.AddPanel then self.AddPanel:Remove(); self.AddPanel = nil; end;
        local item = self.ContainTree:GetSelectedItem();
        
        if !self.RemovePanel then
            self.RemovePanel = rightPanel:Add('DLabel')
            self.RemovePanel:Dock(TOP)
            self.RemovePanel:SetText('Select anwser or dialogue on the left panel.')
            self.RemovePanel:SetWrap(true)
        end;

        if item && item.uniqueID then
            Derma_Query( "Press yes or no", "Delete?", "Yes", function()
                local DIALOGUES_ONSHOW = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 0 ):GetChildNode(0);
                local ANWSERS_ONSHOW = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 0 ):GetChildNode(1);
                local DIALOGUES = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 1 ):GetChildNode(0)
                local ANWSERS = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 1 ):GetChildNode(1)

                if item.type == 'Dialogues' then
                    for k, v in pairs(DIALOGUES_ONSHOW:GetChildNodes()) do
                        if v.uniqueID == item.uniqueID then
                            v:Remove();
                        end;
                    end;
                    for k, v in pairs(DIALOGUES:GetChildNodes()) do
                        if v.uniqueID == item.uniqueID then
                            v:Remove();
                        end;
                    end;
                end;
                if item.type == 'Anwsers' then
                    for k, v in pairs(ANWSERS_ONSHOW:GetChildNodes()) do
                        if v.uniqueID == item.uniqueID then
                            v:Remove();
                        end;
                    end;
                    for k, v in pairs(ANWSERS:GetChildNodes()) do
                        if v.uniqueID == item.uniqueID then
                            v:Remove();
                        end;
                    end;
                end;

                netstream.Start('SendToTalker_remove', item.type, item.uniqueID)
            end,
            "No",
            function()
            end)
        end;
    end;

    self.ContainDescription = self.ContainInfo:Add('DScrollPanel')
    self.ContainDescription:Dock(FILL)
    self.ContainDescription:DockMargin(5, 5, 5, 5)
    self.ContainDescription.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color( 40, 40, 40 ))
    end;

    function self.ContainDescription:ActivatePanel()
        self:AlphaTo(255, 0.5, 0, function()
            self:SetAlpha(255)
        end)
    end;

    self.ContainDescription:AlphaTo(100, 1, 0.2, function()
        self.ContainDescription:SetAlpha(100)
    end)

    self.ContainDescriptionID = self.ContainDescription:Add('DLabel')
    self.ContainDescriptionID:Dock(TOP);
    self.ContainDescriptionID:SetText('')
    self.ContainDescriptionID:SetContentAlignment(2)

    self.ContainDescriptionID:SetVisible(false)

    self.ContainDescriptionText = self.ContainDescription:Add('DLabel')
    self.ContainDescriptionText:Dock(TOP);
    self.ContainDescriptionText:SetText('')
    self.ContainDescriptionText:DockMargin(5, 5, 5, 5)
    self.ContainDescriptionText:SetWrap(true)
    self.ContainDescriptionText:SetAutoStretchVertical(true)
    self.ContainDescriptionText:SizeToContents()

    self.ContainDescriptionText:SetVisible(false)

    self.ContainDescriptionCall = self.ContainDescription:Add('DLabel')
    self.ContainDescriptionCall:Dock(TOP);
    self.ContainDescriptionCall:SetText('')
    self.ContainDescriptionCall:DockMargin(5, 5, 5, 5)
    self.ContainDescriptionCall:SetWrap(true)
    self.ContainDescriptionCall:SetAutoStretchVertical(true)
    self.ContainDescriptionCall:SizeToContents()

    self.ContainDescriptionCall:SetVisible(false)

    self.ContainDescriptionRemove = self.ContainDescription:Add('DLabel')
    self.ContainDescriptionRemove:Dock(TOP);
    self.ContainDescriptionRemove:SetText('')
    self.ContainDescriptionRemove:DockMargin(5, 5, 5, 5)
    self.ContainDescriptionRemove:SetWrap(true)
    self.ContainDescriptionRemove:SetAutoStretchVertical(true)
    self.ContainDescriptionRemove:SizeToContents()

    self.ContainDescriptionRemove:SetVisible(false)

    self.ContainDescriptionNext = self.ContainDescription:Add('DLabel')
    self.ContainDescriptionNext:Dock(TOP);
    self.ContainDescriptionNext:SetText('')
    self.ContainDescriptionNext:DockMargin(5, 5, 5, 5)
    self.ContainDescriptionNext:SetWrap(true)
    self.ContainDescriptionNext:SetAutoStretchVertical(true)
    self.ContainDescriptionNext:SizeToContents()

    self.ContainDescriptionNext:SetVisible(false)

    local start_show = self.ContainTree:AddNode( "Show in the beginning", 'icon16/page_white_width.png' )
    local dialogues = self.ContainTree:AddNode( "Show on talk", 'icon16/paste_plain.png' )
    local dialogue_init = dialogues:AddNode('Dialogues', 'icon16/comment.png')
    local anwser_init = dialogues:AddNode('Anwsers', 'icon16/error.png')
    local dialogue = start_show:AddNode('Dialogues', 'icon16/comment.png')
    local anwser = start_show:AddNode('Anwsers', 'icon16/error.png')
    
    if #D['callByDefault']['Dialogues'] != 0 then
        for k, v in pairs(D['callByDefault']['Dialogues']) do
            self:CreateDialoguesTree(v, D['Dialogues'], dialogue)
        end;
    end;
    
    if #D['callByDefault']['Anwsers'] != 0 then
        for k, v in pairs(D['callByDefault']['Anwsers']) do
            self:CreateAnwsersTree(v, D['Anwsers'], anwser)
        end;
    end;

    if #D['Dialogues'] != 0 then
        for k, v in pairs(D['Dialogues']) do
            self:CreateDialoguesTree(k, D['Dialogues'], dialogue_init)
        end;
    end;

    if #D['Anwsers'] != 0 then
        for k, v in pairs(D['Anwsers']) do
            self:CreateAnwsersTree(k, D['Anwsers'], anwser_init)
        end;
    end;

    local questList = self.ContainTree:AddNode( "Quests", 'icon16/eye.png' )
    if quests then
        for k, v in pairs(quests) do
            self:CreateQuestTree(k, v, questList)
        end;
    end;

end;

function PANEL:CreateQuestTree(id, data, parent)
    local text = CutTextAlittle('[' .. id .. '] ' .. data.title);
    local Quest = parent:AddNode(text, 'icon16/script.png')
    local quests = PLUGIN.quests

    Quest.uniqueID = id;

    local NPCs = Quest:AddNode("NPCs", 'icon16/bug.png')
    local Items = Quest:AddNode("Items", 'icon16/plugin.png')
    local Rewards = Quest:AddNode("Rewards", 'icon16/ruby.png')

    Quest.DoClick = function(btn)
        local edit = self.QuestPlate.EditPanel;
        if edit && data then
            edit.NextID:SetText('ID: '..id);
            edit.NextID.id = id;
            edit.titleText:SetText(data.title)
            edit.DescriptionText:SetText(data.description)
            edit.moneyReward:SetValue(data.money)
            edit.showQuestOnce:SetValue(data.ShowOnce)
            edit.npcsList:Clear()
            edit.itemsList:Clear()
            edit.rewardList:Clear()
            for k, v in pairs(data.npcs) do
                local newLine = edit.npcsList:AddLine(k, v)
                newLine.npc = k
                newLine.amount = v
            end;
            for k, v in pairs(data.items) do
                local newLine = edit.itemsList:AddLine(k, v)
                newLine.npc = k
                newLine.amount = v
            end;
            for k, v in pairs(data.reward) do
                local newLine = edit.rewardList:AddLine(k, v)
                newLine.npc = k
                newLine.amount = v
            end;
            for k, v in pairs(edit.questsLeft:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove();
                end;
            end;
            for k, v in pairs(edit.questsRight:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove();
                end;
            end;

            if data.needsQuest && #data.needsQuest > 0 then
                for k, v in pairs(data.needsQuest) do
                    local questRight = edit.questsLeft:Add('DButton')
                    questRight:Dock(TOP)
                    questRight:SetText('['.. v .. ']' .. quests[v].title)
                    questRight.id = k;
                    questRight:DockMargin(5, 5, 5, 5)
                    questRight:DockPadding(5, 5, 5, 5)
        
                    questRight.DoClick = function(btn)
                        if !edit.QuestsDone:IsEnabled() then return; end;
                        btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                            if panel:GetParent() == edit.questsRight:GetCanvas() then
                                edit.questsLeft:Add(panel)
                            elseif panel:GetParent() == edit.questsLeft:GetCanvas() then
                                edit.questsRight:Add(panel)
                            end;
                            panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                                pnl:SetAlpha(255);
                            end)
                        end)
                    end;
        
                    questRight.Think = function(btn)
                        btn:SetEnabled(edit.QuestsDone:IsEnabled())
                    end;                              
                end;
            end;
            
            for k, v in pairs(quests) do
                if data.needsQuest or #data.needsQuest == 0 or !table.HasValue(data.needsQuest, k) then
                    local questRight = edit.questsRight:Add('DButton')
                    questRight:Dock(TOP)
                    questRight:SetText('['.. k .. ']' .. v.title)
                    questRight.id = k;
                    questRight:DockMargin(5, 5, 5, 5)
                    questRight:DockPadding(5, 5, 5, 5)
        
                    questRight.DoClick = function(btn)
                        if !edit.QuestsDone:IsEnabled() then return; end;
                        btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                            if panel:GetParent() == edit.questsRight:GetCanvas() then
                                edit.questsLeft:Add(panel)
                            elseif panel:GetParent() == edit.questsLeft:GetCanvas() then
                                edit.questsRight:Add(panel)
                            end;
                            panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                                pnl:SetAlpha(255);
                            end)
                        end)
                    end;
        
                    questRight.Think = function(btn)
                        btn:SetEnabled(edit.QuestsDone:IsEnabled())
                    end;
                end;
            end;

            for k, v in pairs(self.QuestPlate.EditPanel:GetCanvas():GetChildren()) do
                self.QuestPlate.EditPanel.ChooseCorrectly:Remove()
                v:SetAlpha(255)
                v:SetEnabled(true)
            end;
        end;
    end;

    if data.npcs && table.Count(data.npcs) > 0 then
        for k, v in pairs(data.npcs) do
            local npc = NPCs:AddNode(k..' = '..v, 'icon16/bug.png')
        end;
    end;
    if data.items && table.Count(data.items) > 0 then
        for k, v in pairs(data.items) do
            local item = Items:AddNode(k..' = '..v, 'icon16/plugin.png')
        end;
    end;
    if data.reward && table.Count(data.reward) > 0 then
        for k, v in pairs(data.reward) do
            local reward = Rewards:AddNode(k..' = '..v, 'icon16/ruby.png')
        end;
    end;
end;


function PANEL:CreateDialoguesTree(id, TABLE, parent)
    local text = '[' .. id .. ']' .. TABLE[id].text;
    if string.len(text) > 15 then text = string.sub(text, 1, 15) .. '...' end;
    local basicDialogue = parent:AddNode(text, 'icon16/comment.png')
    basicDialogue.markedToDelete = true;
    basicDialogue.uniqueID = id;
    basicDialogue.type = 'Dialogues'

    local quests = PLUGIN.quests;
    local quest = TABLE[id].callQuest
    if quest && quests[quest] then
        local ph_quest = basicDialogue:AddNode('Calls quest', 'icon16/script.png')
        local text = CutTextAlittle('[' .. quest .. ']' .. quests[quest].title)
        local CountAnwser_dialogue_next = ph_quest:AddNode(text, 'icon16/help.png')
    end;

    basicDialogue.OnNodeSelected = function(btn)
        if self.GetSelectedTree && self.GetSelectedTree == btn then return end;

        if self.EditPanel then
            local editPanel = self.EditPanel
            editPanel.ChooseCorrectly:Remove();
            for k, v in pairs(editPanel.ScrollPanel:GetCanvas():GetChildren()) do
                if !table.HasValue(editPanel.FirstBuffer, v) then
                    v:SetEnabled(true)
                    v:SetAlpha(255)
                end;
            end;

            editPanel.targetText:SetText( TABLE[id].text )
            editPanel.showFirst:SetChecked( table.HasValue(PLUGIN.dialogueCurrent['callByDefault']['Dialogues'], id) )

            for k, v in pairs(editPanel.FirstBuffer) do
                v:SetEnabled(false)
                v:SetAlpha(100)
            end;

            for k, v in pairs(editPanel.callsLeft:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;
            for k, v in pairs(editPanel.callsRight:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;
            for k, v in pairs(editPanel.RemovesLeft:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;
            for k, v in pairs(editPanel.RemovesRight:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;

            editPanel.TypeLabel:SetText('Identificator: ' .. id)
        end;
        self.GetSelectedTree = btn;
        self:WorkWithInformationLabels(1, id, TABLE[id])
    end;
end;

function PANEL:CreateAnwsersTree(id, TABLE, parent)
    local D = PLUGIN.dialogueCurrent

    local CountAnwser = parent:AddNode(CutTextAlittle('[' .. id .. ']' .. TABLE[id].text), 'icon16/error.png')
    CountAnwser.markedToDelete = true;
    CountAnwser.uniqueID = id;
    CountAnwser.type = 'Anwsers'

    local call = TABLE[id].__CALL;
    local remove = TABLE[id].__REMOVE;
    local nextDialogue = TABLE[id].__DIALOGUE;

    CountAnwser.OnNodeSelected = function(btn)
        if self.GetSelectedTree && self.GetSelectedTree == btn then return end;

        if self.EditPanel then
            local editPanel = self.EditPanel
            editPanel.ChooseCorrectly:Remove();
            for k, v in pairs(editPanel.ScrollPanel:GetCanvas():GetChildren()) do
                v:SetAlpha(255)
                v:SetEnabled(true);
            end;

            editPanel.targetText:SetText( TABLE[id].text )
            editPanel.dialogue:SetValue(TABLE[id].__DIALOGUE)
            editPanel.CanClose:SetChecked( TABLE[id].CanClose )
            editPanel.showFirst:SetChecked( table.HasValue(D['callByDefault']['Anwsers'], id) )

            for k, v in pairs(editPanel.callsLeft:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;
            for k, v in pairs(editPanel.callsRight:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;
            for k, v in pairs(editPanel.RemovesLeft:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;
            for k, v in pairs(editPanel.RemovesRight:GetCanvas():GetChildren()) do
                if v:GetName() != "DLabel" then
                    v:Remove()
                end;
            end;

            for k, v in pairs(D['Anwsers']) do
                if !TABLE[id].__CALL or #TABLE[id].__CALL == 0 or !table.HasValue(TABLE[id].__CALL, k) then
                    local btnAnwsers = editPanel.callsRight:Add('DButton')
                    btnAnwsers:Dock(TOP)
                    btnAnwsers:SetText('['.. k .. ']' .. v.text)
                    btnAnwsers.id = k;
                    btnAnwsers:DockMargin(5, 5, 5, 5)
                    btnAnwsers:DockPadding(5, 5, 5, 5)
        
                    btnAnwsers.DoClick = function(btn)
                        if !editPanel.CallsParent:IsEnabled() then
                            return;
                        end;
                        btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                            if panel:GetParent() == editPanel.callsRight:GetCanvas() then
                                editPanel.callsLeft:Add(panel)
                            elseif panel:GetParent() == editPanel.callsLeft:GetCanvas() then
                                editPanel.callsRight:Add(panel)
                            end;
                            panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                                pnl:SetAlpha(255);
                            end)
                        end)
                    end;
        
                    btnAnwsers.Think = function(btn)
                        btn:SetEnabled(editPanel.CallsParent:IsEnabled())
                    end;
                end;
            end;

            if TABLE[id].__CALL && #TABLE[id].__CALL > 0 then
                for k, v in pairs(TABLE[id].__CALL) do
                    local btnAnwsers = editPanel.callsLeft:Add('DButton')
                    btnAnwsers:Dock(TOP)
                    btnAnwsers:SetText('['.. v .. ']' .. D['Anwsers'][v].text)
                    btnAnwsers.id = k;
                    btnAnwsers:DockMargin(5, 5, 5, 5)
                    btnAnwsers:DockPadding(5, 5, 5, 5)
        
                    btnAnwsers.DoClick = function(btn)
                        if !editPanel.CallsParent:IsEnabled() then
                            return;
                        end;
                        btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                            if panel:GetParent() == editPanel.callsRight:GetCanvas() then
                                editPanel.callsLeft:Add(panel)
                            elseif panel:GetParent() == editPanel.callsLeft:GetCanvas() then
                                editPanel.callsRight:Add(panel)
                            end;
                            panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                                pnl:SetAlpha(255);
                            end)
                        end)
                    end;
        
                    btnAnwsers.Think = function(btn)
                        btn:SetEnabled(editPanel.CallsParent:IsEnabled())
                    end;
                end;
            end;
            
            for k, v in pairs(D['Anwsers']) do
                if !TABLE[id].__REMOVE or #TABLE[id].__REMOVE == 0 or !table.HasValue(TABLE[id].__REMOVE, k) then
                    local btnAnwsers = editPanel.RemovesRight:Add('DButton')
                    btnAnwsers:Dock(TOP)
                    btnAnwsers:SetText('['.. k .. ']' .. v.text)
                    btnAnwsers.id = k;
                    btnAnwsers:DockMargin(5, 5, 5, 5)
                    btnAnwsers:DockPadding(5, 5, 5, 5)
        
                    btnAnwsers.DoClick = function(btn)
                        if !editPanel.RemovesParent:IsEnabled() then
                            return;
                        end;
                        btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                            if panel:GetParent() == editPanel.RemovesRight:GetCanvas() then
                                editPanel.RemovesLeft:Add(panel)
                            elseif panel:GetParent() == editPanel.RemovesLeft:GetCanvas() then
                                editPanel.RemovesRight:Add(panel)
                            end;
                            panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                                pnl:SetAlpha(255);
                            end)
                        end)
                    end;
        
                    btnAnwsers.Think = function(btn)
                        btn:SetEnabled(editPanel.RemovesParent:IsEnabled())
                    end;
                end;
            end;

            if TABLE[id].__REMOVE && #TABLE[id].__REMOVE > 0 then
                for k, v in pairs(TABLE[id].__REMOVE) do
                    if D['Anwsers'][v] then
                    local btnAnwsers = editPanel.RemovesLeft:Add('DButton')
                    btnAnwsers:Dock(TOP)
                    btnAnwsers:SetText('['.. v .. ']' .. D['Anwsers'][v].text)
                    btnAnwsers.id = k;
                    btnAnwsers:DockMargin(5, 5, 5, 5)
        
                    btnAnwsers.DoClick = function(btn)
                        if !editPanel.CallsParent:IsEnabled() then
                            return;
                        end;
                        btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                            if panel:GetParent() == editPanel.RemovesRight:GetCanvas() then
                                editPanel.RemovesLeft:Add(panel)
                            elseif panel:GetParent() == editPanel.RemovesLeft:GetCanvas() then
                                editPanel.RemovesRight:Add(panel)
                            end;
                            panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                                pnl:SetAlpha(255);
                            end)
                        end)
                    end;
        
                        btnAnwsers.Think = function(btn)
                            btn:SetEnabled(editPanel.RemovesParent:IsEnabled())
                        end;
                    end;
                end;
            end;

            editPanel.TypeLabel:SetText('Identificator: ' .. id)
            self.GetSelectedTree = btn
        end;

        self:WorkWithInformationLabels(2, id, TABLE[id])
    end;

    if call then
        local ph_call = CountAnwser:AddNode('Call anwsers', 'icon16/feed.png')

        for key, id in pairs(call) do
            for key_id, data in pairs(D['Anwsers']) do
                if id == key_id then
                    local text = CutTextAlittle('[' .. key_id .. ']' .. data.text);
                    local CountAnwser_call = ph_call:AddNode(text, 'icon16/feed.png') 
                    CountAnwser_call.DoClick = function(btn)
                        self:WorkWithInformationLabels(2, key_id, data)
                    end;
                end;
            end;
        end;
    end;
    if remove then
        local ph_remove = CountAnwser:AddNode('Remove anwsers', 'icon16/cancel.png')

        for key, id in pairs(remove) do
            for key_id, data in pairs(D['Anwsers']) do
                if id == key_id then
                    local text = CutTextAlittle('[' .. key_id .. ']' .. data.text);
                    local CountAnwser_remove = ph_remove:AddNode(text, 'icon16/cancel.png')  
                    CountAnwser_remove.DoClick = function(btn)
                        self:WorkWithInformationLabels(2, key_id, data)
                    end;
                end;
            end;
        end;
    end;
    if nextDialogue then
        local ph_nextDialogue = CountAnwser:AddNode('Next dialogue', 'icon16/help.png')

        if D['Dialogues'][nextDialogue] then
            local text = CutTextAlittle('[' .. nextDialogue .. ']' .. D['Dialogues'][nextDialogue].text)
            local CountAnwser_dialogue_next = ph_nextDialogue:AddNode(text, 'icon16/help.png')
            CountAnwser_dialogue_next.DoClick = function(btn)
                self:WorkWithInformationLabels(1, nextDialogue, D['Dialogues'][nextDialogue])
            end;
        end;
    end;

end;

function PANEL:RefreshTrees(type, id, default)
    local D = PLUGIN.dialogueCurrent
    local DIALOGUES_ONSHOW = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 0 ):GetChildNode(0);
    local ANWSERS_ONSHOW = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 0 ):GetChildNode(1);

    local DIALOGUES = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 1 ):GetChildNode(0)
    local ANWSERS = self.ContainTree:GetCanvas():GetChild(0):GetChildNode( 1 ):GetChildNode(1)
    -- uff, ugly ><
   
    if default then
        if type == 'Dialogues' then
            self:CreateDialoguesTree(id, D[type], DIALOGUES_ONSHOW)
            self:CreateDialoguesTree(id, D[type], DIALOGUES)
        else
            self:CreateAnwsersTree(id, D[type], ANWSERS_ONSHOW)
            self:CreateAnwsersTree(id, D[type], ANWSERS)
        end;
    elseif !default then
        if type == 'Dialogues' then
            self:CreateDialoguesTree(id, D[type], DIALOGUES)
        else
            self:CreateAnwsersTree(id, D[type], ANWSERS)
        end;
    end;

end;

function PANEL:WorkWithInformationLabels(type, id, TABLE)
    -- 1 = dialogue;
    -- 2 = anwser;
    self.ContainDescription:ActivatePanel()
    
    if type == 1 then
        self.ContainDescriptionID:SetText('ID: ' .. id)
        self.ContainDescriptionText:SetText('Text: ' .. TABLE.text )

        self.ContainDescriptionID:SetVisible(true);
        self.ContainDescriptionText:SetVisible(true);
        self.ContainDescriptionCall:SetVisible(false)
        self.ContainDescriptionRemove:SetVisible(false)
        self.ContainDescriptionNext:SetVisible(false)        
    elseif type == 2 then
        self.ContainDescriptionID:SetText('ID: ' .. id)
        self.ContainDescriptionText:SetText('Text: ' .. TABLE.text )
        local nextDialgue = '';
        
        if TABLE.__CALL then
            local callAnwser = '';
            for k, v in pairs(TABLE.__CALL) do
                callAnwser = v .. ', ' .. callAnwser
            end;
            self.ContainDescriptionCall:SetText('Call anwsers: '..callAnwser)
            self.ContainDescriptionCall:SetVisible(true)
        end;

        if TABLE.__REMOVE then
            local removeAnwser = '';
            for k, v in pairs(TABLE.__REMOVE) do
                removeAnwser = v .. ', ' .. removeAnwser
            end;
            self.ContainDescriptionRemove:SetText('Remove anwsers: '..removeAnwser)
            self.ContainDescriptionRemove:SetVisible(true)
        end;
        if TABLE.__DIALOGUE then
            self.ContainDescriptionNext:SetText('Calls dialogue: '..TABLE.__DIALOGUE)
            self.ContainDescriptionNext:SetVisible(true)  
        end;

        self.ContainDescriptionID:SetVisible(true);
        self.ContainDescriptionText:SetVisible(true);
    end;

end;

function CutTextAlittle(text)
    if string.len(text) > 15 then text = string.sub(text, 1, 15) .. '...' end;

    return text
end;

vgui.Register( "TalkerSettingsPanel", PANEL, "EditablePanel" )

--[[ Add panel ]]--

local PANEL = {};

function PANEL:Init() 
    self.FirstBuffer = {}

    local D = PLUGIN.dialogueCurrent

    self.ScrollPanel = self:Add('DScrollPanel')
    self.ScrollPanel:Dock(FILL)    

    self.label = self.ScrollPanel:Add("DLabel")
    self.label:SetText('Choose type: ')
    self.label:Dock(TOP) self.label:SetContentAlignment(5)

    self.GetType = self.ScrollPanel:Add("DComboBox")
    self.GetType:Dock(TOP);
    self.GetType:AddChoice('Dialogues', 1, true);
    self.GetType:AddChoice('Anwsers', 2)

    timer.Simple(0.1, function()
        self.GetType:ChooseOptionID( 1 )
    end);

    self.TypeLabel = self.ScrollPanel:Add("DLabel")
    self.TypeLabel:SetText('Next ID: ' .. #D[self.GetType:GetValue()] + 1)
    self.TypeLabel:Dock(TOP) self.TypeLabel:SetContentAlignment(5)

    self.label = self.ScrollPanel:Add("DLabel")
    self.label:SetText('Edit text: ')
    self.label:Dock(TOP) self.label:SetContentAlignment(5)

    self.targetText = self.ScrollPanel:Add('DTextEntry')
    self.targetText:Dock(TOP);
    self.targetText:SetMultiline(true)
    self.targetText:SetTall(200)

    self.targetText.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.targetText.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.CallsLabel = self.ScrollPanel:Add("DLabel")
    self.CallsLabel:SetText("Choose calls: ")
    self.CallsLabel:Dock(TOP) self.CallsLabel:SetContentAlignment(5)

    self.CallsParent = self.ScrollPanel:Add('Panel')
    self.CallsParent:Dock(TOP)
    self.CallsParent:SetTall(250)

    self.CallsParent.Paint = function(s, w, h)
        if !s:IsEnabled() then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(25, 25, 25) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
    end;

    self.callsLeft = self.CallsParent:Add('DScrollPanel')
    self.callsLeft:Dock(LEFT)
    self.callsLeft:SetWide(135)

    self.label = self.callsLeft:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Added: ')
    self.label:SetContentAlignment(5)

    self.callsRight = self.CallsParent:Add('DScrollPanel')
    self.callsRight:Dock(LEFT)
    self.callsRight:SetWide(130)

    self.label = self.callsRight:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Available: ')
    self.label:SetContentAlignment(5)

    if D['Anwsers'] then
        for k, v in pairs(D['Anwsers']) do
            local btnAnwsers = self.callsRight:Add('DButton')
            btnAnwsers:Dock(TOP)
            btnAnwsers:SetText('['.. k .. ']' .. v.text)
            btnAnwsers.id = k;
            btnAnwsers:DockMargin(5, 5, 5, 5)
            btnAnwsers:DockPadding(5, 5, 5, 5)

            btnAnwsers.DoClick = function(btn)
                if !self.CallsParent:IsEnabled() then
                    return;
                end;
                btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                    if panel:GetParent() == self.callsRight:GetCanvas() then
                        self.callsLeft:Add(panel)
                    elseif panel:GetParent() == self.callsLeft:GetCanvas() then
                        self.callsRight:Add(panel)
                    end;
                    panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                        pnl:SetAlpha(255);
                    end)
                end)
            end;

            btnAnwsers.Think = function(btn)
                btn:SetEnabled(self.CallsParent:IsEnabled())
            end;
       end;
    end;

    self.RemovesLabel = self.ScrollPanel:Add("DLabel")
    self.RemovesLabel:SetText("Choose removes: ")
    self.RemovesLabel:Dock(TOP) self.RemovesLabel:SetContentAlignment(5)

    self.RemovesParent = self.ScrollPanel:Add('Panel')
    self.RemovesParent:Dock(TOP)
    self.RemovesParent:SetTall(250)

    self.RemovesParent.Paint = function(s, w, h)
        if !s:IsEnabled() then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(25, 25, 25) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
    end;

    self.RemovesLeft = self.RemovesParent:Add('DScrollPanel')
    self.RemovesLeft:Dock(LEFT)
    self.RemovesLeft:SetWide(135)

    self.label = self.RemovesLeft:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Added: ')
    self.label:SetContentAlignment(5)

    self.RemovesRight = self.RemovesParent:Add('DScrollPanel')
    self.RemovesRight:Dock(LEFT)
    self.RemovesRight:SetWide(130)

    self.label = self.RemovesRight:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Available: ')
    self.label:SetContentAlignment(5)

    if D['Anwsers'] then
        for k, v in pairs(D['Anwsers']) do
            local btnAnwsers = self.RemovesRight:Add('DButton')
            btnAnwsers:Dock(TOP)
            btnAnwsers:SetText('['.. k .. ']' .. v.text)
            btnAnwsers.id = k;
            btnAnwsers:DockPadding(5, 5, 5, 5)
            btnAnwsers:DockMargin(5, 5, 5, 5)

            btnAnwsers.DoClick = function(btn)
                if !self.CallsParent:IsEnabled() then
                    return;
                end;
                btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                    if panel:GetParent() == self.RemovesRight:GetCanvas() then
                        self.RemovesLeft:Add(panel)
                    elseif panel:GetParent() == self.RemovesLeft:GetCanvas() then
                        self.RemovesRight:Add(panel)
                    end;
                    panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                        pnl:SetAlpha(255);
                    end)
                end)
            end;

            btnAnwsers.Think = function(btn)
                btn:SetEnabled(self.RemovesParent:IsEnabled())
            end;
        end;

        local itself = self.RemovesRight:Add('DButton')
        itself:Dock(TOP)
        itself:SetText("Itself")
        itself.id = #D[self.GetType:GetValue()];
        itself:DockPadding(5, 5, 5, 5)
        itself:DockMargin(5, 5, 5, 5)

        itself.DoClick = function(btn)
            if !self.CallsParent:IsEnabled() then
                return;
            end;
            btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                if panel:GetParent() == self.RemovesRight:GetCanvas() then
                    self.RemovesLeft:Add(panel)
                elseif panel:GetParent() == self.RemovesLeft:GetCanvas() then
                    self.RemovesRight:Add(panel)
                end;
                panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                    pnl:SetAlpha(255);
                end)
            end)
        end;

        itself.Think = function(btn)
            btn:SetEnabled(self.RemovesParent:IsEnabled())
        end;        
    end;

    self.NextDialogueLabel = self.ScrollPanel:Add("DLabel")
    self.NextDialogueLabel:SetText("Choose dialogue to show next: ")
    self.NextDialogueLabel:Dock(TOP) self.NextDialogueLabel:SetContentAlignment(5)

    self.dialogue = self.ScrollPanel:Add("DNumberWang")
    self.dialogue:Dock(TOP)
    self.dialogue:SetMinMax(0, #D['Dialogues'])
    self.dialogue:HideWang()

    self.dialogue.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.dialogue.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.dialogue.Think = function(wang)
        local value = wang:GetValue()
        if tonumber(value) > #D['Dialogues'] then
            wang:SetValue(#D['Dialogues'])
        elseif tonumber(value) < 0 then
            wang:SetValue(0)
        end;
    end;

    self.label = self.ScrollPanel:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Call quest: ')
    self.label:SetContentAlignment(5)

    local quests = PLUGIN.quests;
    self.callQuest = self.ScrollPanel:Add("DNumberWang")
    self.callQuest:Dock(TOP)
    self.callQuest:SetMinMax(0, #quests)
    self.callQuest:HideWang()
    self.callQuest.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;   
    self.callQuest.Think = function(wang)
        local value = wang:GetValue()
        if tonumber(value) > #quests then
            wang:SetValue(#quests)
        elseif tonumber(value) < 0 then
            wang:SetValue(0)
        end;
    end; 
    
    self.showFirst = self.ScrollPanel:Add('DCheckBoxLabel')
    self.showFirst:SetText('Show on open?')
    self.showFirst:Dock(TOP)

    self.CanClose = self.ScrollPanel:Add('DCheckBoxLabel')
    self.CanClose:SetText('Anwser can finish dialogue?')
    self.CanClose:Dock(TOP)

    self.apply = self.ScrollPanel:Add('DButton')
    self.apply:Dock(TOP);
    self.apply:SetText('Apply')

    self.apply.DoClick = function(btn)
        local type = tostring(self.GetType:GetValue());
        local callTable = self.callsLeft:GetCanvas():GetChildren();
        local removeTable = self.RemovesLeft:GetCanvas():GetChildren();
        local nextID = #D[type] + 1;
        local text = tostring( self.targetText:GetText() )
        local shouldFirst = tobool(self.showFirst:GetChecked());
        local CanFinish = tobool(self.CanClose:GetChecked());
        local nextDialogue = tonumber(self.dialogue:GetValue())
        local CALLQUEST = tonumber(self.callQuest:GetValue())

        local formTable = {
            showFirst = false,
            type = '',
            ID = 0,
            Dialogues = {
                text = '',
                callQuest = 0
            },
            Anwsers = {
                text = '',
                __CALL = {},
                __REMOVE = {},
                __DIALOGUE = 0,
                CanClose = false
            }
        }

        formTable[type]['callQuest'] = CALLQUEST
        formTable[type]['text'] = text;
        formTable[type]['CanClose'] = CanFinish;
        formTable['ID'] = nextID;
        formTable['showFirst'] = shouldFirst;
        formTable['type'] = type;
        if type == 'Anwsers' then
            for k, v in pairs(callTable) do
                table.insert(formTable[type]['__CALL'], v.id)
            end;

            for k, v in pairs(removeTable) do
                table.insert(formTable[type]['__REMOVE'], v.id)
            end;

            formTable[type]['__DIALOGUE'] = nextDialogue;
        end;

        -- Validation --
        if text == '' or text == nil then
            self.targetText.showErr = true;
            surface.PlaySound('buttons/button8.wav')
            self.ScrollPanel:ScrollToChild( self.targetText )
            return;
        end;

        -- if type == 'Anwsers' then
        --     if !D['Dialogues'][nextDialogue] && !shouldFirst then
        --         self.dialogue.showErr = true;
        --         surface.PlaySound('buttons/button8.wav')
        --         return;
        --     end;
        -- end;
        -- Validation --

        netstream.Start('SendToTalker_add', formTable);
        surface.PlaySound('buttons/button9.wav')
        self.targetText:SetText('')
        self.showFirst:SetValue(0)
        self.CanClose:SetValue(0)
        self.dialogue:SetValue(0)
        self.callQuest:SetValue(0)

        self.TypeLabel:SetText('Next ID: ' .. #D[self.GetType:GetValue()] + 1)
        PLUGIN.dialogueCurrent[ type ][ nextID ] = {};
        for k, v in pairs(formTable[type]) do
            PLUGIN.dialogueCurrent[ type ][ nextID ][ k ] = v;
        end;
        if formTable['showFirst'] then
            table.insert(PLUGIN.dialogueCurrent[ 'callByDefault' ][ type ], nextID);
        end;

        self.MainParent:RefreshTrees( type, nextID, shouldFirst )
    end; 

    self:AddToFirstBuffer(self.CallsParent)
    self:AddToFirstBuffer(self.RemovesParent)
    self:AddToFirstBuffer(self.CallsLabel)
    self:AddToFirstBuffer(self.RemovesLabel)
    self:AddToFirstBuffer(self.dialogue)
    self:AddToFirstBuffer(self.NextDialogueLabel)
    self:AddToFirstBuffer(self.CanClose)

    self.GetType.OnSelect = function(combo, index, value, data)
        self.TypeLabel:SetText('Next ID: ' .. #D[self.GetType:GetValue()] + 1)
        if value == 'Dialogues' then
            for k, v in pairs(self.FirstBuffer) do
                v:SetEnabled(false)
                v:SetAlpha(100)
            end;
            self.callQuest:SetEnabled(true)
            self.callQuest:SetAlpha(255)
        elseif value == 'Anwsers' then
            for k, v in pairs(self.FirstBuffer) do
                v:SetEnabled(true)
                v:SetAlpha(255)
            end;
            self.callQuest:SetEnabled(false)
            self.callQuest:SetAlpha(100)
        end;
    end;

    self.ScrollPanel:DockMargin(0, 0, 0, 10)
    for k, v in pairs(self.ScrollPanel:GetCanvas():GetChildren()) do
        v:DockMargin(5, 5, 5, 5)
    end;

end;

function PANEL:AddToFirstBuffer(what)
    self.FirstBuffer[#self.FirstBuffer + 1] = what;
end;

vgui.Register( "TalkerSettingsPanel_ADD", PANEL, "EditablePanel" )

--[[ Edit panel ]]--

local PANEL = {};

function PANEL:Init() 
    self.FirstBuffer = {}
    local D = PLUGIN.dialogueCurrent

    self.ScrollPanel = self:Add('DScrollPanel')
    self.ScrollPanel:Dock(FILL)

    self.ChooseCorrectly = self.ScrollPanel:Add('DLabel')
    self.ChooseCorrectly:Dock(TOP)
    self.ChooseCorrectly:SetText('Choose anwser or dialogue from the left panel first.')
    self.ChooseCorrectly:SetWrap(true);
    self.ChooseCorrectly:SetTextColor(Color(255, 100, 100))
    self.ChooseCorrectly:SetTall(40)

    self.TypeLabel = self.ScrollPanel:Add("DLabel")
    self.TypeLabel:SetText('Identificator: ---')
    self.TypeLabel:Dock(TOP) self.TypeLabel:SetContentAlignment(5)

    self.label = self.ScrollPanel:Add("DLabel")
    self.label:SetText('Edit text: ')
    self.label:Dock(TOP) self.label:SetContentAlignment(5)

    self.targetText = self.ScrollPanel:Add('DTextEntry')
    self.targetText:Dock(TOP);
    self.targetText:SetMultiline(true)
    self.targetText:SetTall(200)

    self.targetText.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.targetText.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.CallsLabel = self.ScrollPanel:Add("DLabel")
    self.CallsLabel:SetText("Choose calls: ")
    self.CallsLabel:Dock(TOP) self.CallsLabel:SetContentAlignment(5)

    self.CallsParent = self.ScrollPanel:Add('Panel')
    self.CallsParent:Dock(TOP)
    self.CallsParent:SetTall(250)

    self.CallsParent.Paint = function(s, w, h)
        if !s:IsEnabled() then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(25, 25, 25) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
    end;

    self.callsLeft = self.CallsParent:Add('DScrollPanel')
    self.callsLeft:Dock(LEFT)
    self.callsLeft:SetWide(135)

    self.label = self.callsLeft:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Added: ')
    self.label:SetContentAlignment(5)

    self.callsRight = self.CallsParent:Add('DScrollPanel')
    self.callsRight:Dock(LEFT)
    self.callsRight:SetWide(130)

    self.label = self.callsRight:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Available: ')
    self.label:SetContentAlignment(5)

    self.RemovesLabel = self.ScrollPanel:Add("DLabel")
    self.RemovesLabel:SetText("Choose removes: ")
    self.RemovesLabel:Dock(TOP) self.RemovesLabel:SetContentAlignment(5)

    self.RemovesParent = self.ScrollPanel:Add('Panel')
    self.RemovesParent:Dock(TOP)
    self.RemovesParent:SetTall(250)

    self.RemovesParent.Paint = function(s, w, h)
        if !s:IsEnabled() then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(25, 25, 25) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
    end;

    self.RemovesLeft = self.RemovesParent:Add('DScrollPanel')
    self.RemovesLeft:Dock(LEFT)
    self.RemovesLeft:SetWide(135)

    self.label = self.RemovesLeft:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Added: ')
    self.label:SetContentAlignment(5)

    self.RemovesRight = self.RemovesParent:Add('DScrollPanel')
    self.RemovesRight:Dock(LEFT)
    self.RemovesRight:SetWide(130)

    self.label = self.RemovesRight:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Available: ')
    self.label:SetContentAlignment(5)

    self.NextDialogueLabel = self.ScrollPanel:Add("DLabel")
    self.NextDialogueLabel:SetText("Choose dialogue to show next: ")
    self.NextDialogueLabel:Dock(TOP) self.NextDialogueLabel:SetContentAlignment(5)

    self.dialogue = self.ScrollPanel:Add("DNumberWang")
    self.dialogue:Dock(TOP)
    self.dialogue:SetMinMax(0, #D['Dialogues'])
    self.dialogue:HideWang()

    self.dialogue.OnValueChanged = function(wang, value)
        if tonumber(value) > #D['Dialogues'] then
            wang:SetValue(#D['Dialogues'])
        elseif tonumber(value) < 0 then
            wang:SetValue(0)
        end;
    end;

    self.dialogue.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.dialogue.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.dialogue.Think = function(wang)
        local value = wang:GetValue()
        if tonumber(value) > #D['Dialogues'] then
            wang:SetValue(#D['Dialogues'])
        elseif tonumber(value) < 0 then
            wang:SetValue(0)
        end;
    end;

    local quests = PLUGIN.quests;
    self.callQuest = self.ScrollPanel:Add("DNumberWang")
    self.callQuest:Dock(TOP)
    self.callQuest:SetMinMax(0, #quests)
    self.callQuest:HideWang()
    self.callQuest.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end; 
    
    self.showFirst = self.ScrollPanel:Add('DCheckBoxLabel')
    self.showFirst:SetText('Show on open?')
    self.showFirst:Dock(TOP)

    self.CanClose = self.ScrollPanel:Add('DCheckBoxLabel')
    self.CanClose:SetText('Anwser can finish dialogue?')
    self.CanClose:Dock(TOP)

    self.apply = self.ScrollPanel:Add('DButton')
    self.apply:Dock(TOP);
    self.apply:SetText('Edit')

    self.apply.DoClick = function(btn)
        local tree = self.MainParent:GetChild(1):GetChild(0);
        local id = tree:GetSelectedItem().uniqueID;
        local callTable = self.callsLeft:GetCanvas():GetChildren();
        local removeTable = self.RemovesLeft:GetCanvas():GetChildren();
        local text = tostring( self.targetText:GetText() )
        local shouldFirst = tobool(self.showFirst:GetChecked());
        local nextDialogue = tonumber(self.dialogue:GetValue())        
        local CanFinish = tobool(self.CanClose:GetChecked());
        local CALLQUEST = tonumber(self.callQuest:GetValue());

        local type = ''
        if self.CallsParent:IsEnabled() then
            type = "Anwsers"
        else
            type = "Dialogues"
        end;

        local formTable = {
            showFirst = false,
            type = '',
            ID = 0,
            Dialogues = {
                text = '',
                callQuest = 0
            },
            Anwsers = {
                text = '',
                __CALL = {},
                __REMOVE = {},
                __DIALOGUE = 0,
                CanClose = false
            }
        }

        formTable[type]['callQuest'] = CALLQUEST
        formTable[type]['text'] = text;
        formTable[type]['CanClose'] = CanFinish;
        formTable['ID'] = id;
        formTable['showFirst'] = shouldFirst;
        formTable['type'] = type;
        if type == 'Anwsers' then
            for k, v in pairs(callTable) do
                if v.id then
                    table.insert(formTable[type]['__CALL'], v.id)
                end;
            end;

            for k, v in pairs(removeTable) do
                if v.id then
                    table.insert(formTable[type]['__REMOVE'], v.id)
                end;
            end;

            formTable[type]['__DIALOGUE'] = nextDialogue;
        end;

        if text == '' or text == nil then
            self.targetText.showErr = true;
            surface.PlaySound('buttons/button8.wav')
            self.ScrollPanel:ScrollToChild( self.targetText )
            return;
        end;

        netstream.Start('SendToTalker_edit', formTable);
        surface.PlaySound('buttons/button9.wav')

        if PLUGIN.dialogueCurrent[ type ][ id ] then
            for k, v in pairs(formTable[type]) do
                PLUGIN.dialogueCurrent[ type ][ id ][ k ] = v;
            end;
        end;

    end;

    self:AddToFirstBuffer(self.CallsParent)
    self:AddToFirstBuffer(self.RemovesParent)
    self:AddToFirstBuffer(self.CallsLabel)
    self:AddToFirstBuffer(self.RemovesLabel)
    self:AddToFirstBuffer(self.dialogue)
    self:AddToFirstBuffer(self.NextDialogueLabel)
    self:AddToFirstBuffer(self.CanClose)

    self.ScrollPanel:DockMargin(0, 0, 0, 10)
    for k, v in pairs(self.ScrollPanel:GetCanvas():GetChildren()) do
        v:DockMargin(5, 5, 5, 5)

        if v != self.ChooseCorrectly then
            v:SetAlpha(100)
            v:SetEnabled(false)
        end;
    end;
end;

function PANEL:AddToFirstBuffer(what)
    self.FirstBuffer[#self.FirstBuffer + 1] = what;
end;


vgui.Register( "TalkerSettingsPanel_EDIT", PANEL, "EditablePanel" )

local PANEL = {};

function PANEL:Init() 
    --[[ model here ]]--
    self.talkerModel = self:Add( "ixModelPanel" )
    self.talkerModel:SetModel('models/error.mdl')
    self.talkerModel:Dock(LEFT)
    self.talkerModel:SetWidth(175)
    self.talkerModel:SetCamPos( Vector(30, 30, 45) )

    self.Settings = self:Add('DScrollPanel')
    self.Settings:Dock(FILL)

    self.label = self.Settings:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Talker name: ')
    self.label:SetContentAlignment(5)

    self.talkerName = self.Settings:Add('DTextEntry')
    self.talkerName:Dock(TOP);
    self.talkerName:SetText('John Doe')
    self.talkerName.Paint = function(s, w, h)
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self.Settings:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Model path: ')
    self.label:SetContentAlignment(5)

    self.modelPath = self.Settings:Add('DTextEntry')
    self.modelPath:Dock(TOP);
    self.modelPath:SetText('')
    self.modelPath.Paint = function(s, w, h)
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;
    self.modelPath.OnChange = function(wang)
        self.talkerModel:SetModel(tostring(wang:GetText()), self.skinSelector:GetValue())
        self.skinSelector:SetMax( self.talkerModel.Entity:SkinCount() )
    end;

    self.label = self.Settings:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Sequence number: ')
    self.label:SetContentAlignment(5)

    self.sequenceWang = self.Settings:Add("DNumSlider")
    self.sequenceWang:Dock(TOP)
    self.sequenceWang:SetMinMax(0, 500)
    self.sequenceWang:SetDecimals( 0 )
    self.sequenceWang:SetValue(4)
    self.sequenceWang.TextArea:SetTextColor(Color(255, 255, 255))
    self.sequenceWang.OnValueChanged = function(wang, value)
        if self.talkerModel.Entity then
            self.talkerModel.Entity:ResetSequence( tonumber(value) )
        end;
    end;

    self.label = self.Settings:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Choose skin: ')
    self.label:SetContentAlignment(5)

    self.skinSelector = self.Settings:Add("DNumSlider")
    self.skinSelector:Dock(TOP)
    self.skinSelector:SetMin(1)
    self.skinSelector:SetValue(1)
    self.skinSelector:SetDecimals( 0 )
    self.skinSelector.TextArea:SetTextColor(Color(255, 255, 255))
    self.skinSelector.OnValueChanged = function(wang, val)
        self.talkerModel:SetModel(self.talkerModel:GetModel(), tonumber(val))
    end;

    self.BodyGroupTree = self.Settings:Add('DTree')
    self.BodyGroupTree:Dock(TOP)
    self.BodyGroupTree:SetTall(250)
    self.BodyGroupTree:DockMargin(5, 5, 5, 5)
    self.BodyGroupTree.Paint = function(s, w, h)
        draw.RoundedBox(1, 0, 0, w, h, Color( 40, 40, 40 ))
    end;
    
    self.label = self.Settings:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('[Settings will apply on close]')
    self.label:SetTextColor( Color(150, 150, 255) )
    self.label:SetContentAlignment(5)
    
    timer.Simple(0.5, function()
        
        for i = 1, self.talkerModel.Entity:GetNumBodyGroups() - 1 do
            if self.bodyGroupText[i] == nil then
                self.bodyGroupText[i] = 0;
            end;

            local bodygroup = self.talkerModel.Entity:GetBodygroupName( i );
            local BodyGroup = self.BodyGroupTree:AddNode( bodygroup, 'icon16/page_white_width.png' )

            for x = 0, self.talkerModel.Entity:GetBodygroupCount( i ) - 1 do
                local SubBodyGroup = BodyGroup:AddNode( x, 'icon16/page_white_width.png' )

                SubBodyGroup.DoClick = function(btn)
                    self.bodyGroupText[i + 1] = x
                    self.talkerModel.Entity:SetBodygroup(i, x)
                end;
            end;
        end;

    end)

    for k, v in pairs(self.Settings:GetCanvas():GetChildren()) do
        v:DockMargin(5, 0, 5, 0)
    end;
end;

function PANEL:SetBaseData( name, model, sequence, skin, bodygroups )
    self.talkerName:SetText(name or 'John Doe')
    self.modelPath:SetText(model or 'models/error.mdl')
    self.sequenceWang:SetValue(sequence or 4)
    self.skinSelector:SetValue(skin or 1)
    self.bodyGroupText = string.Explode("", bodygroups);
    self.talkerModel:SetModel(self.modelPath:GetText(), self.skinSelector:GetValue(), bodygroups)
end;

vgui.Register( "TalkerSettings_Settings", PANEL, "EditablePanel" )