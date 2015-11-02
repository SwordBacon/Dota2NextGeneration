if modifier_neutrino_strike_aoe_damage == nil then modifier_neutrino_strike_aoe_damage = class({}) end

function modifier_neutrino_strike_aoe_damage:GetAttributes() 
	if IsServer() then 
		return MODIFIER_ATTRIBUTE_MULTIPLE 
	end
end

function modifier_neutrino_strike_aoe_damage:OnCreated(kv)
	if IsServer() then
		PrintTable(self)
		self.tAOETargetsHit = {}
		self.fAOERadius = 0
		self:SetDuration(1.25, true)	
		self:StartIntervalThink(1/30)
	end
end

function modifier_neutrino_strike_aoe_damage:OnIntervalThink()
	if IsServer() then
		
		local hCaster, hParent = self:GetAbility():GetCaster(), self:GetParent()
		self.fAOERadius = self.fAOERadius + 8.333
		-- debug
		DebugDrawCircle(hParent:GetOrigin(), Vector(0,255,0), 2, self.fAOERadius, false, 1/30)
	end
end

function table.contains_element(table, element)
	for _, value in pairs(table) do
    	if value == element then
      		return true
    	end
 	end
  	return false
end