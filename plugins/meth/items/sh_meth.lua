-- Item Statistics

ITEM.name = "Methamphetamine"
ITEM.description = "A small jar containing a greying-blue powder. It has some nasty side-effects which may include genuine weakness or unnatural overdose."
ITEM.category = "Medical Items"

-- Item Configuration

ITEM.model = "models/willardnetworks/skills/buffout.mdl"
ITEM.skin = 0

-- Item Inventory Size Configuration

ITEM.width = 1
ITEM.height = 1

-- Item Custom Configuration

ITEM.bDropOnDeath = true

-- Item Functions

ITEM.functions.Apply = {
    name = "Smoke",
    icon = "icon16/pill.png",
    OnRun = function(itemTable)
        local ply = itemTable.player
        local char = ply:GetCharacter()

        if ( char:IsCombine() ) then
            ply:Notify("You are apart of the Combine, you cannot smoke meth!")
            return false
        end

        if ( math.random(1,4) == 4 ) and ( char:GetData("ixHigh") ) then
            ix.chat.Send(ply, "me", "falls on the ground and slowly dies due to overdose.", false)
            ply:Notify("You have died of overdose!")
            ply:Kill()
            return false
        end

        ix.chat.Send(ply, "me", "opens up a small jar and starts to smoke the contents of it.", false)
        ply:Freeze(true)
        ply:SetAction("Smoking Crack...", 3, function()
            local lastHealth = ply:Health()
            ply:Notify("You have smoked some meth.")
            ply:Freeze(false)
            ply:SetHealth(ply:Health() + 80)
            ply:EmitSound("vo/npc/male01/pain0"..math.random(7,9)..".wav", 80)
            ply:ViewPunch(Angle(-10, 0, 0))
            timer.Simple(1, function() ply:EmitSound("vo/npc/male01/yeah02.wav") end)
            char:SetData("ixHigh", true)
            timer.Simple(90, function()
                if ( char:GetData("ixHigh") ) then
                    ply:Notify("Your crack has worn off...")
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
