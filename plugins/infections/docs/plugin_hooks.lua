
-- @Hook: Может ли игрок заболеть [CanPlayerGetDisease]
-- @Realm: Server
-- @Description: Может ли игрок заболеть болезнью?
-- @Arguments: Player player, String disease
-- @Return: true, если игрок не может заболеть, false, если игрок может заболеть

function PLUGIN:CanPlayerGetDisease(player, disease)
end

-- @Hook: Может ли игрок вылечиться? [CanPlayerDisinfect]
-- @Realm: Server
-- @Description: Can a player cure disease?
-- @Arguments: Player player, String disease
-- @Return:  true, если игрок не может вылечить болезнь, false, если игрок может вылечить болезнь

function PLUGIN:CanPlayerDisinfect(player, disease)
end

-- @Hook: Игрок заражен [PlayerInfected]
-- @Realm: Server
-- @Description: Вызывается, когда игрок заболевает
-- @Arguments: Player player, String disease
-- @Return: да нихуя она не возвращает, в рот мне ноги, в жопу хуй

function PLUGIN:PlayerInfected(player, disease)
end

-- @Hook: Игрок вылечен [PlayerDisinfected]
-- @Realm: Server
-- @Description: Вызывается, когда игрок вылечивает болезнь
-- @Arguments: Player player, String disease
-- @Return: а хули она тебе возвращать должна? разве что пизды

function PLUGIN:PlayerDisinfected(player, disease)
end
