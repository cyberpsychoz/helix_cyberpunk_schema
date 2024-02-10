local PANEL = {}

function PANEL:Init() 
    local sw, sh = ScrW(), ScrH()
    self:Dock(TOP)
    self:SetTall(sh * 0.250)
end;

function PANEL:Populate(type)
		local data = util.JSONToTable(OBJs:ExistsType(type).options)
		self.optionsList = {}

		for k, v in pairs(data) do
			self.lbl = self:Add("ObjectiveLabel")
    	self.lbl:SetText(k)

			if v.info == "number" or v.info == "float" || v.info == "time" then
				self._number = self:Add( "DNumSlider" )
				self._number:Dock(TOP)
    		self._number:SetText( "" )
    		self._number.Label:SetVisible(false)
    		self._number.TextArea:SetTextColor(Color(255, 255, 255))
    		self._number:SetMinMax( v.min, v.max )
    		self._number:SetDecimals( (v.info == "float" && 1) or 0 )
				self.optionsList[k] = {element = self._number, info = v.info}
			end

			if v.info == "position" then
					self.posLbl = self:Add("ObjectiveLabel")
					self.posLbl:Dock(TOP)
    			self.posLbl:SetText("0, 0, 0")

					self.posBtn = self:Add("ObjButton")
					self.posBtn:Dock(TOP)
					self.posBtn:SetText("Set position")
					self.posBtn.DoClick = function(btn)
							local pos = LocalPlayer():GetPos()
							self.posLbl:SetText(math.Round(pos.x) .. " " .. math.Round(pos.y) .. " " .. math.Round(pos.z))
							self.posLbl.pos = pos.x .. " " .. pos.y .. " " .. pos.z;
					end;

					self.optionsList[k] = {element = self.posLbl, info = v.info}
			end

			if v.info == "position_list" then
					self.posList = self:Add("ObjListView")
    			self.posList:Column( "Position Vector" )

					self.posAdd = self:Add("ObjButton")
					self.posAdd:Dock(TOP)
    			self.posAdd:SetText("Add current position")

					self.posAdd.DoClick = function(btn)
							if btn.BtnCooldDown && CurTime() < btn.BtnCooldDown then
            		return;
        			end
        			btn.BtnCooldDown = CurTime() + 1;
							local pos = LocalPlayer():GetPos()
							local pos_line = self.posList:AddLine( math.Round(pos.x) .. " " .. math.Round(pos.y) .. " " .. math.Round(pos.z) )
							pos_line.pos = pos.x .. " " .. pos.y .. " " .. pos.z;
							for k, v in pairs(pos_line.Columns) do
            			v:SetTextColor(color_white)
            			v:SetFont("FONT_medium")
            			v:SetContentAlignment(5)
        			end

							pos_line.OnMousePressed = function(_subbut, key)
										local menu = DermaMenu() 
										menu:AddOption( "Remove", function() 
												self.posList:RemoveLine(_subbut:GetID())
										end )
										menu:Open()
							end;
					end;
					self.optionsList[k] = {element = self.posList, info = v.info}
			end

			if v.info == "reinforcement" then
					self.reLBL = self:Add("ObjectiveLabel")
					self.reLBL:Dock(TOP)
    			self.reLBL:SetText("0, 0, 0")

					self.posRe = self:Add("ObjButton")
					self.posRe:SetText("Set position")
					self.posRe:Dock(TOP)
					self.posRe.DoClick = function(btn)
							local pos = LocalPlayer():GetPos()
							self.reLBL:SetText(math.Round(pos.x) .. " " .. math.Round(pos.y) .. " " .. math.Round(pos.z))
							self.reLBL.pos = pos.x .. " " .. pos.y .. " " .. pos.z;
					end;

					self.reMdlLBL = self:Add("ObjectiveLabel")
					self.reMdlLBL:Dock(TOP)
    			self.reMdlLBL:SetText("Model of the reinforcements entity")

					self.reModel = self:Add("ObjectiveText")
					self.reModel:Dock(TOP)

					self.optionsList[k] = {element = self.reLBL, reModel = self.reModel, info = v.info}
			end

			if v.info == "text" then
					self.textInfo = self:Add("ObjectiveText")
					self.textInfo:Dock(TOP)

					self.optionsList[k] = {element = self.textInfo, info = v.info}
			end

			if v.info == "npc" then
				self._npc = self:Add("ObjListView")
    		self._npc:Column( "Name" )
				for k, v in pairs(list.Get( "NPC" )) do
        		local team_line = self._npc:AddLine( k )
        		team_line.name = k
        		for k, v in pairs(team_line.Columns) do
            		v:SetTextColor(color_white)
            		v:SetFont("FONT_medium")
            		v:SetContentAlignment(5)
        		end
    		end
				self.optionsList[k] = {element = self._npc, info = v.info}
			end;

			if v.info == "weapons" then
				self.weapons = self:Add("ObjListView")
				self.weapons:SetMultiSelect(false)
    		self.weapons:Column( "Weapon class" )
				for k, v in pairs(list.Get( "Weapon" )) do
        		local weapon = self.weapons:AddLine( k )
        		weapon.name = k
        		for k, v in pairs(weapon.Columns) do
            		v:SetTextColor(color_white)
            		v:SetFont("FONT_medium")
            		v:SetContentAlignment(5)
        		end
    		end
				self.optionsList[k] = {element = self.weapons, info = v.info}
			end;

		end;

		for k, v in pairs(self:GetCanvas():GetChildren()) do
        if v.GetMin then
            v:SetValue(v:GetMin())
        end
    end
end;

function PANEL:Paint( w, h ) 
    surface.SetDrawColor(Color(10, 10, 10, 10))
    surface.DrawOutlinedRect( 0, 0, w, h, 1 )        
end;

vgui.Register( "Objectives", PANEL, "ObjectiveScroll" )