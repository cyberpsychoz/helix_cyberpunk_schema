local PLUGIN = PLUGIN

PLUGIN.name = "Улучшенный лут"
PLUGIN.descriptions = "СКИБИДИ КРИПЕР ОР ТОЙЛЕТ???"
PLUGIN.author = "Крыжовник"

CAMI.RegisterPrivilege({
    Name = "Helix - Manage Loot Containers",
    MinAccess = "admin"
})

ix.loot = ix.loot or {}
ix.loot.containers = ix.loot.containers or {}

ix.loot.containers = {
    ["crate"] = {
        name = "Деревянный ящик",
        description = "Тестовое описание",
        model = "models/props_junk/wood_crate001a_damaged.mdl",
        skin = 1,
        delay = 180, -- time in seconds before it can be looted again
        lootTime = {3, 4, 5, 6}, -- can be a table for random time, example: lootTime = {2, 5, 7, 8, 10},
        maxItems = {1, 2, 3}, -- how many items can be in the container
        items = {
            "meth",
        },
        rareItems = {
			"meth",
        },
        onStart = function(ply, ent) -- when you press e on the container
        end,
        onEnd = function(ply, ent) -- when you finished looting the container
        end,
    },
    ["barrel"] = {
        name = "Ржавая бочка",
        description = "Тестовое описание",
        model = "models/props_c17/oildrum001.mdl",
        skin = 1,
        delay = 180, -- time in seconds before it can be looted again
        lootTime = {3, 4, 5, 6}, -- can be a table for random time, example: lootTime = {2, 5, 7, 8, 10},
        maxItems = {1, 2, 3}, -- how many items can be in the container
        items = {
            "meth",
        },
        rareItems = {
            "meth",
        },
        onStart = function(ply, ent) -- when you press e on the container
        end,
        onEnd = function(ply, ent) -- when you finished looting the container
        end,
    },
    ["dumpster"] = {
        name = "Мусорный контейнер",
        description = "Тестовое описание",
        model = "models/props_junk/TrashDumpster01a.mdl",
        skin = 0,
        delay = 180, -- time in seconds before it can be looted again
        lootTime = {3, 4, 5, 6}, -- can be a table for random time, example: lootTime = {2, 5, 7, 8, 10},
        maxItems = {1, 2, 3}, -- how many items can be in the container
        items = {
            "meth",
        },
        rareItems = {
            "meth",
        },
        onStart = function(ply, ent) -- when you press e on the container
        end,
        onEnd = function(ply, ent) -- when you finished looting the container
        end,
    },
	["bookshelf"] = {
        name = "Книжная полка",
        description = "Тестовое описание",
        model = "models/props/cs_office/bookshelf1.mdl",
        skin = 0,
        delay = 180, -- time in seconds before it can be looted again
        lootTime = {3, 4, 5, 6}, -- can be a table for random time, example: lootTime = {2, 5, 7, 8, 10},
        maxItems = {1, 2, 3}, -- how many items can be in the container
        items = {
            "meth",
        },
        rareItems = {
            "meth",
        },
        onStart = function(ply, ent) -- when you press e on the container
        end,
        onEnd = function(ply, ent) -- when you finished looting the container
        end,
    },
	    ["trash"] = {
        name = "Мусорка",
        description = "Тестовое описание",
        model = "models/willardnetworks/props/trash03.mdl",
        skin = 0,
        delay = 180, -- time in seconds before it can be looted again
        lootTime = {3, 4, 5, 6}, -- can be a table for random time, example: lootTime = {2, 5, 7, 8, 10},
        maxItems = {1, 2, 3}, -- how many items can be in the container
        items = {
            "meth",
        },
        rareItems = {
            "meth",
        },
        onStart = function(ply, ent) -- when you press e on the container
        end,
        onEnd = function(ply, ent) -- when you finished looting the container
        end,
    },
  ["vehicle"] = {
        name = "Разбитая машина",
        description = "Тестовое описание",
        model = "models/props_vehicles/car001a_hatchback.mdl",
        skin = 0,
        delay = 180, -- time in seconds before it can be looted again
        lootTime = {3, 4, 5, 6}, -- can be a table for random time, example: lootTime = {2, 5, 7, 8, 10},
        maxItems = {1, 2, 3}, -- how many items can be in the container
        items = {
            "meth",
        },
        rareItems = {
            "meth",
        },
        onStart = function(ply, ent) -- when you press e on the container
        end,
        onEnd = function(ply, ent) -- when you finished looting the container
        end,
    },
   	["wood_barrel"] = {
        name = "Бочка",
        description = "Тестовое описание",
        model = "models/mosi/fallout4/props/fortifications/woodenbarrel.mdl",
        skin = 0,
        delay = 180, -- time in seconds before it can be looted again
        lootTime = {3, 4, 5, 6}, -- can be a table for random time, example: lootTime = {2, 5, 7, 8, 10},
        maxItems = {1}, -- how many items can be in the container
        items = {
            "meth",
        },
        rareItems = {
            "meth",
        },
        onStart = function(ply, ent) -- when you press e on the container
        end,
        onEnd = function(ply, ent) -- when you finished looting the container
        end,
    },
}
properties.Add("loot_setclass", {
    MenuLabel = "Выбрать тип контейнера",
    MenuIcon = "icon16/wrench.png",
    Order = 5,

    Filter = function(self, ent, ply)
        if not ( IsValid(ent) and ent:GetClass() == "ix_loot_container" ) then return false end

        return CAMI.PlayerHasAccess(ply, "Helix - Manage Loot Containers", nil)
    end,

    Action = function(self, ent)
    end,

    LootClassSet = function(self, ent, class)
        self:MsgStart()
            net.WriteEntity(ent)
            net.WriteString(class)
        self:MsgEnd()
    end,

    MenuOpen = function(self, option, ent, trace)
        local subMenu = option:AddSubMenu()

        for k, v in SortedPairs(ix.loot.containers) do
            subMenu:AddOption(v.name.." ("..k..")", function()
                self:LootClassSet(ent, k)
            end)
        end
    end,

    Receive = function(self, len, ply)
        local ent = net.ReadEntity()

        if not ( IsValid(ent) ) then return end
        if not ( self:Filter(ent, ply) ) then return end

        local class = net.ReadString()
        local loot = ix.loot.containers[class]

        -- safety check, just to make sure if it really exists in both realms.
        if not ( class or loot ) then
            ply:Notify("You did not specify a valid container class!")
            return
        end

        ent:SetContainerClass(tostring(class))
        ent:SetModel(loot.model)
        ent:SetSkin(loot.skin or 0)
        ent:PhysicsInit(SOLID_VPHYSICS) 
        ent:SetSolid(SOLID_VPHYSICS)
        ent:SetUseType(SIMPLE_USE)
        ent:DropToFloor()

        PLUGIN:SaveData()
    end
})

if ( SERVER ) then
    function PLUGIN:SaveData()
        local data = {}
    
        for _, v in pairs(ents.FindByClass("ix_loot_container")) do
            data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetContainerClass(), v:GetModel(), v:GetSkin()}
        end
    
        ix.data.Set("lootContainer", data)
    end

    function PLUGIN:LoadData()
        for _, v in pairs(ix.data.Get("lootContainer")) do
            local lootContainer = ents.Create("ix_loot_container")
            lootContainer:SetPos(v[1])
            lootContainer:SetAngles(v[2])
            lootContainer:SetContainerClass(v[3])
            timer.Simple(1, function()
                if ( IsValid(lootContainer) ) then
                    lootContainer:SetModel(v[4])
                    lootContainer:SetSkin(v[5])
                end
            end)
            lootContainer:Spawn()
        end
    end
end
