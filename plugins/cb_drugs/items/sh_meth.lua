-- Item Statistics

ITEM.name = "Метамфетаминовый бонг"
ITEM.description = "Маленький бонг, содержащий серовато-голубой порошок. У него есть некоторые неприятные побочные эффекты, которые могут включать в себя настоящую слабость или неестественную передозировку."
ITEM.category = "Medical Items"

-- Item Configuration

ITEM.model = "models/mark2580/gtav/mp_apa_low/lobby/bong_01.mdl"
ITEM.skin = 0

-- Item Inventory Size Configuration

ITEM.width = 1
ITEM.height = 1

-- Item Custom Configuration

ITEM.bDropOnDeath = true

-- Item Functions

ITEM.functions.Apply = {
    name = "Раскумарить",
    icon = "icon16/pill.png",
    OnRun = function(itemTable)
        local ply = itemTable.player
        local char = ply:GetCharacter()

        if ( char:GetFaction() == FACTION_AUTORAVE ) then
            ply:Notify("Дурной? Авторейвы не могут раскумариться от бонга!")
            return false
        end

        if ( math.random(1,4) == 4 ) and ( char:GetData("ixHigh") ) then
            ix.chat.Send(ply, "me", "падает на землю и медленно умирает из-за передозировки непонятным веществом.", false)
            ply:Notify("Вы умерли от передозировки!")
            ply:Kill()
            return false
        end

        ix.chat.Send(ply, "me", "смачно раскумаривается бонгом, закуривая его.", false)
        ply:Freeze(true)
        ply:SetAction("Выкуривание бонга...", 3, function()
            local lastHealth = ply:Health()
            ply:Notify("Вы выкурили немного метамфетамина.")
            ply:Freeze(false)
            ply:SetHealth(ply:Health() + 80)
            ply:EmitSound("vo/npc/male01/pain0"..math.random(7,9)..".wav", 80)
            ply:ViewPunch(Angle(-10, 0, 0))
            timer.Simple(1, function() ply:EmitSound("vo/npc/male01/yeah02.wav") end)
            char:SetData("ixHigh", true)
            timer.Simple(15, function()
                if ( char:GetData("ixHigh") ) then
                    ply:Notify("Раскумар прошел...")
                    ply:SetHealth(lastHealth)
                    ply:TakeDamage(10)
                    ply:ViewPunch(Angle(-10, 0, 0))
                    char:SetData("ixHigh", nil)
                end
            end)
            return true
        end)
    end
}
