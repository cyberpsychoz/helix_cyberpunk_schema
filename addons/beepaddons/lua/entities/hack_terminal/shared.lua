ENT.Type = "anim";
ENT.Author = "Ross";
ENT.PrintName = "Terminal to sabotage";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.Category = 'Cyberpunk RED Terminals'

function ENT:GetDefaultModel()
	return 'models/kingpommes/starwars/misc/palp_panel1.mdl';
end;

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Malwared")
	self:NetworkVar("Int", 1, "OBJid")
end;