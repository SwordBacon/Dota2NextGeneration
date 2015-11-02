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
		-- amplify damage
		if params.unit == self:GetParent() and params.damage_type == DAMAGE_TYPE_MAGICAL then
			local fAmplifyMagicDmgRate = self:GetStackCount() / 100
			ApplyDamage({
				victim = params.unit,
				attacker = params.attacker,
				damage_type = DAMAGE_TYPE_PURE,
				damage = fAmplifyMagicDmgRate * params.damage
			})			
			local hCaster = self:GetAbility():GetCaster()
			params.unit:AddNewModifier(hCaster, self:GetAbility(), "modifier_neutrino_strike_aoe_damage", {})
		end
	end
end