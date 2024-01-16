PLUGIN.name = "Cyberpunk RED system"
PLUGIN.author = "Крыжовник"
PLUGIN.description = "Сделано для проекта Cyberpunk RED."

-- [[ FILE INCLUSIONS ]] --

ix.util.Include("sh_hooks.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_config.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sh_chat.lua")
--ix.util.Include("sh_hrpgskills.lua")

PLUGIN.hudTextColors = {
	GREEN = Color(0, 255, 0),
	BLUE = Color(0, 128, 255),
	YELLOW = Color(255, 255, 0),
	RED = Color(255, 0, 0),
	BLACK = Color(128, 128, 128)
}