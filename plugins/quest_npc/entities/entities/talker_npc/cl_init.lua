include("shared.lua");

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;

function ENT:OnPopulateEntityInfo(tooltip)
	local sellername = tooltip:AddRow("name")
	sellername:SetImportant()
	sellername:SetText(self:GetDefaultName())
	sellername:SetBackgroundColor(Color(255, 255, 255, 0))
	sellername:SetTextInset(8, 0)
	sellername:SizeToContents()
end

function ENT:GetEntityMenu(client)
	local options = {};
	options["Talk"] = "talker_npc_talk";
	if client:IsAdmin() or client:IsSuperAdmin() then
		options["Options"] = "talker_npc_settings";
	end;
	return options
end;