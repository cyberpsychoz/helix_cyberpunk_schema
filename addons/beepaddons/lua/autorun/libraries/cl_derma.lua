local panelMeta = FindMetaTable('Panel')
local matBlurScreen = Material( "pp/blurscreen" )
local math = math;
local appr = math.Approach

function panelMeta:Adaptate(w, h, x, y)
    local sW, sH = ScrW(), ScrH()
    x = x or 0.1; y = y or 0.1
    w = w or 100; h = h or 100
    
    self:SetPos( sW * math.min(x, 1.25), sH * math.min(y, 1.25) ) 
    self:SetSize( sW * (w / 1920), sH * (h / 1080) )
end;
    
function panelMeta:CreateClose_()
    local use = input.IsKeyDown(input.GetKeyCode(input.LookupBinding( "+use", true )));

	if use && self.CanCloseE then
    	surface.PlaySound("ui/buttonclick.wav");
    	self:Close();
  end;
end;
    
function panelMeta:Close()
    self:SetVisible(false); self:Remove();
    gui.EnableScreenClicker(false);
end;
function Derma_DrawBGBlur( panel, starttime )

	local Fraction = 1

	if ( starttime ) then
		Fraction = math.Clamp( (SysTime() - starttime) / 1, 0, 1 )
	end

	local x, y = panel:LocalToScreen( 0, 0 )

	local wasEnabled = DisableClipping( true )

	-- Menu cannot do blur
	if ( !MENU_DLL ) then
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i=0.33, 1, 0.33 do
			matBlurScreen:SetFloat( "$blur", Fraction * 5 * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end -- Todo: Make this available to menu Lua
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
	end

	surface.SetDrawColor( 10, 10, 10, 150 * Fraction )
	surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )

	DisableClipping( wasEnabled )
end
function panelMeta:MakeHover(default, cover)
    local frameTime = 600 * FrameTime()
    if !default then default = Color(255, 255, 255) end;
    if !cover then cover = Color(255, 100, 100) end;
    if !self.hvr then self.hvr = Color(0, 0, 0) end;

    if self:IsHovered() then
        self.hvr = Color(
            appr(self.hvr.r, cover.r, frameTime), 
            appr(self.hvr.g, cover.g, frameTime), 
            appr(self.hvr.b, cover.b, frameTime)
        )
    else
        self.hvr = Color(
            appr(self.hvr.r, default.r, frameTime), 
            appr(self.hvr.g, default.g, frameTime), 
            appr(self.hvr.b, default.b, frameTime)
        )
    end

    if self.GetText && self.SetTextColor then
        self:SetTextColor(self.hvr)
    end
end;

// That's good
function draw.drawSubSection(x, y, r, r2, startAng, endAng, step, cache)
    local positions = {}
    local inner = {}
    local outer = {}
    r2 = r+r2
    startAng = startAng or 0
    endAng = endAng or 0
    for i = startAng - 90, endAng - 90, step do
        table.insert(inner, {
            x = math.ceil(x + math.cos(math.rad(i)) * r2),
            y = math.ceil(y + math.sin(math.rad(i)) * r2)
        })
    end
    for i = startAng - 90, endAng - 90, step do
        table.insert(outer, {
            x = math.ceil(x + math.cos(math.rad(i)) * r),
            y = math.ceil(y + math.sin(math.rad(i)) * r)
        })
    end
    for i = 1, #inner * 2 do
        local outPoints = outer[math.floor(i / 2) + 1]
        local inPoints = inner[math.floor((i + 1) / 2) + 1]
        local otherPoints
        if i % 2 == 0 then
            otherPoints = outer[math.floor((i + 1) / 2)]
        else
            otherPoints = inner[math.floor((i + 1) / 2)]
        end
        table.insert(positions, {outPoints, otherPoints, inPoints})
    end
    if cache then
        return positions
    else
        for k,v in pairs(positions) do 
            surface.DrawPoly(v)
        end
    end
end

function draw.GetLinesOfContent(text)   
    local len = 10 + math.Round(text:len()/52);
    if len > 10 then
        len = len * 5.5
    end 
    return len;
end;