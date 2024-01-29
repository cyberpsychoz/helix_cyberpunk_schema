
include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

ENT.PopulateEntityInfo = true
function ENT:OnPopulateEntityInfo(container)
	local text = container:AddRow("name")
	text:SetImportant()
	text:SetText( "Очень старый радиоприемник" )
	text:SizeToContents()

	local description = container:AddRow("description")
	description:SetBackgroundColor( Color(0, 0, 0, 155) )
	description:SetText( "Такое радио большая редкость, можно сказать раритет, учитывая то, какой сейчас год. Забавно что оно до сих пор может поймать несколько радиостанций. Интересно откуда ведется трансляция?" )
	description:SizeToContents()
end
