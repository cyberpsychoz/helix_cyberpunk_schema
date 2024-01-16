
PLUGIN.name = "Radios"
PLUGIN.author = "Bilwin"
PLUGIN.description = "Adds radio"
PLUGIN.schema = "Any"
PLUGIN.version = 1.0
PLUGIN.songs = {
    [''] = "Stop",
    ["CyberpunkMusic/wordl_on_fire.mp3"] = "Мир в огне",
    ["CyberpunkMusic/Alice_01.mp3"] = "Планета Крок",
    ["CyberpunkMusic/Alice_02.mp3"] = "Страшная тайна",
    ["CyberpunkMusic/Alice_03.mp3"] = "К звёздам",
    ["CyberpunkMusic/Alice_04.mp3"] = "Рынок животных",
}

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")