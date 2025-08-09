ITEM.name = "Жетон ГПМ"
ITEM.description = "Самый обыкновенный полицейский жетон."
ITEM.model = "MODEL"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 0

function ITEM:GetName()
    return self.name
end

function ITEM:GetDescription()
    return self.description
end