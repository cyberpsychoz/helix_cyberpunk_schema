local PLUGIN = PLUGIN

PLUGIN.name = "Meth"
PLUGIN.description = "Walter White moment"
PLUGIN.author = "Riggs Mackay & Walter White"

if ( SERVER ) then
    local function resetHigh(char)
        if ( char and char:GetData("ixHigh") ) then
            char:SetData("ixHigh", nil)
        end
    end

    function PLUGIN:PlayerLoadedCharacter(ply, char, oldChar)
        resetHigh(oldChar)
    end

    function PLUGIN:DoPlayerDeath(ply)
        resetHigh(ply:GetCharacter())
    end
end

if ( CLIENT ) then
    function PLUGIN:PopulateCharacterInfo(ply, char, tooltip)
        if ( char:GetData("ixHigh") ) then
            local panel = tooltip:AddRowAfter("description", "methstate")
            panel:SetText("Their eyes are flared up")
            panel:SizeToContents()
        end
    end

    function PLUGIN:HUDPaint()
        local ply, char = LocalPlayer(), LocalPlayer():GetCharacter()
    
        if not ( ply:IsValid() and ply:Alive() and char ) then return end
        if not ( char:GetData("ixHigh") ) then return end

        if ( ( ply.ixMethSound or 0 ) < CurTime() ) then
            ply:EmitSound("interlock/ambient/combine/combine_tech_spaces_0"..math.random(1,7)..".ogg", nil, math.random(100, 200))
        end

        surface.SetDrawColor(color_white)
        surface.SetMaterial(ix.util.GetMaterial("effects/tp_eyefx/tpeye2"))
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

        surface.SetMaterial(ix.util.GetMaterial("effects/tp_eyefx/tpeye3"))
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end

    local calcViewMethHookRan = nil
    function PLUGIN:CalcView(ply, pos, ang, fov)
        if not ( ply:GetCharacter() and ply:GetCharacter():GetData("ixHigh") ) then return end
        if ( calcViewMethHookRan ) then return end

        calcViewMethHookRan = true
        local view = hook.Run("CalcView", ply, pos, ang, fov)
        calcViewMethHookRan = false

        view.fov = view.fov + math.sin(RealTime() * 2) + 10

        return view
    end

    function PLUGIN:RenderScreenspaceEffects()
        if not ( LocalPlayer():GetCharacter() and LocalPlayer():GetCharacter():GetData("ixHigh") ) then return end
        local colorModify = {}
        colorModify["$pp_colour_colour"] = 2
    
        DrawColorModify(colorModify)
    end
end