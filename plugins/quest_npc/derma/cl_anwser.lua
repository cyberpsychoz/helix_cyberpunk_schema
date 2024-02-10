local PANEL = {};
local PLUGIN = PLUGIN;

function PANEL:Init() 
    self:SetTall(15);
    self:Dock(TOP);
    self:DockMargin(15, 5, 5, 5)

    self.noneColor = Color(255, 255, 255):ToTable()
end;

function PANEL:Paint( w, h )
    local frameTime = 600 * FrameTime()
    if self:IsHovered() then
        self.noneColor[1] = math.Approach( self.noneColor[1], 100, frameTime )
        self.noneColor[2] = math.Approach( self.noneColor[2], 255, frameTime )
        self.noneColor[3] = math.Approach( self.noneColor[3], 100, frameTime )
    else
        self.noneColor[1] = math.Approach( self.noneColor[1], 255, frameTime )
        self.noneColor[2] = math.Approach( self.noneColor[2], 255, frameTime )
        self.noneColor[3] = math.Approach( self.noneColor[3], 255, frameTime )
	end;
    self.textContent:SetTextColor( Color(self.noneColor[1], self.noneColor[2], self.noneColor[3]) )
    self:CreateCloseDebug()
end;

function PANEL:Populate()
    self.textContent = self:Add('DLabel')
    self.textContent:Dock(FILL);
    self.textContent:SetText(self:GetAnwserText())
    self.textContent:SetAutoStretchVertical(true)
    self.textContent:SizeToContents()
    self.textContent:SetWrap(true);
    self.textContent:SetFont('R_chatFont_anwsers')
    

    self:SetTall( 25 * (1 * self:GetLinesOfContent()) )
end;

function PANEL:GetLinesOfContent()
    local amount = string.len(self.textContent:GetText())
    return 1 + math.Round(amount/120)
end;

function PANEL:GetAnwserText(text)
    if text then
        self.contentText = text;
    end;

    return self.contentText or 'none'
end;

function PANEL:GetUniqueID(uniqueID)
    if uniqueID then
        self.currentID = uniqueID;
    end;

    return self.currentID or 0;
end;

function PANEL:OnMousePressed( code )
    local parentPanel = self:GetParent();
    local D = PLUGIN.dialogueCurrent
    local TalkerSettings = PLUGIN.settingsCurrent
    
    local globalTable = D['Anwsers'][ self:GetUniqueID() ];
    if !globalTable then print("Can't find it.") return end;
    local manyParents = self.defaultParent

    if globalTable.CanClose then 

        manyParents:AlphaTo(0, 0.3, 0, function(tbl, pnl)
            pnl:CloseMe() 
        end)
        return; 
    end;

    local call = globalTable.__CALL;
    local remove = globalTable.__REMOVE;
    local next_dialogue = globalTable.__DIALOGUE;

    if code == 107 then
        if remove then
            for id, child in pairs(parentPanel:GetChildren()) do
                if child.GetUniqueID && table.HasValue(remove, child:GetUniqueID()) then
                    child:Remove()
                    parentPanel:GetParent():Rebuild()
                end;
            end
        end;

        local dialogue = manyParents.dialoguesPanel:Add('Dialogue')
        dialogue:DialogueOwner(false);
        dialogue:DialogueText(self:GetAnwserText())
        dialogue:Populate();        

        if next_dialogue && D['Dialogues'][next_dialogue] then
            local dialogue = manyParents.dialoguesPanel:Add('Dialogue')
            dialogue:DialogueOwner(true);
            dialogue:DialogueText(D['Dialogues'][next_dialogue].text)
            dialogue:Populate();
        end;

        timer.Simple(0.05, function()
            if manyParents then
                manyParents.dialoguesPanel:GetVBar():SetScroll(manyParents.dialoguesPanel:GetVBar().CanvasSize)
            end;
        end);

        if call then
            for key, id in pairs(call) do
                for anwser_id, data in pairs(D['Anwsers']) do
                    if anwser_id == id then
                        local anwser = manyParents.AnwsersList:Add('Anwser')
                        anwser:GetAnwserText(data.text)
                        anwser:GetUniqueID(anwser_id)
                        anwser.defaultParent = manyParents;
                        anwser:Populate()
                    end;
                end;
            end;
        end;

    end;

end;

vgui.Register( "Anwser", PANEL, "Panel" )