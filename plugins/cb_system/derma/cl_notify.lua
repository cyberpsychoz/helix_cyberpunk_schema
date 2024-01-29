local PANEL = {}

local baseSizeW, baseSizeH = ScrW() / 5, 20

function PANEL:Init()
	self.message = markup.Parse("")
	self:SetSize(baseSizeW, baseSizeH)
	self.startTime = CurTime()
	self.endTime = CurTime() + 10
end

function PANEL:SetMessage(...)
	-- Encode message into markup
	local msg = "<font=Font-Elements18>"

	for k, v in ipairs({...}) do
		if type(v) == "table" then
			msg = msg.."<color="..v.r..","..v.g..","..v.b..">"
		elseif type(v) == "Player" then
			local col = team.GetColor(v:Team())
			msg= msg.."<color="..col.r..","..col.g..","..col.b..">"..tostring(v:Name()):gsub("<", "&lt;"):gsub(">", "&gt;").."</color>"
		else
			msg = msg..tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
	end
	msg = msg.."</font>"

	-- parse
	self.message = markup.Parse(msg, baseSizeW-20)

	-- set frame position and height to suit the markup
	local shiftHeight = self.message:GetHeight()
	self:SetHeight(shiftHeight+baseSizeH)
	surface.PlaySound("buttons/lightswitch2.wav")
end

local gradient = Material("vgui/gradient-r")
local darkCol = Color(30, 30, 30, 200)
local lightCol = Color(20,20,20,80)
local hudBlackGrad = Color(40,40,40,120)
local lifetime = 10

function PANEL:Paint(w,h)
	-- draw frame
	ix.util.DrawBlur(self)
	surface.SetDrawColor(ColorAlpha(ix.config.Get("color"), 5))
	surface.DrawRect(0,0,w,h)
	surface.SetDrawColor(ColorAlpha(darkCol, 50))
	surface.DrawRect(0,0,w,h)
	surface.SetDrawColor(darkCol)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0,0,w,h)

	-- draw message
	self.message:Draw(10,10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	-- draw timebar
	local w2 = math.TimeFraction(self.startTime, self.endTime, CurTime()) * w
	surface.SetDrawColor(ix.config.Get("color"))
	surface.DrawRect(w2, h-2, w - w2, 2)
end

vgui.Register("ixNotify", PANEL, "DPanel")