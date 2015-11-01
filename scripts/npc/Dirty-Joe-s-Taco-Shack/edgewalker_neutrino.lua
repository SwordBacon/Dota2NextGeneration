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
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------

if modifier_neutrino_strike_target_debuff == nil then modifier_neutrino_strike_target_debuff = class({}) end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_target_debuff:OnCreated(kv)
	if IsServer() then
		self.fBaseMagicAmp = self:GetAbility():GetLevelSpecialValueFor("base_magic_amp", self:GetAbility():GetLevel()-1)
		self.fStackingMagicAmp = self:GetAbility():GetLevelSpecialValueFor("stacking_magic_amp", self:GetAbility():GetLevel()-1)
		self.fMaxMagicAmp = self:GetAbility():GetSpecialValueFor("max_magic_amp")
		local nStacks = self.fBaseMagicAmp
		self:SetStackCount(nStacks)
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_target_debuff:OnRefresh(kv)
	if IsServer() then
		self.fBaseMagicAmp = self:GetAbility():GetLevelSpecialValueFor("base_magic_amp", self:GetAbility():GetLevel()-1)
		self.fStackingMagicAmp = self:GetAbility():GetLevelSpecialValueFor("stacking_magic_amp", self:GetAbility():GetLevel()-1)
		self.fMaxMagicAmp = self:GetAbility():GetSpecialValueFor("max_magic_amp")
		local nStacks = self:GetStackCount() or self.base_magic_amp
		nStacks = nStacks + self.fStackingMagicAmp
		if nStacks > self.fMaxMagicAmp then
			nStacks = self.fMaxMagicAmp
		end
		self:SetStackCount(nStacks)
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_target_debuff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_target_debuff:CheckState() 
	if IsServer() then 
		return {[MODIFIER_STATE_PASSIVES_DISABLED] = true} 
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_target_debuff:OnTakeDamage(params)
	if IsServer() then
		-- PrintTable(params)
		-- amplify damage
		if params.unit == self:GetParent() and params.damage_type == DAMAGE_TYPE_MAGICAL then
			local fAmplifyMagicDmgRate = self:GetStackCount()/100
			local tDmgTable = {
				victim = params.unit,
				attacker = params.attacker,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage = params.original_damage * fAmplifyMagicDmgRate
			}
			ApplyDamage(tDmgTable)
			local hCaster = self:GetAbility():GetCaster()
			params.unit:AddNewModifier(hCaster, self:GetAbility(), "modifier_neutrino_strike_aoe_damage", {duration = 1.25, dmg = tDmgTable.damage})
		end
	end
end
