local PLUGIN = PLUGIN

function PLUGIN:CreateMenuButtons(tabs)
    local ply, char = LocalPlayer(), LocalPlayer():GetCharacter()
    if not ( ply:IsSuperAdmin() ) then return end

    tabs["админ"] = {
        Create = function(info, container)
            local scrollpanel = container:Add("DScrollPanel")
            scrollpanel:Dock(FILL)
            scrollpanel.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
            end

            self.category = container:Add("DCategoryList")
            self.category:Dock(FILL)
            self.category.Paint = function() end

            local items = ix.item.list
            local itemCategories = {}
        
            for k, v in SortedPairs(items) do
                itemCategories[v.category or v.Category] = true
            end

            for k2, v2 in SortedPairs(itemCategories) do
                local cat = self.category:Add(k2)
                local panel = vgui.Create("DScrollPanel")
                panel:SetSize(scrollpanel:GetWide(), 250)

                for k, v in SortedPairs(items) do
                    if ( v.category == k2 ) then
                        local itemButton = panel:Add("ixMenuButton")
                        itemButton:Dock(TOP)
                        itemButton:SetTall(40)
                        itemButton:SetText("    "..tostring(v.name))
                        --itemButton:SetFont("Font-Elements30")
                        itemButton.DoClick = function(self)
                            net.Start("ixItemMenuSpawn")
                                net.WriteString(v.uniqueID)
                                net.WriteString(v.name or "unknown item name")
                            net.SendToServer()
                        end
                        itemButton.DoRightClick = function(self)
                            local menu = DermaMenu(nil, self)
                            menu:AddOption("Copy uniqueID", function()
                                SetClipboardText(v.uniqueID)
                            end)
                            menu:AddSpacer()
                            menu:AddOption("Spawn (Where you are looking at)", function()
                                net.Start("ixItemMenuSpawn")
                                    net.WriteString(v.uniqueID)
                                    net.WriteString(v.name or "unknown item name")
                                net.SendToServer()
                            end)
                            menu:AddSpacer()
                            menu:AddOption("Give", function()
                                net.Start("ixItemMenuGive")
                                    net.WriteString(v.uniqueID)
                                    net.WriteString(v.name or "unknown item name")
                                    net.WriteUInt(1, 5)
                                net.SendToServer()
                            end)
                            menu:AddSpacer()
                            for i = 1, 10 do
                                menu:AddOption("Give "..i.."x", function()
                                    net.Start("ixItemMenuGive")
                                        net.WriteString(v.uniqueID)
                                        net.WriteString(v.name or "unknown item name")
                                        net.WriteUInt(i, 5)
                                    net.SendToServer()
                                end)
                            end
                            menu:Open()

                            for _, v in pairs(menu:GetChildren()[1]:GetChildren()) do
                                if v:GetClassName() == "Label" then
                                    v:SetFont("Font-Elements18")
                                end
                            end
                        end

                        local itemButtonModel = itemButton:Add("SpawnIcon")
                        itemButtonModel:Dock(LEFT)
                        itemButtonModel:SetWide(40)
                        itemButtonModel:SetModel(tostring(v.model))
                        itemButtonModel:SetSkin(v.skin or 0)

                        cat:SetContents(panel)
                    end
                end
            end
        end,
    }
end