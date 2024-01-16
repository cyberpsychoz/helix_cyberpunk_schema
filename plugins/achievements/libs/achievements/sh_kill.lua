// Kill a player with a headshot
achievement = {
    name = "В яблочко!",
    description = "Убить игрока выстрелом в голову.",
    icon = "minerva/halflife2/icons/lambda.png",
    OnCompleted = function(ply)
    end
}

ix.achievements.Register(achievement)

// Kill a player with full health
achievement = {
    name = "Каратель.",
    description = "Убить игрока с полным здоровьем за один ход.",
    icon = "minerva/halflife2/icons/lambda.png",
    OnCompleted = function(ply)
    end
}

ix.achievements.Register(achievement)