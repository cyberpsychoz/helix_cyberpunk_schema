function OBJs:GetSignColor()
		local clr = Color(255, 255, 255)
		local quest = OBJs:Quest()

		if !quest.active then
				clr = Color(200, 200, 200)
		end
		
		return clr;
end;

function OBJs:DrawTitles(pos, text)
	local plyPos = LocalPlayer():GetPos()
	text = text:upper();
	local tpos = pos + Vector(0, 0, 100);
	local toscreen = tpos:ToScreen()
	local meters = math.Round( tpos:Distance( plyPos ) / 28 ) .. " m"
	local clr = OBJs:GetSignColor();

	draw.SimpleText((text:len() > 0 && text or "UNKNOWN TITLE"), "FONT_bold", toscreen.x, toscreen.y, clr, 1 )
	draw.SimpleText(meters, "FONT_medium", toscreen.x, toscreen.y+30, clr, 1 )
end;

function OBJs:DrawRadius(pos, radius)
	local plyPos = LocalPlayer():GetPos()
	local dist = math.Round(plyPos:Distance( pos ))
	local clr = OBJs:GetSignColor();
	if !OBJs:ToolValidation() then return end;
	
		cam.Start3D2D( pos + Vector(0, 0, 15), angle_zero, 1 )
			if dist < 1080 && radius then
				draw.NoTexture()
				surface.SetDrawColor(Color(clr.r, clr.g, clr.b, math.max((radius+640) - dist, 0 )))
				for k, v in pairs(draw.drawSubSection(0, 0, radius, 2, 0, 365, 5, true)) do surface.DrawPoly(v) end
			end;
		cam.End3D2D();	
end;

function FormatTime(time)
		local formatTime = ""
		if time >= 10 then
				local lTime = math.floor(time / 60);
				if lTime > 9 then
						formatTime = math.floor(time / 60) .. ":"
				else
						formatTime = "0" .. math.floor(time / 60) .. ":"
				end;
				if time % 60 < 10 then
						formatTime = formatTime .. "0" .. time % 60
				else
						formatTime = formatTime .. time % 60
				end
		elseif time < 10 then
				if !NOT_10_SEC then
					surface.PlaySound("pr/warn_10_sec.wav")
					NOT_10_SEC = true;
				end;
				formatTime = "00:" .. "0" .. time
		end

		return formatTime
end;

function OBJs:DrawTime(pos, time)
		local toscreen = pos:ToScreen()
		local clr = OBJs:GetSignColor();
		
		draw.SimpleText(FormatTime(time), "FONT_bold", toscreen.x, toscreen.y+50, clr, 1 )
end;

function OBJs:ToolValidation()
		local ply = LocalPlayer()
		if !ply:IsValid() || !ply:Alive() then return false end;
		local interface = OBJs.tool;
		local wep = ply:GetActiveWeapon();
		if wep == NULL then return false end;

		local isToolGun = wep:GetClass() == "gmod_tool";
		local TOOL = ply:GetTool();
		if !isToolGun || !TOOL || !interface || (TOOL && TOOL.Mode != "point_tool") then return false end;

		return interface
end;