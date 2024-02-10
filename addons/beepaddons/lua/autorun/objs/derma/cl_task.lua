local PANEL = {};
function PANEL:Init() 
    local sw, sh = ScrW(), ScrH()
    self:Dock(TOP)
    self:SetTall(sh * 0.035)
	self:DockMargin(5, 5, 5, 5)
end;

function PANEL:Populate(id)
    local sw, sh = ScrW(), ScrH()
	self.list = {}
    local objective = OBJs.list[id];
    objective = util.JSONToTable(objective)
    local options = util.JSONToTable(objective.options)
    local data = OBJs:ExistsType(objective.type)

    self.titleBackGround = self:Add("Panel")
    self.titleBackGround:Dock(TOP)
    self.titleBackGround:SetTall(sh * 0.035)
    self.titleBackGround.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 150))
    end;

    self.title = self.titleBackGround:Add("ObjectiveLabel")
    self.title:SetContentAlignment(4)
    self.title:SetAutoStretchVertical(false)
    self.title:DockMargin(20, 0, 20, 0)
    self.title:SetText(objective.Name)
    self.title:SetCursor("hand")
    self.title:Dock(FILL)
    self.title:SizeToContents()
    self.title:SetMouseInputEnabled( true )
    self.title.DoClick = function(button)
        if !button.clicked then
            button.clicked = true
            if !self.opened then
                for k, v in pairs(self.list) do v:AlphaTo(255, .2, 0, function() v:SetAlpha(255) end) end
                for k, v in pairs(self.buttonSubPanel:GetChildren()) do
                    v:AlphaTo(v.alpha or 255, .2, 0, function(fun, pnl) pnl:SetAlpha(v.alpha or 255) end)
                end
            else
                for k, v in pairs(self.list) do v:AlphaTo(0, .2, 0, function() v:SetAlpha(0) end) end
                for k, v in pairs(self.buttonSubPanel:GetChildren()) do
                    v:AlphaTo(0, .2, 0, function(fun, pnl) pnl:SetAlpha(0) end)
                end
            end
            self:SizeTo( self:GetWide(), (!self.opened && self.GetLast) or sh * 0.035, .2, 0, -1, function() 
                self.opened = !self.opened
                button.clicked = false
            end)
        end;
    end;

    self.progress = self.titleBackGround:Add("ObjectiveLabel")
    self.progress:SetContentAlignment(4)
    self.progress:SetAutoStretchVertical(false)
    self.progress:SetText(objective.active && "In progress" || "Waiting for queue")
    self.progress:SetTextColor(objective.active && Color(100, 255, 100))
    self.progress:DockMargin(5, 0, 10, 0)
    self.progress:Dock(RIGHT)
    self.progress:SizeToContents()

    function self.progress:UpdateProgress()
        self:SetText(OBJs:Check(id).active && "In progress" || "Waiting for queue")
        self:SetTextColor(OBJs:Check(id).active && Color(100, 255, 100))
        self:SizeToContents()
    end;

    self.GetLast = 100 + self.title:GetTall();

    self.infoList = self:Add("Panel")
    self.infoList:Dock(LEFT)
    self.infoList:SetWide(sh * 0.3)
    
    self.buttons = self:Add("Panel")
    self.buttons:Dock(FILL)
    self.buttons:SetWide(sh * 0.025)

    local content = {};
    table.insert(content, data.name:upper());
    local jobStr = objective.jobs:Replace("[", ""):Replace("]", ",")
    table.insert(content, "Target Category: " .. jobStr);
    for k, v in pairs(options) do
        v = type(v) == "number" && tostring(math.Round(v)) || tostring(v);
        table.insert(content, k .. ": " .. v);
    end

    for k, v in pairs(content) do
        self.info = self.infoList:Add("ObjectiveLabel")
        self.info:SetText(v)
        if k == 1 then
            self.info:SetFont("FONT_bold")
        else 
            self.info:SetFont("FONT_medium")
        end;
        self.info:SetAlpha(0)
        self.info:SetWrap(true)
        self.info:DockMargin(10, 5, 10, 5)
        self.GetLast = self.GetLast + self.info:GetTall() + draw.GetLinesOfContent(self.info:GetText());
        table.insert(self.list, self.info)
    end

    self.buttonSubPanel = self.buttons:Add("Panel")
    self.buttonSubPanel:AlignBottom(0)
    self.buttonSubPanel:AlignLeft(sw * 0.095)
    self.buttonSubPanel:SetTall(self.GetLast)
    self.buttonSubPanel:SetWide(sh * 0.2)

    self.Start = self.buttonSubPanel:Add("ObjButton")
    self.Start:SetText("Start")
    self.Start:Dock(TOP)
    self.Start:SetAlpha(0)
    self.Start:DockMargin(5, 5, 5, 5)
    self.Start.Paint = function(s, w, h)
        if OBJs.list[id] && !OBJs:Check(id).active then
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
    self.Start.DoClick = function(btn)
        if OBJs:Check(id).active then return end;

        if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            return;
        end
        btn.BtnCooldDown = CurTime() + 1;

        netstream.Start('OBJs::StartAction', "start", id)
        timer.Simple(0, function()
            if OBJs:Check(id).active then
                self.progress:UpdateProgress()
                for k, v in pairs(self.buttonSubPanel:GetChildren()) do
                    if v:GetText() != "Remove" then
                        v.alpha = 50
                        v:SetAlpha(50)
                    else
                        v.alpha = 255
                        v:SetAlpha(255)
                    end
                end
            end
        end)
    end;

    self.Edit = self.buttonSubPanel:Add("ObjButton")
    self.Edit:SetText("Edit")
    self.Edit:Dock(TOP)
    self.Edit:SetAlpha(0)
    self.Edit:DockMargin(5, 5, 5, 5)
    self.Edit.Paint = function(s, w, h)
        if OBJs.list[id] && !OBJs:Check(id).active then
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
    self.Edit.DoClick = function (btn)
        if OBJs:Check(id).active then return end;

        if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            return;
        end
        btn.BtnCooldDown = CurTime() + 1;
        
        OBJs.editTask = id;
        OBJs:NOTIFY("You've choosen this task to edit. You can edit it with your toolgun. If you want to reset, just press R with your toolgun in hands.", "notify")
        local interface = OBJs.tool
        if interface then
            local data = OBJs:Check(id);
            local jobs = util.JSONToTable(data.jobs)
            local options = util.JSONToTable(data.options)

            for k, v in pairs(interface.jobs:GetLines()) do
                if table.HasValue(jobs, v.name) then
                    interface.jobs:SelectItem(v)
                end
            end

            for k, v in pairs(interface.tasks.Data) do
                if v.id && v.id == data.type then
                    interface.tasks:ChooseOptionID(k)
                end
            end

            interface.titleText:SetValue(data["Name"])
        end
    end

    self.Decline = self.buttonSubPanel:Add("ObjButton")
    self.Decline:SetText("Remove")
    self.Decline:Dock(TOP)
    self.Decline:SetAlpha(0)
    self.Decline:DockMargin(5, 5, 5, 5)
    self.Decline.Paint = function(s, w, h)
        if s:IsHovered() && !timer.Exists("objStart - " .. id) then
            s:SetTextColor(Color(187, 120, 64))
            draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 200))
        else
            s:SetTextColor(Color(255, 255, 255))
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
        end
    end;
    if timer.Exists("objStart - " .. id) then self.Decline:SetAlpha(50) end;
    
    self.Decline.DoClick = function(btn)
        if timer.Exists("objStart - " .. id) then return end;

        if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            return;
        end
        btn.BtnCooldDown = CurTime() + 1;

        netstream.Start('OBJs::StartAction', "remove", id)
        timer.Simple(0.1, function()
            if (OBJs.interface && OBJs.interface:IsValid()) then            
                OBJs.interface:RefreshInfo()
    	    end;
        end)
    end;

    self.GoUp = self.buttonSubPanel:Add("ObjButton")
    self.GoUp:SetText("Go Up")
    self.GoUp:Dock(TOP)
    self.GoUp:SetAlpha(0)
    self.GoUp:DockMargin(5, 5, 5, 5)
    self.GoUp.Paint = function(s, w, h)
        if OBJs.list[id] && !OBJs:Check(id).active then
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
    self.GoUp.DoClick = function(btn)
        if OBJs:Check(id).active then return end;
        if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            return;
        end
        btn.BtnCooldDown = CurTime() + 1;

        netstream.Start('OBJs::StartAction', "up", id)
        if (OBJs.interface && OBJs.interface:IsValid()) then            
            OBJs.interface:RefreshInfo()
    	end;
    end;

    self.GoDown = self.buttonSubPanel:Add("ObjButton")
    self.GoDown:SetText("Go Down")
    self.GoDown:Dock(TOP)
    self.GoDown:SetAlpha(0)
    self.GoDown:DockMargin(5, 5, 5, 5)
    self.GoDown.Paint = function(s, w, h)
        if OBJs.list[id] &&  !OBJs:Check(id).active then
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
    self.GoDown.DoClick = function(btn)
        if OBJs:Check(id).active then return end;
        if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            return;
        end
        btn.BtnCooldDown = CurTime() + 1;

        netstream.Start('OBJs::StartAction', "down", id)
        if (OBJs.interface && OBJs.interface:IsValid()) then            
            OBJs.interface:RefreshInfo()
    	end;
    end;
    
    if OBJs:Check(id).active then
        for k, v in pairs(self.buttonSubPanel:GetChildren()) do
            if v:GetText() != "Remove" then
                v.alpha = 50
            else
                v.alpha = 255
            end
        end
    end
end;

function PANEL:Paint( w, h ) 
    draw.RoundedBox(2, 0, 0, w, h, Color(50, 50, 50, 100))
end;
vgui.Register( "Task", PANEL, "EditablePanel" )