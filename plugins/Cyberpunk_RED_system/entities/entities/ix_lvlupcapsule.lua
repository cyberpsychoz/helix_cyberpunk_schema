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

    function ENT:Use(activator, caller)
        if IsValid(caller) and caller:IsPlayer() then
            local character = caller:GetCharacter()
            if character and character:GetInventory():GetItemCount("biocore") > 0 then
                local inventory = character:GetInventory()
                local item = inventory:GetID("biocore")
                print(item)
                inventory:Remove(item, 1)
                net.Start("OpenSkillMenu")
                net.Send(caller)
            else
                caller:ChatPrint("У вас нет биозаряда!")
            end
        end
    end
end

if CLIENT then
    net.Receive("OpenSkillMenu", function()
        local ply = LocalPlayer()
        OpenUpgradeMenu(ply)
    end)

    function ENT:OnPopulateEntityInfo(tooltip)
        surface.SetFont("ixIconsSmall")

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText("БИСК - X01")
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SizeToContents()

        local description = tooltip:AddRow("description")
        description:SetText("Биоинженерный стол компании \"Mega-Tech\". Изначально разрабатывался для репликантов, с целью ускорения развития путем ускорения мозговых процессов при помощи особого вещества. Новые модели позволяют использовать его обычным людям.")
        description:SizeToContents()
    end
end