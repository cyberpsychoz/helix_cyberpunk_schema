DrawBars = false

surface.CreateFont( "FONT_regular", {
	font = "Red Hat Display",
	extended = false,
	size = ScreenScale(8), 
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
surface.CreateFont( "FONT_ALT", {
	font = "Red Hat Display",
	extended = false,
	size = ScreenScale(9), 
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
surface.CreateFont( "FONT_medium", {
	font = "Red Hat Display",
	extended = false,
	size = ScreenScale(7),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
surface.CreateFont( "FONT_bold", {
	font = "Red Hat Display",
	extended = false,
	size = ScreenScale(11),
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

language.Add( "tool.point_tool.name", "Objectives" )