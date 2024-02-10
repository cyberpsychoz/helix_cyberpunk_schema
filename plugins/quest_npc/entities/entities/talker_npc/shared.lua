ENT.Type = "anim";
ENT.Author = "Ross";
ENT.PrintName = "Quester";
ENT.Spawnable = true;
ENT.AdminSpawnable = true;
ENT.PhysgunDisabled = false;
ENT.Category = 'Quester'

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, 'DefaultName')
end;

function ENT:SpawnFunction(client, trace)
	local newTrace = client:GetEyeTraceNoCursor()

	local entity = ents.Create("talker_npc")
	entity:SetPos(newTrace.HitPos)

	local angles = (entity:GetPos() - client:GetPos()):Angle()
	angles.p = 0
	angles.y = 0
	angles.r = 0

	entity:SetAngles(angles)
	entity:Spawn()
	entity:Activate()

	for k, v in pairs(ents.FindInBox(entity:LocalToWorld(entity:OBBMins()), entity:LocalToWorld(entity:OBBMaxs()))) do
		if (string.find(v:GetClass(), "prop") and v:GetModel() == 'models/Humans/Group01/Male_01.mdl') then 
			entity:SetPos(v:GetPos())
			entity:SetAngles(v:GetAngles())
			SafeRemoveEntity(v)

			break
		end
	end

	return entity
end;