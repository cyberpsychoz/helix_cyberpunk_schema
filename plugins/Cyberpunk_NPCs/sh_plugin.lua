local PLUGIN = PLUGIN

PLUGIN.name = "Cyberpunk NPC's"
PLUGIN.author = "Крыжовник"
PLUGIN.description = "Ебануться туфли гнуться, а у нас и такое есть!"

PLUGIN.config = {
    ["ix_solo"] = {
        rarity = 40,
        randomItems = true,
        items = {
            "soda",
        },
    },
}

ix.util.Include("sv_plugin.lua")