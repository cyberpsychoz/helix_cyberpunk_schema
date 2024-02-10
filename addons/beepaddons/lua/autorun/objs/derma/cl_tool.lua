local PANEL = {};

function PANEL:Init()
    local sw, sh = ScrW(), ScrH()
    self:Dock(TOP)
    self:SetTall(sh * 0.95)
end;

function PANEL:Paint( w, h )
    surface.SetDrawColor(Color(50, 50, 50, 255))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(10, 10, 10))
    surface.DrawOutlinedRect( 0, 0, w, h, 2 )
end;

function PANEL:Populate()
    local sw, sh = ScrW(), ScrH()
    self.settings = self:Add('ObjectiveScroll')
    self.settings:Dock(FILL)

    self.titleLabel = self.settings:Add("ObjectiveLabel")
    self.titleLabel:SetText("Task title: ")
    self.titleLabel:SetZPos( -4 )
    self.titleLabel:DockMargin(10, 5, 10, 5)

    self.titleText = self.settings:Add("ObjectiveText")
    self.titleText:SetZPos( -3 )

    self.jobs = self.settings:Add("ObjListView")
    self.jobs:SetZPos( -2 )
    self.jobs:Column( "Job groups" )
    	for k, v in pairs(OBJs:Regime() == "production" && PR.CategoriesAssign || {["Test category"] = ""}) do
        local job = self.jobs:AddLine( k )
        job.name = k
        for k, v in pairs(job.Columns) do
            v:SetTextColor(color_white)
            v:SetContentAlignment(5)
        end
    end

    self.chooseTask = self.settings:Add("ObjectiveLabel")
    self.chooseTask:SetText("Choose task: ")
    self.chooseTask:DockMargin(10, 5, 10, 5)

    self.tasks = self.settings:Add( "DComboBox" )
		self.tasks:Dock( TOP )
    self.tasks:SetTextColor( color_white )
		self.tasks:DockMargin( 20, 5, 20, 5 )
		self.tasks:SetValue( "" )
    self.tasks:SetTall(sh * 0.035)
    function self.tasks:Paint(w, h)
        surface.SetDrawColor(Color(60, 60, 60, 100))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(10, 10, 10))
        surface.DrawOutlinedRect( 0, 0, w, h, 1 )
    end;
    for k, v in pairs(OBJs.types) do
        self.tasks:AddChoice(v.name, {id = k, description = v.description} or {})
    end
    self.tasks:ChooseOption(1)
    self.tasks.OnSelect = function(combo, index, text, data)
        self.description:SetText(data.description)
        self.optionsPanel:Clear()

        self.details = self.optionsPanel:Add("Objectives")
        self.details:Populate(data.id)
    end;

    self.lbl = self.settings:Add("ObjectiveLabel")
    self.lbl:SetText("Description: ")
    self.lbl:DockMargin(10, 5, 10, 5)

    self.description = self.settings:Add("ObjectiveLabel")
    self.description:SetWrap(true)
    self.description:SetText("Stand in radius of flag and hold the positions until it's not captured.")
    self.description:DockMargin(20, 5, 10, 5)

    self.lbl = self.settings:Add("ObjectiveLabel")
    self.lbl:SetText("Choose options: ")
    self.lbl:DockMargin(10, 5, 10, 5)

    self.optionsPanel = self.settings:Add("Panel")
    self.optionsPanel:Dock( TOP )
    self.optionsPanel:SetTall(sh * 0.35)
    self.optionsPanel:DockMargin( 20, 5, 20, 5 )

    self.OpenObjectives = self.settings:Add("ObjButton")
    self.OpenObjectives:SetText("Open objectives")
    self.OpenObjectives:Dock(TOP)
    self.OpenObjectives:DockMargin(5, 5, 5, 5)
    self.OpenObjectives.Paint = function(s, w, h)
        if s:IsHovered() then
            s:SetTextColor(Color(187, 120, 64))
            draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 200))
        else
            s:SetTextColor(Color(255, 255, 255))
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
        end
    end;
    
    self.OpenObjectives.DoClick = function(btn)
		if !LocalPlayer():IsAdmin() || !LocalPlayer():IsSuperAdmin() then return end;
			
		if (OBJs.interface && OBJs.interface:IsValid()) then
			OBJs.interface:Close();
    	end;

    	OBJs.interface = vgui.Create("ObjectiveList");
    	OBJs.interface:Populate()
    end;

    self.tasks:ChooseOptionID(1)
end;

vgui.Register( "OBJs_interface", PANEL, "EditablePanel" )