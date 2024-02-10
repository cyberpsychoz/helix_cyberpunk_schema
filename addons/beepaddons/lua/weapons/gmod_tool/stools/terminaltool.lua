-- TOOL.AddToMenu = true
TOOL.Category = "Terminal Tools"
TOOL.Name = "#tool.terminaltool.name"

function TOOL:LeftClick( trace )
	local ent = trace.Entity;
		if CLIENT then
			if ent && ent:GetClass() == 'sensor' && !ent:GetGrouped() && !TERMINAL.sensorsList[ent:GetIndex()] then
				TERMINAL.sensorsList[ent:GetIndex()] = ent
				if TERMINAL.intTOOLEDIT && TERMINAL.intTOOLEDIT:IsValid() then
					local newLine = TERMINAL.intTOOLEDIT.list:AddLine(ent:GetIndex());
					newLine.id = ent:GetIndex();
					newLine.entID = ent:EntIndex();
					newLine.data = {}
				end
			end
		end;
	return true;
end

function TOOL:RightClick( trace )
	local ent = trace.Entity;
	if CLIENT then
		if ent && ent:GetClass() == 'sensor' && TERMINAL.sensorsList[ent:GetIndex()] then
			TERMINAL.sensorsList[ent:GetIndex()] = nil;
			if TERMINAL.intTOOLEDIT && TERMINAL.intTOOLEDIT:IsValid() then
				for k, v in pairs(TERMINAL.intTOOLEDIT.list:GetLines()) do
					if v.id == ent:GetIndex() then
						TERMINAL.intTOOLEDIT.list:RemoveLine( k )
					end
				end
			end
		end
	end
	return true;
end;

function TOOL:Reload( trace )
	if CLIENT && TERMINAL.intTOOLEDIT && TERMINAL.intTOOLEDIT:IsValid() then
		TERMINAL.sensorsList = {}
 		TERMINAL.intTOOLEDIT.list:Clear();
		surface.PlaySound("buttons/combine_button1.wav")
	end;
end

function TOOL.BuildCPanel( CPanel )
	local function FormSensorGroup()
		return os.time() + math.random(1000, 2000);
	end;
	CPanel.header = CPanel:AddControl( "Header", { Description = "#tool.terminaltool.desc" } )
	CPanel.list = CPanel:AddControl("listbox", { Height = 256, Label = "List of grouped sensors" })
	CPanel.label = CPanel:AddControl("label", { Text = "To form a group ID - add sensors to list and click 'Form a group' button" })
	CPanel.GroupID = CPanel:AddControl("textbox", { Label = "Group ID: " })
	CPanel.GroupID:SetEnabled(false)
	CPanel.formGroup = CPanel:AddControl("button", { Text = "Form a group" })

	CPanel.formGroup.DoClick = function()
		if TERMINAL.sensorsList && TERMINAL.intTOOLEDIT then
			CPanel.GroupID:SetText(FormSensorGroup())
			netstream.Start('terminal::formSensorGroup', TERMINAL.sensorsList, CPanel.GroupID:GetText());
			TERMINAL.sensorsList = {}
			TERMINAL.intTOOLEDIT.list:Clear();
			surface.PlaySound("buttons/combine_button1.wav")
		end;
	end

	TERMINAL.intTOOLEDIT = CPanel;
end