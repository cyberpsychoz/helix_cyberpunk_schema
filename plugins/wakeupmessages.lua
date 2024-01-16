local PLUGIN = PLUGIN

PLUGIN.name = "Spawn Notifications"
PLUGIN.description = "A notification which tells the player their status on loading the character."
PLUGIN.author = "Riggs Mackay"

local wakeupmessages = {
    "Вы очнулись от долгого сна и пытаетесь вспомнить, кто вы и где вы...",
    "Чувствуя как запах гниющего мира проникает в ваш разум, вы просыпаетесь...",
    "Поднимасясь вы ощущаете адскую боль в ваших костях...",
    "Ваш внутренний голос говорит вам обернуться, вы просыпаетесь от панической атаки...",
    "Вы слышите отдаляющийся голос любимого человека, тревога заставляет вас очнуться...",
    "Открывая глаза, вы видите мерзкую серость, которая заставляет ваш желудок выворачиваться на изнанку...",
    "Перед вами стоит человек, он что-то говорит вам, но вы не понимаете ни единого слово... Спустя минуту силуэт расплывается...",
    "Вам снился чудесный сон, о том что когда-нибудь, все изменится...",
    "Громкая сирена въедается своими криками в ваш мозг. Вы вскакиваете на ноги, шум пропадает..."
}

function PLUGIN:PlayerSpawn(ply)
    if not ( ply:IsValid() or ply:Alive() or ply:GetCharacter() ) then return end

    --ply:ConCommand("play music/stingers/hl1_stinger_song16.mp3")
    ply:ScreenFade(SCREENFADE.IN, color_black, 3, 2)
    ply:ChatPrint(table.Random(wakeupmessages))
end
