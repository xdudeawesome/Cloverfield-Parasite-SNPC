function HLR_HUDPAINT()
	if(!LocalPlayer() or !LocalPlayer():IsValid()) then
		return
	end
	
	local tr = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
	if !IsValid(tr.Entity) or !tr.Entity:GetNetworkedBool(10) or tr.Entity:GetNetworkedEntity(11) == LocalPlayer() then return end
	local scale_w = LocalPlayer():GetPanelScale()[1]
	local scale_h = LocalPlayer():GetPanelScale()[2]
	
	surface.SetDrawColor(255,255,255,255)
	local message = "Possessed by " .. tr.Entity:GetNetworkedEntity(11):GetName()
	surface.SetFont( "GModNotify" )
	
	local width = surface.GetTextSize( message )
	draw.RoundedBox( 16, ScrW() *0.5 -((35 +width) /scale_w) /2, ScrH() *0.523, (35 +width) /scale_w, 40 /scale_h, Color(73,78,73,165) )
	
	draw.SimpleText(message, "GModNotify", ScrW() *0.5, ScrH() *0.54, Color(253,231,82,255), 1, 1)
end
hook.Add("HUDPaint", "HLR_HUDPAINT", HLR_HUDPAINT)