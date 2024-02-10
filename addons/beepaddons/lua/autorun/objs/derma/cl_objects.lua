local PANEL = {}

function PANEL:Init() 
    self:Dock(TOP)
    self:SetContentAlignment(5)
    self:SizeToContents()
    self:SetAutoStretchVertical(true)

    self:SetFont("FONT_regular")
end;
vgui.Register( "ObjectiveLabel", PANEL, "DLabel" )

local PANEL = {}
function PANEL:Init()
    local ConVas, ScrollBar = self:GetCanvas(), self:GetVBar()
    ScrollBar:SetWidth(5)
    ScrollBar:DockMargin(5, 5, 5, 5)
	ScrollBar:SetHideButtons( true )
	function ScrollBar:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 50)) end
	function ScrollBar.btnGrip:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 100)) end
end
vgui.Register( "ObjectiveScroll", PANEL, "DScrollPanel" )

local PANEL = {}
function PANEL:Init()
    self:Dock(TOP)
    self:DockMargin(20, 5, 10, 5)

    self:SetFont("FONT_regular")
end

function PANEL:Paint( w, h )
	self:DrawTextEntryText( Color(255, 255, 255), Color(100, 100, 100), Color(255 ,255, 255) )
    surface.SetDrawColor(Color(70, 70, 70, 100))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(10, 10, 10))
    surface.DrawOutlinedRect( 0, 0, w, h, 1 )
end;
vgui.Register( "ObjectiveText", PANEL, "DTextEntry" )

local PANEL = {}

function PANEL:Init()
    self:SetSize( 150, 20 )
    self:Dock(LEFT)
    self:SetTextColor(color_white)

    self:SetFont("FONT_regular")
end

function PANEL:Paint( w, h ) 
    if self:IsHovered() then
        self:SetTextColor(Color(187, 120, 64))
        draw.RoundedBox(0, 0, 0, w, h, Color(90, 90, 90, 200))
    else
        self:SetTextColor(Color(255, 255, 255))
        draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 200))
    end    
end;
vgui.Register( "ObjButton", PANEL, "DButton" )

local PANEL = {}

function PANEL:Init()
    self:Dock( TOP )
    self:SetTall(255)
    self:DockMargin( 20, 5, 20, 5 )
    self:SetMultiSelect( true )
end

function PANEL:Paint( w, h )
    surface.SetDrawColor(Color(60, 60, 60, 100))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(10, 10, 10))
    surface.DrawOutlinedRect( 0, 0, w, h, 1 )
end;

function PANEL:Column(str, pos)
    local column = self:AddColumn( str, pos )
    column.Header:SetTextColor(color_white)
    column.Header:SetFont("FONT_regular")
    column.Header.Paint = function(s, w, h) 
        surface.SetDrawColor(Color(60, 60, 60, 200))
        surface.DrawRect(0, 0, w, h)
    end;
end;
vgui.Register( "ObjListView", PANEL, "DListView" )