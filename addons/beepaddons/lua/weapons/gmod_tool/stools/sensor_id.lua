-- TOOL.AddToMenu = true
TOOL.Category = "Terminal Tools"
TOOL.Name = "#tool.sensor_id.name"

function TOOL:LeftClick( trace )
	local ent = trace.Entity;
	if CLIENT then
		if ent && ent:GetClass() == "sensor" && ent:GetIndex() then
			TERMINAL.idChoosen = ent:GetIndex();
			TERMINAL.groupID = ent:GetGroupIndex();
			if TERMINAL.intTOOLID && TERMINAL.intTOOLID:IsValid() then
				TERMINAL.intTOOLID.SensorID:SetText(ent:GetIndex())
				TERMINAL.intTOOLID.GroupID:SetText(ent:GetGroupIndex())
			end
		end
	end
	return true;
end

function TOOL:RightClick( trace )
	return false;
end;

function TOOL.BuildCPanel( CPanel )
	CPanel.header = CPanel:AddControl( "Header", { Description = "#tool.sensor_id.desc" } )

	CPanel.SensorID = CPanel:AddControl("textbox", { Label = "Sensor ID: " })
	CPanel.SensorID:SetEnabled(false)
	CPanel.SensorID:SetText(TERMINAL.idChoosen or "");
	CPanel.CopyI = CPanel:AddControl("button", { Text = "Copy sensor id to clipboard" })
	CPanel.CopyI.DoClick = function(self)
		SetClipboardText(CPanel.SensorID:GetText())
		surface.PlaySound("buttons/combine_button1.wav")
	end

	CPanel.GroupID = CPanel:AddControl("textbox", { Label = "Group ID: " })
	CPanel.GroupID:SetEnabled(false)
	CPanel.GroupID:SetText(TERMINAL.groupID or "");
	CPanel.CopyG = CPanel:AddControl("button", { Text = "Copy group id to clipboard" })
	CPanel.CopyG.DoClick = function(self)
		SetClipboardText(CPanel.GroupID:GetText())
		surface.PlaySound("buttons/combine_button1.wav")
	end

	TERMINAL.intTOOLID = CPanel;
end