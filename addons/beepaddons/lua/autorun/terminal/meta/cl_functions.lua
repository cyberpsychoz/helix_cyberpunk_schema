local panelMeta = FindMetaTable('Panel')
local matBlurScreen = Material( "pp/blurscreen" )

function panelMeta:Adaptate(w, h, x, y)
    local sW, sH = ScrW(), ScrH()
    x = x or 0.1; y = y or 0.1
    w = w or 100; h = h or 100
    
    self:SetPos( sW * math.min(x, 1.25), sH * math.min(y, 1.25) ) 
    self:SetSize( sW * (w / 1920), sH * (h / 1080) )
end;
    
function panelMeta:CreateCloseDebug()
	local use = input.IsKeyDown(input.GetKeyCode(input.LookupBinding( "+use", true )));
	local ctrl = input.IsKeyDown(input.GetKeyCode(input.LookupBinding( "+duck", true )));
	// If player presses Ctrl+E - the cmd closes.
    if ctrl && use && self.allowedToClose then
        self:CloseMe();
    end;
end;
    
function panelMeta:CloseMe()
    self:SetVisible(false); self:Remove();
    gui.EnableScreenClicker(false);
end;

function draw.RoundedBoxOutlined( bordersize, x, y, w, h, color, bordercol )
        x, y, w, h = math.Round( x ), math.Round( y ), math.Round( w ), math.Round( h )
        draw.RoundedBox( bordersize, x, y, w, h, color )
        surface.SetDrawColor( bordercol )
        surface.DrawTexturedRectRotated( x + bordersize/2, y + bordersize/2, bordersize, bordersize, 0 ) 
        surface.DrawTexturedRectRotated( x + w - bordersize/2, y + bordersize/2, bordersize, bordersize, 270 ) 
        surface.DrawTexturedRectRotated( x + w - bordersize/2, y + h - bordersize/2, bordersize, bordersize, 180 ) 
        surface.DrawTexturedRectRotated( x + bordersize/2, y + h - bordersize/2, bordersize, bordersize, 90 ) 
        surface.DrawLine( x + bordersize, y, x + w - bordersize, y )
        surface.DrawLine( x + bordersize, y + h - 1, x + w - bordersize, y + h - 1 )
        surface.DrawLine( x, y + bordersize, x, y + h - bordersize )
        surface.DrawLine( x + w - 1, y + bordersize, x + w - 1, y + h - bordersize )
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
			matBlurScreen:SetFloat( "$blur", Fraction * 10 * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end -- Todo: Make this available to menu Lua
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
	end

	surface.SetDrawColor( 10, 10, 10, 240 * Fraction )
	surface.DrawRect( x * -1, y * -1, ScrW(), ScrH() )

	DisableClipping( wasEnabled )

end