include("shared.lua"); 
AddCSLuaFile("cl_init.lua"); 
AddCSLuaFile("shared.lua");

function ENT:Initialize()
	self:SetModel(self:GetDefaultModel())
	self:DrawShadow(false);
	self:SetSolid(SOLID_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetCollisionGroup(11)

	local physObj = self:GetPhysicsObject();
	if (IsValid(physObj)) then
		physObj:EnableMotion(false);
		physObj:Sleep();
	end;

	self.light = ents.Create("light_dynamic")
	self.light:Spawn()
	self.light:Activate()
	self.light:SetPos( self:GetPos() + (self:GetUp() * 50) + (self:GetForward() * -20) + (self:GetRight() * 0) )
	self.light:SetKeyValue("distance", 0)
	self.light:SetKeyValue("brightness", 0)
	self.light:SetKeyValue("_light", "255 100 100")
	self.light:Fire("TurnOn")
	self.light:SetParent( self )
end;