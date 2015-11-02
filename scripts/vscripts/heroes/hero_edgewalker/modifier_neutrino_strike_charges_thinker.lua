--[[
	TODO: 
	1. Polish StartInterval/SetDuration to update on ability upgrade
	2. Particles
]]

if modifier_neutrino_strike_charges_thinker == nil then modifier_neutrino_strike_charges_thinker = class({}) end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:IsHidden() return false end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:DestroyOnExpire()	return false end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:OnCreated(kv)
	if IsServer() then
		local hAbility = self:GetAbility()
		local fBaseCharges = hAbility:GetSpecialValueFor("base_charges")
		self.fIntervalThink = hAbility:GetLevelSpecialValueFor("charges_think_interval", hAbility:GetLevel() - 1)
		-- set base stack
		self:SetStackCount(fBaseCharges)
		self:SetDuration(self.fIntervalThink, true)
		self:StartIntervalThink(self.fIntervalThink)
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:OnIntervalThink()
	if IsServer() then	
		local hAbility = self:GetAbility()
		local fIntervalThink = hAbility:GetLevelSpecialValueFor("charges_think_interval", hAbility:GetLevel() - 1)
	
		-- increment on interval think
		self:IncrementStackCount() --test
		if fIntervalThink ~= self.fIntervalThink then
			self.fIntervalThink = fIntervalThink
		end
		self:SetDuration(self.fIntervalThink, true)
		self:StartIntervalThink(self.fIntervalThink)
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:OnRefresh(kv)
	if IsServer() then
		local hAbility = self:GetAbility()
		local fIntervalThink = hAbility:GetLevelSpecialValueFor("charges_think_interval", hAbility:GetLevel() - 1)
		if fIntervalThink ~= self.fIntervalThink then
			self.fIntervalThink = fIntervalThink
		end
		self:SetDuration(self.fIntervalThink, true)
		self:StartIntervalThink(self.fIntervalThink)
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:DeclareFunctions()
	return { MODIFIER_EVENT_ON_HERO_KILLED, MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:OnHeroKilled(params)
	if IsServer() then
		local hAbility = self:GetAbility()
		local fDist =hAbility:GetSpecialValueFor("onherokill_dist")
		if (params.target:GetOrigin() - self:GetParent():GetOrigin()):Length2D() < fDist then
			local nIncrementCharges = hAbility:GetLevelSpecialValueFor("charges_gained_per_hero_kill", hAbility:GetLevel() - 1)
			for i=1, nIncrementCharges do
				self:IncrementStackCount()
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_thinker:OnAbilityExecuted(params)		
	if IsServer() then
		local hAbility = self:GetAbility()
		if params.unit == self:GetParent() and params.ability == hAbility then
			local nStackCount = self:GetStackCount()
			if nStackCount > 0 then
				self:DecrementStackCount()
				if self:GetStackCount() < 1 then
					local fRemTime = self:GetRemainingTime()
					hAbility:StartCooldown(fRemTime)
				end		
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------