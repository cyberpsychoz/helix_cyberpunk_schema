ITEM.name = "Пищевая добавка \"MUSCULAR\""
ITEM.description = "Банка содержащая белый порошок являющийся анаболиком, употребляется вместе с водой, едой, но особо отбитые жрут его на сухую."
ITEM.model = "MODEL"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 1
ITEM.category = "Прокачка"


ITEM.functions.Use = {
    name = "OptionName",
    OnRun = function(item)
        local char = item.player:GetCharacter()
        local str = char:GetAttribute("str")
        local int = char:GetAttribute("int")

        
        return false
    end
}