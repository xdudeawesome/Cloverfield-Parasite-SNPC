include('shared.lua')

language.Add("parasite_poison", "Parasite")
killicon.Add("parasite_poison","HUD/killicons/monster_parasite",Color ( 255, 80, 0, 255 ) )

function ENT:Draw()
	self.Entity:DrawModel()
end
