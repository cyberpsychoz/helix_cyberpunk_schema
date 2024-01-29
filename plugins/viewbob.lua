local PLUGIN = PLUGIN

PLUGIN.name = "Охуевшая камера"
PLUGIN.description = "Трахает вашу камеру пока вы бегаете, красиво!"
PLUGIN.author = "Крыжовник"

ix.lang.AddTable("english", {
    optViewbob = "View Bobbing",
    optdViewbob = "Wheter or not to enable view bobbing.",
})

ix.option.Add("viewbob", ix.type.bool, true, {
    category = PLUGIN.name,
    default = true,
})

if not ( CLIENT ) then return end

local angleLerp
local speed
function PLUGIN:CalcView(ply, pos, ang, fov, nearZ, farZ)
    if ( IsValid(ix.gui.characterMenu) and not ix.gui.characterMenu:IsClosing() ) then return end
    if ( ply.ixRagdoll or ply.ixIntroState ) then return end
    if ( ix.option.Get("thirdpersonEnabled") ) then return end
    if not ( ix.option.Get("viewbob") ) then return end
    if ( ply:InVehicle() ) then return end

    local view = {
        origin = pos,
        angles = ang,
        fov = fov - 5,
    }

    if not ( angleLerp ) then
        angleLerp = ang
    end

    if not ( speed ) then
        speed = 0
    end

    if ( IsValid(ply) and ply:Alive() ) and not ( ply:GetMoveType() == MOVETYPE_NOCLIP or ply.ixRagdoll ) then
        local ft = FrameTime()
        local rl = RealTime()

        speed = math.Round(Lerp(ft * 8, speed, math.Clamp(ply:GetVelocity():Length() / 20, 1, 10)), 2)

        ang.p = ang.p + math.cos(rl * 2) * 0.1 * speed
        ang.r = ang.r + math.cos(rl * 3) * 0.1 * speed
        ang.y = ang.y + math.sin(rl * 5) * 0.1 * speed

        angleLerp = LerpAngle(0.3, angleLerp, ang)
    else
        angleLerp = ang
    end

    view.angles = angleLerp

    return view
end

-- in the future someone can fix this
--[[
local angleLerp
local LOWERED_ANGLES = Angle(30, 0, -25)
function GAMEMODE:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
    if not ( IsValid(weapon) ) then
        return
    end

    if not ( angleLerp ) then
        angleLerp = eyeAngles
    end

    local ft = FrameTime()
    local ply = LocalPlayer()
    local bWepRaised = ply:IsWepRaised()

    if ( ply.ixWasWeaponRaised != bWepRaised ) then
        local fraction = bWepRaised and 0 or 1

        ply.ixRaisedFraction = 1 - fraction
        ply.ixRaisedTween = ix.tween.new(0.75, ply, {
            ixRaisedFraction = fraction
        }, "outQuint")

        ply.ixWasWeaponRaised = bWepRaised
    end

    local fraction = ply.ixRaisedFraction
    local rotation = weapon.LowerAngles or LOWERED_ANGLES

    if ( ix.option.Get("altLower", true) and weapon.LowerAngles2 ) then
        rotation = weapon.LowerAngles2
    end

    eyeAngles:RotateAroundAxis(eyeAngles:Up(), rotation.p * fraction)
    eyeAngles:RotateAroundAxis(eyeAngles:Forward(), rotation.y * fraction)
    eyeAngles:RotateAroundAxis(eyeAngles:Right(), rotation.r * fraction)

    viewModel:SetAngles(eyeAngles)

    if ( ix.option.Get("viewbob") ) then
        angleLerp = LerpAngle(ft * 8, angleLerp, eyeAngles)
        eyeAngles = angleLerp
    end

    return GAMEMODE.BaseClass:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
end
]]