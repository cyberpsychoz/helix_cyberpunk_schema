
ITEM.name = "Фонарик"
ITEM.model = Model("models/raviool/flashlight.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Угадайте для чего нужна эта штука?"
ITEM.category = "Tools"
ITEM.price = 45

ITEM:Hook("drop", function(item)
    item.player:SetNWBool("ixFlashlight", false)
end)
