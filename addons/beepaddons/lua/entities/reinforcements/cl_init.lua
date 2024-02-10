include("shared.lua");

function ENT:Draw()
	local quest = OBJs:Quest()
	if !quest["Name"] || OBJs.bufferedID != self:GetOBJid() then return end;
	
	self:DrawModel();
end;