local PANEL = {};
local PLUGIN = PLUGIN;

function PANEL:Init()
    self:SetTall(150)
    self:Dock(TOP);
end;

function PANEL:Paint( w, h )
    self:CreateCloseDebug()
end;

function PANEL:Populate(call, parent)
    local dialogueText = self:DialogueText();

    self.myself = self:Add('Panel')
    self.myself:DockMargin(10, 10, 10, 10)

    self.talkerName = self.myself:Add('DLabel')
    self.talkerName:Dock(TOP)
    self.talkerName:SetText('');
    self.talkerName:DockMargin(5, 0, 0, 0)
    self.talkerName:SetFont('R_chatFont_Bold')
    self.myself:SetWide(10)

    self.textContent = self.myself:Add('DLabel')
    self.textContent:Dock(TOP)
    self.textContent:SetText(dialogueText);
    self.textContent:DockMargin(5, 0, 5, 0)
    self.textContent:SetWrap(true);
    self.textContent:SetFont('R_chatFont')
    
    if self:DialogueOwner() then
        self.myself:Dock(LEFT);
        self.talkerName:SetTextColor(Color(244, 154, 65))
        self.talkerName:SetText(PLUGIN.settingsCurrent['name']);
        self.myself:SetWide(400)
    else
        self.talkerName:SetText(LocalPlayer():GetName());
        self.talkerName:SetTextColor(Color(171, 210, 100))
        self.myself:Dock(RIGHT);
        self.myself:SetWide(self:GetWidthOfContent())
    end;

    self.textContent:SetAutoStretchVertical(true)
    self.textContent:SizeToContents()

    self:SetTall( 40 * (1 * self:GetLinesOfContent()) + 25 )
end;

function PANEL:DialogueOwner( who )
    if who then
        self.whoIS = who;
    end;

    return self.whoIS
end;

function PANEL:DialogueText( text )
    if text then
        self.dialogueText = text
    end;

    return self.dialogueText or 'none';
end;

function PANEL:GetLinesOfContent()
    local amount = string.len(self.textContent:GetText())

    return 1 + math.Round(amount/90)
end;

function PANEL:GetWidthOfContent()
    local amount = string.len(self.textContent:GetText())

    return (1 + math.Round(amount/40)) * 200
end;

vgui.Register( "Dialogue", PANEL, "Panel" )