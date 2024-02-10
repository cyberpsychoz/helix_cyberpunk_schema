local PANEL = {}

function PANEL:Init()
    self:SetFocusTopLevel( true )
    self:MakePopup()
    self:Adaptate(750, 700, 0.3, 0.2)
    gui.EnableScreenClicker(true);
    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0, function(alpha, pnl)
        pnl:SetAlpha(255)
        pnl.CanCloseE = true;
    end);
end;

function PANEL:Paint( w, h )
    Derma_DrawBGBlur( self, 0 )
    surface.SetDrawColor(Color(50, 50, 50, 150))
    surface.DrawRect(0, 0, w, h)
    self:CreateClose_()
end;

function PANEL:Populate()
    local sw, sh = ScrW(), ScrH()
    self.infoPanel = self:Add('ObjectiveScroll')
    self.infoPanel:Dock(FILL)
    self:RefreshInfo()

    self.regimes = self:Add("Panel")
    self.regimes:Dock(BOTTOM)
    self.regimes:SetTall(sh * 0.050)

    self.regimesBG = self.regimes:Add("Panel")
    self.regimesBG:SetWide(sw * 0.30)
    self.regimesBG:CenterHorizontal(sw * 0.0030)
    self.regimesBG:CenterVertical(sh * 0.0007)

    self.startQ = self.regimesBG:Add("ObjButton")
    self.startQ:Dock(LEFT)
    self.startQ:SetText("Start Queue")
    self.startQ.Paint = function(s, w, h)
        if #OBJs.list > 0 && OBJs.list[2] && !OBJs:Check(2).queued then
            if s:IsHovered() then
                s:SetTextColor(Color(187, 120, 64))
                draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 200))
            else
                s:SetTextColor(Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
            end
        else
            s:SetTextColor(Color(255, 255, 255))
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
        end;
    end;
    
    if #OBJs.list <= 1 || !OBJs.list[2] || OBJs:Check(2) && OBJs:Check(2).queued then
        self.startQ:SetAlpha(50)
    end
    self.startQ.DoClick = function(btn)
        if #OBJs.list <= 1 || OBJs.list[2] && OBJs:Check(2) && OBJs:Check(2).queued then return end;

        if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            return;
        end
        btn.BtnCooldDown = CurTime() + 1;

        netstream.Start('OBJs::StartAction', "startQueue")
        btn:SetAlpha(50)
        timer.Simple(0.1, function()
            if (OBJs.interface && OBJs.interface:IsValid()) then            
                OBJs.interface:RefreshInfo()
    	    end;
        end)
    end;

    self.stopQ = self.regimesBG:Add("ObjButton")
    self.stopQ:Dock(RIGHT)
    self.stopQ:SetText("Stop Queue")
    self.stopQ.Paint = function(s, w, h)
        if #OBJs.list > 0 && OBJs.list[2] && OBJs:Check(2).queued then
            if s:IsHovered() then
                s:SetTextColor(Color(187, 120, 64))
                draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 200))
            else
                s:SetTextColor(Color(255, 255, 255))
                draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
            end
        else
            s:SetTextColor(Color(255, 255, 255))
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
        end;
    end;
    if #OBJs.list <= 1 || !OBJs.list[2] || OBJs:Check(2) && !OBJs:Check(2).queued then
        self.stopQ:SetAlpha(50)
    end
    self.stopQ.DoClick = function(btn)
        if #OBJs.list <= 1 || !OBJs.list[2] && OBJs:Check(2) && !OBJs:Check(2).queued then return end;

        if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            return;
        end
        btn.BtnCooldDown = CurTime() + 1;

        netstream.Start('OBJs::StartAction', "stopQueue")
        btn:SetAlpha(50)
        timer.Simple(0.1, function()
            if (OBJs.interface && OBJs.interface:IsValid()) then            
                OBJs.interface:RefreshInfo()
    	    end;
        end)
    end;

    if #OBJs.list <= 1 then
        self.stopQ:SetAlpha(50)
        self.startQ:SetAlpha(50)
    end

end;

function PANEL:RefreshInfo()
    timer.Simple(0, function()
        if !self.infoPanel || !self.infoPanel:IsValid() then return end;
        
        self.infoPanel:Clear()
        if self.docker then
            self.docker:Remove();
        end

        if #OBJs.list == 0 then
            self.docker = self:Add("Panel")
            self.docker:Dock(FILL)
            
		    self.lbl = self.docker:Add("ObjectiveLabel")
            self.lbl:Dock(FILL)
            self.lbl:SetAutoStretchVertical(false)
    		self.lbl:SetText("There's no available tasks yet!")
	    	self.lbl:SetFont("FONT_bold")
            return;
    	end

        for k, v in pairs(OBJs.list or {}) do
            self.task = self.infoPanel:Add("Task")
            self.task:Populate(k)
        end;
        
        if #OBJs.list <= 1 || !OBJs.list[2] || OBJs:Check(2) && OBJs:Check(2).queued then
            self.startQ:SetAlpha(50)
        else
            self.startQ:SetAlpha(255)
        end
        if #OBJs.list <= 1 || !OBJs.list[2] || OBJs:Check(2) && !OBJs:Check(2).queued then
            self.stopQ:SetAlpha(50)
        else
            self.stopQ:SetAlpha(255)
        end        
    end);
end;

vgui.Register( "ObjectiveList", PANEL, "EditablePanel" )