local PLUGIN = PLUGIN

PLUGIN.name = "Mining System"
PLUGIN.description = "Self-exlpanatory."
PLUGIN.author = "Riggs.mackay"

if ( SERVER ) then
    function PLUGIN:SaveData()
        local data = {}
    
        for _, v in ipairs(ents.FindByClass("ix_mining_*")) do
            data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetModel(), v:GetClass()}
        end
    
        ix.data.Set("miningEntities", data)
    end

    function PLUGIN:LoadData()
        for _, v in ipairs(ix.data.Get("miningEntities") or {}) do
            local miningEntity = ents.Create(v[4])
    
            miningEntity:SetPos(v[1])
            miningEntity:SetAngles(v[2])
            miningEntity:SetModel(v[3])
            miningEntity:Spawn()
        end
    end
end