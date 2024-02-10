ITEM.name = "Компьютер AMARIA"
ITEM.description = "Довольно старый, но все еще рабочий компьютер для программирования электронных книг. Благодаря ему в них можно загружать информацию."
ITEM.model = "models/props/cs_office/amariapc.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Documents"
ITEM.price = 2000

ITEM.functions.Use = {
	name = "Use",
	OnClick = function(item)
		vgui.Create("ixTypewriter")
	end,
	OnRun = function(item)
		return false
	end,
	OnCanRun = function(item)
		return IsValid(item.entity)
	end
}