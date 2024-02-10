
surface.CreateFont( "CONSOLE", {
	font = "Consolas",
	extended = false,
	size = 8,
	weight = 5000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

language.Add( "tool.sensor_id.name", "Sensor ID checker" )
language.Add( "tool.sensor_id.desc", "Left click: check sensor ID." )
language.Add( "tool.terminaltool.name", "Sensor tool" )
language.Add( "tool.terminaltool.desc", "Left click: add sensor to list. Right click: remove sensor from list. Reload: Clear sensors list." )