local PLUGIN = PLUGIN

PLUGIN.name = "Tab Menu"
PLUGIN.description = ""
PLUGIN.author = "Крыжовник"

ix.config.Add("tabMenuTitle", false, "Wether or not there should be titles on tabs within the tab menu. (NOTE: THIS CAN BE BUGGY ON PLUGINS THAT ADD CUSTOM TABS)", function()
    if ( CLIENT ) then
        ix.util.Notify("Reopen the tab menu!")
    end
end, {
    category = "Appearance (User Interface)",
})