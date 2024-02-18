ENT.Type = "anim"
ENT.PrintName = "Стол повышения навыков"
ENT.Author = "Крыжовник"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Cyberpunk RED"

if SERVER then
    util.AddNetworkString("OpenSkillMenu")

    function ENT:Initialize()
        self:SetModel("models/lt_c/desk_officer.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
    end
end

if CLIENT then
    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("БИСК - М01")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Биоинженерный стол компании \"Mega-Tech\". Изначально разрабатывался для репликантов, с целью уменьшения времени развития путем ускорения мозговых процессов при помощи особого вещества. Новые модели позволяют использовать его даже обычным людям.")
        description:SizeToContents()
    end
end