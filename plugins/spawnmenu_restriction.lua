local PLUGIN = PLUGIN

PLUGIN.name = "Some shit rectriction"
PLUGIN.description = "Убирает раздельно контекстное меню и Q меню."
PLUGIN.author = "Крыжовник"

ix.flag.Add("x", "Доступ к Q меню.")
--ix.flag.Add("x", "Доступ к контекстному меню.")

if ( CLIENT ) then
    function PLUGIN:OnSpawnMenuOpen()
        if not LocalPlayer():GetCharacter():HasFlags("e") then
            return false
        end
    end
    --[[
    function PLUGIN:OnContextMenuOpen()
        if not ( LocalPlayer():GetCharacter():HasFlags("e") ) then
            return false
        end
    end
    ]]
end