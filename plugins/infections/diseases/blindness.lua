
return {
    name = "Черная слепота",
    description = "Заствляет потерять вас одно из чувств навсегда... Или нет?",
    canGetRandomly = true,
    immuneFactions = { FACTION_AUTORAVE },

    functionsIsClientside = true,
    OnCall = [[
        local function blind()
            alpha = math.abs(math.cos(RealTime() * .5) * 255)
            draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), ColorAlpha(Color(0,0,0), alpha))
        end
        hook.Add("HUDPaint", "Diseases_blindness", blind)
    ]],
    OnEnd = [[
        hook.Remove("HUDPaint", "Diseases_blindness")
    ]]
}
