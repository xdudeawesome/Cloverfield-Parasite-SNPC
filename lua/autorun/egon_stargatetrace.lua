AddCSLuaFile("egon_stargatetrace.lua")

if CLIENT then
	killicon.Add("egon_cannon","killicons/egon_killicon",Color(255,80,0,255))
	killicon.Add("dark_egon_cannon","killicons/egon_killicon",Color(255,80,0,255))
end

function Egon_GetTraceData(st,en,fl) -- This is the trace system that the sweps and entities use.
	local tracedata = {}
	tracedata.start = st
	tracedata.endpos = en
	tracedata.filter = fl or {}
	local tr
	if StarGate != nil then
		tr = Egon_ShieldTrace(st,en-st,(fl or {}),true)
	else
		tr = util.TraceLine(tracedata)
	end
	return tr
end

function Egon_ShieldTrace(pos, dir, filter, acur)  -- Mayor thanks to DrFattyJr for this awesome part of math.
	local tr = StarGate.Trace:New(pos,dir,filter)
	local aim = (dir-pos):GetNormal()
	tr.HitShield = false
	if ValidEntity(tr.Entity) then
		local class = tr.Entity:GetClass()
		if class == "shield" then
			if acur then
				local pos2 = tr.Entity:GetPos()
				local rad = tr.Entity:GetNWInt("size", false)
				local relpos = tr.HitPos-pos2
				local a = aim.x^2+aim.y^2+aim.z^2
				local b = 2*(relpos.x*aim.x+relpos.y*aim.y+relpos.z*aim.z)
				local c = relpos.x^2+relpos.y^2+relpos.z^2-rad^2
				local dist = (-1*b-(b^2-4*a*c)^0.5)/(2*a)
				if tostring(dist) == "-1.#IND" then
					tr = Egon_ShieldTrace(tr.HitPos,dir,(tr.Entity or {}),true)
				elseif dist < 0 then
					dist = (-1*b+(b^2-4*a*c)^0.5)/(2*a)
					tr.HitPos = tr.HitPos+aim*dist
					tr.HitNormal = (tr.HitPos-pos2):GetNormal()
					tr.HitShield = true
				else
					tr.HitPos = tr.HitPos+aim*dist
					tr.HitNormal = (tr.HitPos-pos2):GetNormal()
					tr.HitShield = true
				end
			else
				self.HitShield = true
			end
		end
	end
    return tr
end
