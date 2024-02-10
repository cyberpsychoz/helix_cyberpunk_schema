TOOL.AddToMenu = true
TOOL.Category = "Objectives"
TOOL.Name = "#tool.point_tool.name"



function TOOL:LeftClick( trace )
	if CLIENT then
		local ply = self:GetOwner()
		local interface = OBJs.tool;
		if !interface || !ply:IsAdmin() then return end;
		local name, info = interface.tasks:GetSelected()
		local text = interface.titleText:GetValue();
		if name == "" then return end;
		local obj = OBJs:ExistsType(info.id)

		local edit = OBJs.editTask

		if obj then
			local data = {options = {}};
			local options = util.JSONToTable(obj.options);
			local jobs = {};

			for k, v in pairs(interface.jobs:GetSelected()) do
					table.insert(jobs, v.name)
			end
			jobs = util.TableToJSON(jobs);

			for k, v in pairs(options) do
					local match = interface.details.optionsList[k];
					if !match then continue; end;
					local info = match["info"]
					local el = match["element"]
					if info == "time" then
						options[info] = el:GetValue()
						options[k] = nil;
						
					elseif info == "number" || info == "float" || info == "text" then 
						options[k] = el:GetValue()

					elseif info == "position" then
						options[k] = Vector(el.pos)

					elseif info == "npc" then
						options[k] = {};
						for a, b in pairs(el:GetSelected()) do table.insert(options[k], b.name) end
						options[k] = util.TableToJSON(options[k])

					elseif info == "reinforcement" then
						options[k] = {position = el:GetValue(), model = match["reModel"]:GetValue()};
						options[k] = util.TableToJSON(options[k])

					elseif info == "weapons" then
						options[k] = el:GetSelectedLine() && el:GetLine(el:GetSelectedLine()).name or "";

					elseif info == "position_list" then
						options[k] = {}
						for a, b in pairs(el:GetLines()) do table.insert(options[k], b.pos) end
						options[k] = util.TableToJSON(options[k])
					end
			end
			options["Authorized by"] = ply:GetName();
			options["Edited by"] = ply:GetName();
			options = util.TableToJSON(options);

			data["Name"] = (text:len() > 0 && text or "Unknown title");
			data["jobs"] = jobs;
			data["options"] = options;
			data["type"] = info.id

			netstream.Start("OBJs::AddObjective", data, edit or 0)

			if OBJs.editTask then
				OBJs.editTask = nil;
			end
		end
	end;

		return true;
end

function TOOL:RightClick( trace )
	return false
end;

function TOOL:Reload()
	if CLIENT then
		if OBJs.editTask then
				OBJs.editTask = nil;
		end
		local interface = OBJs.tool;
		interface.tasks:ChooseOptionID(1)
		interface.jobs:ClearSelection()
		interface.titleText:SetText("")
	end;
end

function TOOL.BuildCPanel( CPanel )
	OBJs.tool = vgui.Create("OBJs_interface", CPanel);
  OBJs.tool:Populate()
end

function TOOL:UpdateGhost( ent, ply )
	if ( !IsValid( ent ) ) then return end
	local trace, pos = ply:GetEyeTrace(), ent:GetPos()
	local Offset = pos - ent:NearestPoint( pos - ( trace.HitNormal * 64 ) )
	local interface = OBJs.tool;
	if !interface || !ply:IsAdmin() then return end;
	local name, data = interface.tasks:GetSelected()
	ent:SetAngles(Angle(0, ply:GetAngles().y-180, 0))
	ent:SetPos( trace.HitPos + Offset )
	ent:SetBodyGroups(OBJs:ExistsType(data.id).BG or "0")
	ent:SetNoDraw( false )
end

function TOOL:Think()
	local interface = OBJs.tool;
	if !interface then return end;
	local name, data = interface.tasks:GetSelected()
	if name == "" then return end;
	local obj = OBJs:ExistsType(data.id)

	if !obj || (obj && (!obj.placeholder || obj.placeholder == "")) then 
		self:ReleaseGhostEntity()
		return 
	end;
	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != obj.placeholder ) then
		self:MakeGhostEntity( obj.placeholder, vector_origin, angle_zero )
	end
	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
end

hook.Add( "PostDrawTranslucentRenderables", "objectives::drawToolRadius", function()
if game.SinglePlayer() then return end;
		local interface = OBJs:ToolValidation();
		if !interface then return end;

		local plyPos, trace = LocalPlayer():GetPos(), LocalPlayer():GetEyeTraceNoCursor()
		local pos = trace.HitPos
		local options = interface.details.optionsList
		local radius = options && options["Radius"] && options["Radius"]["element"] && options["Radius"]["element"]:GetValue()
		if radius then
			local distance = math.Round(plyPos:Distance( pos ))
			cam.Start3D2D( pos + Vector(0, 0, 15), angle_zero, 1 )
				draw.NoTexture()
  	  	surface.SetDrawColor(Color(255, 255, 255, math.max((radius+640) - distance, 0 )))
				for k, v in pairs(draw.drawSubSection(0, 0, radius, 2, 0, 365, 5, true)) do surface.DrawPoly(v) end
			cam.End3D2D();			
		end
		local text = interface.titleText:GetText():upper();

		cam.Start2D()
			local infoLabelPos = pos + (trace.Entity != Entity(0) && Vector(0, 0, 50) || Vector(0, 0, 100));
			local infoLabelToScreen = infoLabelPos:ToScreen()
			local meters = math.Round( infoLabelPos:Distance( plyPos ) / 28 ) .. " m"
			draw.SimpleText((text:len() > 0 && text or "UNKNOWN TITLE"), "FONT_bold", infoLabelToScreen.x, infoLabelToScreen.y, Color(170, 170, 170), 1 )
			draw.SimpleText(meters, "FONT_medium", infoLabelToScreen.x, infoLabelToScreen.y+30, Color(170, 170, 170), 1 )
		cam.End2D()
end)

hook.Add( "PreDrawHalos", "objectives::drawToolHalo", function()
if game.SinglePlayer() then return end;
		local interface = OBJs:ToolValidation();
		if !interface then return end;

		local name, data = interface.tasks:GetSelected()
		if name == "" then return end;
		local obj = OBJs:ExistsType(data.id)
		local plyPos, trace = LocalPlayer():GetPos(), LocalPlayer():GetEyeTraceNoCursor()

		if obj && obj.entity then
			halo.Add({trace.Entity}, Color(255, 100, 100), 1, 1, 6, true, true )
		end;
end )