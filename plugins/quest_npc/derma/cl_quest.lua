local PANEL = {};
local PLUGIN = PLUGIN;

function PANEL:Init() 
    self:SetTall(75);
    self:Dock(TOP);
end;

function PANEL:Paint( w, h )
    self:CreateCloseDebug()
end;

function PANEL:Populate()
   
    self.image = self:Add('DImage')
    self.image:Dock(LEFT)
    self.image:SetImage('materials/quest_icon/quest_item.png')
    self.image:SetWidth(100)
    self.image:DockMargin(5, 5, 5, 5)

    self.description = self:Add('DScrollPanel')
    self.description:Dock(LEFT)
    self.description:SetWidth(400)
    self.description:DockMargin(5, 5, 5, 5)

    self.descriptionTitle = self.description:Add('DLabel')
    self.descriptionTitle:Dock(TOP)
    self.descriptionTitle:SetText(self:GetTitle())
    self.descriptionTitle:SetTextColor(Color(255, 173, 44))
    self.descriptionTitle:SetFont('R_chatFont')
    self.descriptionTitle:SetWrap(true)
    self.descriptionTitle:SetAutoStretchVertical(true)
    self.descriptionTitle:SizeToContents()

    self.descriptionLabel = self.description:Add('DLabel')
    self.descriptionLabel:Dock(FILL)
    self.descriptionLabel:SetText(self:GetDescription())
    self.descriptionLabel:SetFont('R_chatFont')
    self.descriptionLabel:SetWrap(true)
    self.descriptionLabel:SetAutoStretchVertical(true)
    self.descriptionLabel:SizeToContents()

    self.buttonsList = self:Add('Panel')
    self.buttonsList:Dock(LEFT)
    self.buttonsList:SetWidth(120)
    self.buttonsList:DockMargin(5, 5, 5, 5)

    self.Accept = self.buttonsList:Add('DButton')
    self.Accept:SetText('Accept')
    self.Accept:Center()
    self.Accept:AlignTop( 20 )
    self.Accept:SetFont('R_chatFont')
    self.Accept:SetTextColor( Color(255, 255, 255) )
    self.Accept.noneColor = Color(255, 255, 255):ToTable()

    if LocalPlayer():HasQuest(self:GetQuestID()) then
        self.Accept:SetText('Finish')
    end;

    self.Accept.DoClick = function(btn)
        local hasQuest = LocalPlayer():HasQuest(self:GetQuestID())
        local canFinishQuest = LocalPlayer():CanFinishQuest(self:GetQuestID())
        
        if !hasQuest then
            surface.PlaySound('buttons/button16.wav')
            btn:AlphaTo(0, 0.5, 0, function(tbl, pnl)
                pnl:SetText('Finish')
                pnl:AlphaTo(255, 0.2, 0, function(alphatbl, but) 
                    netstream.Start('AddQuestToPlayer', self:GetQuestID())
                end)
            end)

            return;
        end;

        if hasQuest && canFinishQuest then
            surface.PlaySound('buttons/button16.wav')
            btn:AlphaTo(0, 0.5, 0, function(tbl, pnl)
                pnl:SetText('Accept')
                pnl:SetAlpha(0)
        
                netstream.Start('FinishQuest', self:GetQuestID())

                if PLUGIN.quests[self:GetQuestID()].ShowOnce then
                    self:SetEnabled(false)
                    self:AlphaTo(0, 0.5, 0, function(tbl, pnl)
                        pnl:Remove();
                    end)
                    return;
                end;

                pnl:AlphaTo(255, 0.2, 0, function(alphatbl, but)
                    but:SetAlpha(255)
                end)
            end)
        end;
    end;

    timer.Simple(25, function()
        if !self:IsValid() then
            return;
        end;

        self:AlphaTo(0, 1, 0, function(tbl, pnl)
            self:SetAlpha(0)
            self:Remove();
        end)
    end)

    self.Accept.Paint = function(s, w, h)
        if LocalPlayer():HasQuest(self:GetQuestID()) && !LocalPlayer():CanFinishQuest(self:GetQuestID()) then
            s:SetEnabled(false);
            s:SetAlpha(100);
            s:SetTextColor( Color(255, 255, 255) )

            return;
        end;

        local frameTime = 600 * FrameTime()
        if s:IsHovered() then
            s.noneColor[1] = math.Approach( s.noneColor[1], 255, frameTime )
            s.noneColor[2] = math.Approach( s.noneColor[2], 173, frameTime )
            s.noneColor[3] = math.Approach( s.noneColor[3], 44, frameTime )
        else
            s.noneColor[1] = math.Approach( s.noneColor[1], 255, frameTime )
            s.noneColor[2] = math.Approach( s.noneColor[2], 255, frameTime )
            s.noneColor[3] = math.Approach( s.noneColor[3], 255, frameTime )
        end;
        s:SetTextColor( Color(s.noneColor[1], s.noneColor[2], s.noneColor[3]) )        
    end;

