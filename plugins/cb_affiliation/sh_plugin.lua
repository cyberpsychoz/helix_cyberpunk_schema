local PLUGIN = PLUGIN

PLUGIN.name = "Cyberpunk Кастомные фракции"
PLUGIN.description = "Позволяет ебануть игроку любую организацию и тд."
PLUGIN.author = "Крыжовник"

--ix.util.Include("cl_plugin.lua")
--ix.util.Include("sv_plugin.lua")

ix.command.Add("CharSetAffil", {
    arguments = {
        ix.type.player,
        ix.type.string
    },
    description = "Позволяет игроку выбирать принадлежность к той или иной организации.",
    adminOnly = true,
    OnRun = function(self, client, target, affiliation)
        if target and target:GetCharacter() then
            local character = target:GetCharacter()
            character:SetData("affiliation", affiliation)
        else
            client:Notify("Такой оболочки не существует!")
        end
    end
})

ix.command.Add("CharGetAffil", {
    arguments = {
        ix.type.player,
    },
    description = "Позволяет увидеть принадлежность игрока.",
    adminOnly = true,
    OnRun = function(self, client, target)
        local character = target:GetCharacter()
        if character then
            local aff = character:GetData("affiliation", "Не имеется.")
            client:Notify("Принадлежность: " .. aff)
        else
            client:Notify("Такой оболочки не существует!")
        end   
    end
})