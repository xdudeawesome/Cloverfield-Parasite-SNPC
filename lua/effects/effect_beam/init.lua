
local mat = Material('particle/bendibeam')

function EFFECT:Init( effectdata )
	self.start = effectdata:GetStart()
	self.posend = effectdata:GetOrigin()
	self:SetPos( self.start )
end 

function EFFECT:Think()
end


function EFFECT:Render()
	render.SetMaterial( mat )
	render.DrawBeam(self.start, self.posend, 2, 0, 1, Color(255, 0, 0, 255))
end