end;

function PANEL:AddTitle(title)
    self.gettitle = title;
end;

function PANEL:AddDescription(description)
    self.desc = description
end;

function PANEL:SetQuestID( id )
    self.id = id;
end;
function PANEL:GetTitle()
    return self.gettitle;
end;

function PANEL:GetDescription()
    return self.desc;
end;

function PANEL:GetQuestID()
    return self.id;
end;

function PANEL:Paint(w, h)
    draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
end;

vgui.Register( "Quest", PANEL, "Panel" )

local PANEL = {};

function PANEL:Init()

    self.SettingsList = self:Add('Panel')
    self.SettingsList:Dock(TOP)
    self.SettingsList:SetTall(600)
    self.SettingsList:DockMargin(0, 5, 5, 5)
    self.SettingsList.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40))
    end;

    self.ButtonList = self:Add('Panel')
    self.ButtonList:Dock(TOP)
    self.ButtonList:SetTall(113)
    self.ButtonList:DockMargin(0, 0, 5, 0)
    self.ButtonList.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40))
    end;

    self.addButton = self.ButtonList:Add('DButton')
    self.addButton:Center()
    self.addButton:AlignLeft(15)
    self.addButton:SetWidth(100)
    self.addButton:SetText('Add quest...')

    self.addButton.DoClick = function(btn)
        if self.RemovePanel then self.RemovePanel:Remove(); self.RemovePanel = nil; end;
        if self.EditPanel then self.EditPanel:Remove(); self.EditPanel = nil; end;

        if !self.AddPanel then
            self.AddPanel = self.SettingsList:Add('AddQuest')
            self.AddPanel:Dock(FILL)
            
            self.AddPanel.MainParent = self;
        end;
    end;
    
    self.editButton = self.ButtonList:Add('DButton')
    self.editButton:Center()
    self.editButton:AlignLeft(120)
    self.editButton:SetWidth(100)
    self.editButton:SetText('Edit quest...')

    self.editButton.DoClick = function(btn)
        if self.AddPanel then self.AddPanel:Remove(); self.AddPanel = nil; end;
        if self.RemovePanel then self.RemovePanel:Remove(); self.RemovePanel = nil; end;

        if !self.EditPanel then
            self.EditPanel = self.SettingsList:Add('EditQuest')
            self.EditPanel:Dock(FILL)

            self.EditPanel.MainParent = self;
        end;
    end;

    self.removeButton = self.ButtonList:Add('DButton')
    self.removeButton:Center()
    self.removeButton:SetWidth(100)
    self.removeButton:AlignLeft(225)
    self.removeButton:SetText('Remove quest...')

    self.removeButton.DoClick = function(btn)
        if self.AddPanel then self.AddPanel:Remove(); self.AddPanel = nil; end;
        if self.EditPanel then self.EditPanel:Remove(); self.EditPanel = nil; end;
        local item = self:GetParent().ContainTree:GetSelectedItem();
        
        if !self.RemovePanel then
            self.RemovePanel = self.SettingsList:Add('DLabel')
            self.RemovePanel:Dock(TOP)
            self.RemovePanel:SetText('Select anwser or dialogue on the left panel.')
            self.RemovePanel:SetWrap(true)
        end;

        if item && item.uniqueID then
            Derma_Query( "Press yes or no", "Delete?", "Yes", function()
                item:Remove()
                netstream.Start('RemoveQuest', item.uniqueID)
            end,
            "No",
            function()
            end)
        end;
    end;
end;

vgui.Register( "QuestPanel", PANEL, "EditablePanel" )

local PANEL = {};

