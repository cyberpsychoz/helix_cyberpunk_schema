ITEM.name = "Системный монитор"
ITEM.description = "Можно подключить к различным устройствам и выводить на него информацию. В основном используется вместе со сканерами, деками и прочими устройствами ввода."
ITEM.model = "models/lt_c/tech/tablet_civ.mdl"
ITEM.skin = 8
ITEM.width = 2
ITEM.height = 2
ITEM.price = 1000
ITEM.category = "Tools"

ITEM.logs = {}
ITEM.ip = "0.0.0.0"

ITEM.functions.Logs = {
    name = "Посмотреть логи",
    icon = "icons/smartphone.png",

    OnRun = function(item)
       
        return false
    end,
}

ITEM.functions.IP = {
    name = "Изменить адрес",
    icon = "icons/0_1.png",

    OnRun = function(item)

        return false
    end,
}