function PANEL:Init() 
    local quests = PLUGIN.quests;

    self.NextID = self:Add('DLabel')
    self.NextID:Dock(TOP)
    self.NextID:SetText('Quest ID: ' .. #quests + 1)
    self.NextID:SetContentAlignment(5)

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Quest title: ')
    self.label:SetContentAlignment(5)

    self.titleText = self:Add('DTextEntry')
    self.titleText:Dock(TOP);
    self.titleText:SetTall(20)
    self.titleText.OnGetFocus = function(self)
        self.showErr = false;
    end
    self.titleText.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Quest description: ')
    self.label:SetContentAlignment(5)

    self.DescriptionText = self:Add('DTextEntry')
    self.DescriptionText:Dock(TOP);
    self.DescriptionText:SetTall(100)
    self.DescriptionText:SetMultiline(true)
    self.DescriptionText.OnGetFocus = function(self)
        self.showErr = false;
    end
    self.DescriptionText.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Kill npcs: ')
    self.label:SetContentAlignment(5)

    self.TextPanel = self:Add('Panel')
    self.TextPanel:Dock(TOP)
    self.TextPanel:SetTall(25)

    self.label = self.TextPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('NPC: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.npcClass = self.TextPanel:Add('DTextEntry')
    self.npcClass:Dock(LEFT);
    self.npcClass:SetWidth(150)
    self.npcClass.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self.TextPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('Amount: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.npcAmount = self.TextPanel:Add('DNumberWang')
    self.npcAmount:Dock(LEFT);
    self.npcAmount:SetWidth(25)
    self.npcAmount:SetMinMax(1, 25)
    self.npcAmount:SetValue(1)
    self.npcAmount.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.buttonApply = self.TextPanel:Add('DButton')
    self.buttonApply:SetText('ADD')
    self.buttonApply:Dock(LEFT)
    self.buttonApply:DockMargin(5, 0, 0, 0)

    self.buttonApply.DoClick = function(btn)
        if self.npcAmount:GetValue() == 0 or self.npcClass:GetText() == "" then return end;

        local newLine = self.npcsList:AddLine(self.npcClass:GetText(), self.npcAmount:GetValue())
        newLine.npc = self.npcClass:GetText();
        newLine.amount = self.npcAmount:GetValue()

        newLine.OnMousePressed = function(btn, key)
            local menu = DermaMenu() 
            menu:AddOption( "Remove", function() 
                btn:Remove()
            end)
            menu:Open()
        end;
    end;

    self.npcsList = self:Add('DListView')
    self.npcsList:Dock( TOP )
    self.npcsList:SetTall(100)
    self.npcsList:DockMargin(5, 5, 5, 5)
    local column1 = self.npcsList:AddColumn( "NPC" )
    column1.Header:SetTextColor( Color(0, 0, 0) )
    local column2 = self.npcsList:AddColumn( "Amount" )
    column2.Header:SetTextColor( Color(0, 0, 0) )

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Collect items: ')
    self.label:SetContentAlignment(5)

    self.TextPanelItems = self:Add('Panel')
    self.TextPanelItems:Dock(TOP)
    self.TextPanelItems:SetTall(25)

    self.label = self.TextPanelItems:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('ID: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.itemID = self.TextPanelItems:Add('DTextEntry')
    self.itemID:Dock(LEFT);
    self.itemID:SetWidth(150)
    self.itemID.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self.TextPanelItems:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('Amount: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.itemAmount = self.TextPanelItems:Add('DNumberWang')
    self.itemAmount:Dock(LEFT);
    self.itemAmount:SetWidth(25)
    self.itemAmount:SetMinMax(1, 25)
    self.itemAmount:SetValue(1)
    self.itemAmount.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.ItemApply = self.TextPanelItems:Add('DButton')
    self.ItemApply:SetText('ADD')
    self.ItemApply:Dock(LEFT)
    self.ItemApply:DockMargin(5, 0, 0, 0)
    self.ItemApply.DoClick = function(btn)
        if self.itemAmount:GetValue() == 0 or self.itemID:GetText() == "" then return end;

        local newLine = self.itemsList:AddLine(self.itemID:GetText(), self.itemAmount:GetValue())
        newLine.item = self.itemID:GetText();
        newLine.amount = self.itemAmount:GetValue()
        newLine.OnMousePressed = function(btn, key)
            local menu = DermaMenu() 
            menu:AddOption( "Remove", function() 
                btn:Remove()
            end)
            menu:Open()
        end;
    end;

    self.itemsList = self:Add('DListView')
    self.itemsList:Dock( TOP )
    self.itemsList:SetTall(100)
    self.itemsList:DockMargin(5, 5, 5, 5)
    local column1 = self.itemsList:AddColumn( "Name" )
    column1.Header:SetTextColor( Color(0, 0, 0) )
    local column2 = self.itemsList:AddColumn( "Amount" )
    column2.Header:SetTextColor( Color(0, 0, 0) )

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Give items: ')
    self.label:SetContentAlignment(5)

    self.RewardPanel = self:Add('Panel')
    self.RewardPanel:Dock(TOP)
    self.RewardPanel:SetTall(25)

    self.label = self.RewardPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('ID: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.giveItemID = self.RewardPanel:Add('DTextEntry')
    self.giveItemID:Dock(LEFT);
    self.giveItemID:SetWidth(150)
    self.giveItemID.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;
    self.giveItemID.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.label = self.RewardPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('Amount: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.giveItemAmount = self.RewardPanel:Add('DNumberWang')
    self.giveItemAmount:Dock(LEFT);
    self.giveItemAmount:SetWidth(25)
    self.giveItemAmount:SetMinMax(1, 25)
    self.giveItemAmount:SetValue(1)
    self.giveItemAmount.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;
    self.giveItemAmount.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.ApplyReward = self.RewardPanel:Add('DButton')
    self.ApplyReward:SetText('ADD')
    self.ApplyReward:Dock(LEFT)
    self.ApplyReward:DockMargin(5, 0, 0, 0)
    self.ApplyReward.DoClick = function(btn)
        if self.giveItemAmount:GetValue() == 0 or self.giveItemID:GetText() == "" then return end;

        local newLine = self.rewardList:AddLine(self.giveItemID:GetText(), self.giveItemAmount:GetValue())
        newLine.item = self.giveItemID:GetText();
        newLine.amount = self.giveItemAmount:GetValue()
        newLine.OnMousePressed = function(btn, key)
            local menu = DermaMenu() 
            menu:AddOption( "Remove", function() 
                btn:Remove()
            end)
            menu:Open()
        end;
    end;

    self.rewardList = self:Add('DListView')
    self.rewardList:SetTall(100)
    self.rewardList:Dock( TOP )
    self.rewardList:DockMargin(5, 5, 5, 5)
    local column1 = self.rewardList:AddColumn( "Name" )
    column1.Header:SetTextColor( Color(0, 0, 0) )
    local column2 = self.rewardList:AddColumn( "Amount" )
    column2.Header:SetTextColor( Color(0, 0, 0) )

    self.showQuestOnce = self:Add( "DCheckBoxLabel" )
    self.showQuestOnce:Dock(TOP)
    self.showQuestOnce:SetText("Show quest once ")
    self.showQuestOnce:SetValue( false )
    self.showQuestOnce:DockMargin(5, 5, 5, 5)	
    self.showQuestOnce:SizeToContents()

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Should have quests to show: ')
    self.label:SetContentAlignment(5)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.QuestsDone = self:Add('Panel')
    self.QuestsDone:Dock(TOP)
    self.QuestsDone:SetTall(250)

    self.QuestsDone.Paint = function(s, w, h)
        if !s:IsEnabled() then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(25, 25, 25) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
    end;

    self.questsLeft = self.QuestsDone:Add('DScrollPanel')
    self.questsLeft:Dock(LEFT)
    self.questsLeft:SetWide(170)

    self.label = self.questsLeft:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Added: ')
    self.label:SetContentAlignment(5)

    self.questsRight = self.QuestsDone:Add('DScrollPanel')
    self.questsRight:Dock(LEFT)
    self.questsRight:SetWide(160)

    self.label = self.questsRight:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Available: ')
    self.label:SetContentAlignment(5)

    if quests then
        for k, v in pairs(quests) do
            local questRight = self.questsRight:Add('DButton')
            questRight:Dock(TOP)
            questRight:SetText('['.. k .. ']' .. v.title)
            questRight.id = k;
            questRight:DockMargin(5, 5, 5, 5)
            questRight:DockPadding(5, 5, 5, 5)

            questRight.DoClick = function(btn)
                if !self.QuestsDone:IsEnabled() then return; end;
                btn:AlphaTo(0, 0.5, 0, function(tbl, panel)
                    if panel:GetParent() == self.questsRight:GetCanvas() then
                        self.questsLeft:Add(panel)
                    elseif panel:GetParent() == self.questsLeft:GetCanvas() then
                        self.questsRight:Add(panel)
                    end;
                    panel:AlphaTo(255, 0.5, 0, function(alpha, pnl)
                        pnl:SetAlpha(255);
                    end)
                end)
            end;

            questRight.Think = function(btn)
                btn:SetEnabled(self.QuestsDone:IsEnabled())
            end;
       end;
    end;

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Give money as reward: ')
    self.label:SetContentAlignment(5)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.moneyReward = self:Add('DNumberWang')
    self.moneyReward:Dock(TOP);
    self.moneyReward:SetMinMax(0, 1000)
    self.moneyReward:SetValue(0)
    self.moneyReward.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.Apply = self:Add('DButton')
    self.Apply:SetText('APPLY')
    self.Apply:Dock(TOP)
    self.Apply:DockMargin(5, 5, 5, 5)

    self.Apply.DoClick = function(btn)
        local title = self.titleText:GetText()
        local desc = self.DescriptionText:GetText();
        
        local formTable = {
            ['id'] = #quests + 1,
            ['npcs'] = {},
            ['items'] = {},
            ['reward'] = {},
            ['needsQuest'] = {},
            ['title'] = title,
            ['description'] = desc,
            ['money'] = self.moneyReward:GetValue(),
            ['ShowOnce'] = self.showQuestOnce:GetChecked()
        }

        for k, v in pairs(self.npcsList:GetLines()) do
            if v.npc && v.amount then
                formTable['npcs'][v.npc] = v.amount;
            end;
        end;
        for k, v in pairs(self.itemsList:GetLines()) do
            if v.item && v.amount then
                formTable['items'][v.item] = v.amount;
            end;
        end;
        for k, v in pairs(self.rewardList:GetLines()) do
            if v.item && v.amount then
                formTable['reward'][v.item] = v.amount;
            end;
        end;
        for k, v in pairs(self.questsLeft:GetCanvas():GetChildren()) do
            if v.id then
                formTable['needsQuest'][#formTable['needsQuest'] + 1] = v.id;
            end;
        end;

        if title == "" or title == nil then
            self.titleText.showErr = true

            surface.PlaySound('buttons/button8.wav')
            self:ScrollToChild( self.titleText )
            return;
        end;

        if desc == "" or desc == nil then
            self.DescriptionText.showErr = true
            surface.PlaySound('buttons/button8.wav')
            self:ScrollToChild( self.DescriptionText )
            return;
        end;
        
        netstream.Start('Talker_createQuest', formTable)
        self.NextID:SetText('Quest ID: ' .. #quests + 1)
        self.titleText:SetText('')
        self.showQuestOnce:SetValue( false )
        self.DescriptionText:SetText('')
        for k, v in pairs(self.questsLeft:GetCanvas():GetChildren()) do
            if v.id then
                self.questsRight:Add(v)
            end;
        end;
        self.moneyReward:SetText(0)
        for k, v in pairs(self.npcsList:GetLines()) do
            if v.npc && v.amount then
                v:Remove()
            end;
        end;
        for k, v in pairs(self.itemsList:GetLines()) do
            if v.item && v.amount then
                v:Remove()
            end;
        end;
        for k, v in pairs(self.rewardList:GetLines()) do
            if v.item && v.amount then
                v:Remove()
            end;
        end;
        surface.PlaySound('buttons/button9.wav')
    end;
end;

vgui.Register( "AddQuest", PANEL, "DScrollPanel" )
local PANEL = {};

function PANEL:Init() 
    
    local quests = PLUGIN.quests;

    self.ChooseCorrectly = self:Add('DLabel')
    self.ChooseCorrectly:Dock(TOP)
    self.ChooseCorrectly:SetText('Choose quest from the left panel first!')
    self.ChooseCorrectly:SetWrap(true);
    self.ChooseCorrectly:SetTextColor(Color(255, 100, 100))
    self.ChooseCorrectly:SetTall(40)

    self.NextID = self:Add('DLabel')
    self.NextID:Dock(TOP)
    self.NextID:SetText('Quest ID: ')
    self.NextID:SetContentAlignment(5)

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Quest title: ')
    self.label:SetContentAlignment(5)

    self.titleText = self:Add('DTextEntry')
    self.titleText:Dock(TOP);
    self.titleText:SetTall(20)
    self.titleText.OnGetFocus = function(self)
        self.showErr = false;
    end
    self.titleText.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Quest description: ')
    self.label:SetContentAlignment(5)

    self.DescriptionText = self:Add('DTextEntry')
    self.DescriptionText:Dock(TOP);
    self.DescriptionText:SetTall(100)
    self.DescriptionText:SetMultiline(true)
    self.DescriptionText.OnGetFocus = function(self)
        self.showErr = false;
    end
    self.DescriptionText.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Kill npcs: ')
    self.label:SetContentAlignment(5)

    self.TextPanel = self:Add('Panel')
    self.TextPanel:Dock(TOP)
    self.TextPanel:SetTall(25)

    self.label = self.TextPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('NPC: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.npcClass = self.TextPanel:Add('DTextEntry')
    self.npcClass:Dock(LEFT);
    self.npcClass:SetWidth(150)
    self.npcClass.Paint = function(s, w, h)
        s:SetEnabled(s:GetParent():IsEnabled())
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self.TextPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('Amount: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.npcAmount = self.TextPanel:Add('DNumberWang')
    self.npcAmount:Dock(LEFT);
    self.npcAmount:SetWidth(25)
    self.npcAmount:SetMinMax(1, 25)
    self.npcAmount:SetValue(1)
    self.npcAmount.Paint = function(s, w, h)
        s:SetEnabled(s:GetParent():IsEnabled())
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.buttonApply = self.TextPanel:Add('DButton')
    self.buttonApply:SetText('ADD')
    self.buttonApply:Dock(LEFT)
    self.buttonApply:DockMargin(5, 0, 0, 0)

    self.buttonApply.DoClick = function(btn)
        if self.npcAmount:GetValue() == 0 or self.npcClass:GetText() == "" then return end;

        local newLine = self.npcsList:AddLine(self.npcClass:GetText(), self.npcAmount:GetValue())
        newLine.npc = self.npcClass:GetText();
        newLine.amount = self.npcAmount:GetValue()

        newLine.OnMousePressed = function(btn, key)
            local menu = DermaMenu() 
            menu:AddOption( "Remove", function() 
                btn:Remove()
            end)
            menu:Open()
        end;
    end;

    self.npcsList = self:Add('DListView')
    self.npcsList:Dock( TOP )
    self.npcsList:SetTall(100)
    self.npcsList:DockMargin(5, 5, 5, 5)
    local column1 = self.npcsList:AddColumn( "NPC" )
    column1.Header:SetTextColor( Color(0, 0, 0) )
    local column2 = self.npcsList:AddColumn( "Amount" )
    column2.Header:SetTextColor( Color(0, 0, 0) )

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Collect items: ')
    self.label:SetContentAlignment(5)

    self.TextPanelItems = self:Add('Panel')
    self.TextPanelItems:Dock(TOP)
    self.TextPanelItems:SetTall(25)

    self.label = self.TextPanelItems:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('ID: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.itemID = self.TextPanelItems:Add('DTextEntry')
    self.itemID:Dock(LEFT);
    self.itemID:SetWidth(150)
    self.itemID.Paint = function(s, w, h)
        s:SetEnabled(s:GetParent():IsEnabled())
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.label = self.TextPanelItems:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('Amount: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.itemAmount = self.TextPanelItems:Add('DNumberWang')
    self.itemAmount:Dock(LEFT);
    self.itemAmount:SetWidth(25)
    self.itemAmount:SetMinMax(1, 25)
    self.itemAmount:SetValue(1)
    self.itemAmount.Paint = function(s, w, h)
        s:SetEnabled(s:GetParent():IsEnabled())
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.ItemApply = self.TextPanelItems:Add('DButton')
    self.ItemApply:SetText('ADD')
    self.ItemApply:Dock(LEFT)
    self.ItemApply:DockMargin(5, 0, 0, 0)
    self.ItemApply.DoClick = function(btn)
        if self.itemAmount:GetValue() == 0 or self.itemID:GetText() == "" then return end;

        local newLine = self.itemsList:AddLine(self.itemID:GetText(), self.itemAmount:GetValue())
        newLine.item = self.itemID:GetText();
        newLine.amount = self.itemAmount:GetValue()
        newLine.OnMousePressed = function(btn, key)
            local menu = DermaMenu() 
            menu:AddOption( "Remove", function() 
                btn:Remove()
            end)
            menu:Open()
        end;
    end;

    self.itemsList = self:Add('DListView')
    self.itemsList:Dock( TOP )
    self.itemsList:SetTall(100)
    self.itemsList:DockMargin(5, 5, 5, 5)
    local column1 = self.itemsList:AddColumn( "Name" )
    column1.Header:SetTextColor( Color(0, 0, 0) )
    local column2 = self.itemsList:AddColumn( "Amount" )
    column2.Header:SetTextColor( Color(0, 0, 0) )

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Give items: ')
    self.label:SetContentAlignment(5)

    self.RewardPanel = self:Add('Panel')
    self.RewardPanel:Dock(TOP)
    self.RewardPanel:SetTall(25)

    self.label = self.RewardPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('ID: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.giveItemID = self.RewardPanel:Add('DTextEntry')
    self.giveItemID:Dock(LEFT);
    self.giveItemID:SetWidth(150)
    self.giveItemID.Paint = function(s, w, h)
        s:SetEnabled(s:GetParent():IsEnabled())
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;
    self.giveItemID.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.label = self.RewardPanel:Add('DLabel')
    self.label:Dock(LEFT)
    self.label:SetText('Amount: ')
    self.label:SetContentAlignment(4)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.giveItemAmount = self.RewardPanel:Add('DNumberWang')
    self.giveItemAmount:Dock(LEFT);
    self.giveItemAmount:SetWidth(25)
    self.giveItemAmount:SetMinMax(1, 25)
    self.giveItemAmount:SetValue(1)
    self.giveItemAmount.Paint = function(s, w, h)
        s:SetEnabled(s:GetParent():IsEnabled())
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;
    self.giveItemAmount.OnGetFocus = function(self)
        self.showErr = false;
    end

    self.ApplyReward = self.RewardPanel:Add('DButton')
    self.ApplyReward:SetText('ADD')
    self.ApplyReward:Dock(LEFT)
    self.ApplyReward:DockMargin(5, 0, 0, 0)
    self.ApplyReward.DoClick = function(btn)
        if self.giveItemAmount:GetValue() == 0 or self.giveItemID:GetText() == "" then return end;

        local newLine = self.rewardList:AddLine(self.giveItemID:GetText(), self.giveItemAmount:GetValue())
        newLine.item = self.giveItemID:GetText();
        newLine.amount = self.giveItemAmount:GetValue()
        newLine.OnMousePressed = function(btn, key)
            local menu = DermaMenu() 
            menu:AddOption( "Remove", function() 
                btn:Remove()
            end)
            menu:Open()
        end;
    end;

    self.rewardList = self:Add('DListView')
    self.rewardList:SetTall(100)
    self.rewardList:Dock( TOP )
    self.rewardList:DockMargin(5, 5, 5, 5)
    local column1 = self.rewardList:AddColumn( "Name" )
    column1.Header:SetTextColor( Color(0, 0, 0) )
    local column2 = self.rewardList:AddColumn( "Amount" )
    column2.Header:SetTextColor( Color(0, 0, 0) )

    self.showQuestOnce = self:Add( "DCheckBoxLabel" )
    self.showQuestOnce:Dock(TOP)
    self.showQuestOnce:SetText("Show quest once ")
    self.showQuestOnce:SetValue( false )
    self.showQuestOnce:DockMargin(5, 5, 5, 5)	
    self.showQuestOnce:SizeToContents()

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Should have quests to show: ')
    self.label:SetContentAlignment(5)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.QuestsDone = self:Add('Panel')
    self.QuestsDone:Dock(TOP)
    self.QuestsDone:SetTall(250)
    self.QuestsDone.Paint = function(s, w, h)
        if !s:IsEnabled() then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(25, 25, 25) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
    end;

    self.questsLeft = self.QuestsDone:Add('DScrollPanel')
    self.questsLeft:Dock(LEFT)
    self.questsLeft:SetWide(170)

    self.label = self.questsLeft:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Added: ')
    self.label:SetContentAlignment(5)

    self.questsRight = self.QuestsDone:Add('DScrollPanel')
    self.questsRight:Dock(LEFT)
    self.questsRight:SetWide(160)

    self.label = self.questsRight:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Available: ')
    self.label:SetContentAlignment(5)

    self.label = self:Add('DLabel')
    self.label:Dock(TOP)
    self.label:SetText('Give money as reward: ')
    self.label:SetContentAlignment(5)
    self.label:DockMargin(5, 5, 5, 5)
    self.label:SizeToContents()

    self.moneyReward = self:Add('DNumberWang')
    self.moneyReward:Dock(TOP);
    self.moneyReward:SetMinMax(0, 1000)
    self.moneyReward:SetValue(0)
    self.moneyReward.Paint = function(s, w, h)
        if s.showErr then
            draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(255, 100, 100) )
            return;
        end;
        draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(55, 55, 55), Color(100, 100, 100) )
        s:DrawTextEntryText( Color(242, 234, 217), Color(0,0,0), Color(242, 234, 217, 100) )
    end;

    self.Apply = self:Add('DButton')
    self.Apply:SetText('APPLY')
    self.Apply:Dock(TOP)
    self.Apply:DockMargin(5, 5, 5, 5)

    self.Apply.DoClick = function(btn)
        local title = self.titleText:GetText()
        local desc = self.DescriptionText:GetText();
        
        local formTable = {
            ['id'] = self.NextID.id,
            ['npcs'] = {},
            ['items'] = {},
            ['reward'] = {},
            ['needsQuest'] = {},
            ['title'] = title,
            ['description'] = desc,
            ['money'] = self.moneyReward:GetValue(),
            ['ShowOnce'] = self.showQuestOnce:GetChecked()
        }

        for k, v in pairs(self.npcsList:GetLines()) do
            if v.npc && v.amount then
                formTable['npcs'][v.npc] = v.amount;
            end;
        end;
        for k, v in pairs(self.itemsList:GetLines()) do
            if v.item && v.amount then
                formTable['items'][v.item] = v.amount;
            end;
        end;
        for k, v in pairs(self.rewardList:GetLines()) do
            if v.item && v.amount then
                formTable['reward'][v.item] = v.amount;
            end;
        end;
        for k, v in pairs(self.questsLeft:GetCanvas():GetChildren()) do
            if v.id then
                formTable['needsQuest'][#formTable['needsQuest'] + 1] = v.id;
            end;
        end;

        if title == "" or title == nil then
            self.titleText.showErr = true

            surface.PlaySound('buttons/button8.wav')
            self:ScrollToChild( self.titleText )
            return;
        end;

        if desc == "" or desc == nil then
            self.DescriptionText.showErr = true
            surface.PlaySound('buttons/button8.wav')
            self:ScrollToChild( self.DescriptionText )
            return;
        end;
        
        netstream.Start('Talker_createQuest', formTable)
        self.NextID:SetText('Quest ID: ' .. #quests + 1)
        self.titleText:SetText('')
        self.showQuestOnce:SetValue( false )
        self.DescriptionText:SetText('')
        for k, v in pairs(self.questsLeft:GetCanvas():GetChildren()) do
            if v.id then
                self.questsRight:Add(v)
            end;
        end;
        self.moneyReward:SetText(0)
        for k, v in pairs(self.npcsList:GetLines()) do
            if v.npc && v.amount then
                v:Remove()
            end;
        end;
        for k, v in pairs(self.itemsList:GetLines()) do
            if v.item && v.amount then
                v:Remove()
            end;
        end;
        for k, v in pairs(self.rewardList:GetLines()) do
            if v.item && v.amount then
                v:Remove()
            end;
        end;
        surface.PlaySound('buttons/button9.wav')
    end;

    for k, v in pairs(self:GetCanvas():GetChildren()) do
        if v != self.ChooseCorrectly then 
            v:SetAlpha(100)
            v:SetEnabled(false)
        end;
    end;

end;

vgui.Register( "EditQuest", PANEL, "DScrollPanel" )