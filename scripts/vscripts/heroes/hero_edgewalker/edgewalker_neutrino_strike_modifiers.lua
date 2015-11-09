----------------------------------------------------------------------------------------------------------
--[[	modifier_neutrino_strike_charges (HIDDEN) 														]]
----------------------------------------------------------------------------------------------------------
if modifier_neutrino_strike_charges == nil then modifier_neutrino_strike_charges = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges:IsHidden() return true end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges:DestroyOnExpire() return false end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_EVENT_ON_HERO_KILLED } end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges:OnCreated()
	if IsServer() then
		local nBaseCharges = self:GetAbility():GetSpecialValueFor("base_charges")
		local fChargeThink = self:GetAbility():GetLevelSpecialValueFor("charges_think_interval", self:GetAbility():GetLevel()-1)
		self:SetStackCount(nBaseCharges)
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_neutrino_strike_charges_counter", { duration = fChargeThink })
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges:OnAbilityFullyCast( params )
	if IsServer() then
		if params.unit == self:GetParent() and params.ability == self:GetAbility() then
			if self:GetStackCount() > 0 then
				self:DecrementStackCount()
				if self:GetStackCount() < 1 then
					local fChargeThink = self:GetAbility():GetLevelSpecialValueFor("charges_think_interval", self:GetAbility():GetLevel()-1)
					self:GetAbility():StartCooldown(fChargeThink)
				end
			end
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges:OnHeroKilled( params )
	if IsServer() then
		if (params.target:GetOrigin() - self:GetParent():GetOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("hero_kill_search_area") then
			local nHeroKillCharges = self:GetAbility():GetLevelSpecialValueFor("charges_gained_per_hero_kill", self:GetAbility():GetLevel()-1)
			self:SetStackCount(self:GetStackCount() + nHeroKillCharges)
		end
	end
end

----------------------------------------------------------------------------------------------------------
--[[	modifier_neutrino_strike_charges_counter (PROXY)												]]
----------------------------------------------------------------------------------------------------------
if modifier_neutrino_strike_charges_counter == nil then modifier_neutrino_strike_charges_counter = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_counter:OnCreated()
	if IsServer() then
		local hNeutrinoChargesModifier = self:GetParent():FindModifierByName("modifier_neutrino_strike_charges")		
		self:SetStackCount(hNeutrinoChargesModifier:GetStackCount())
		self:StartIntervalThink(1/30)
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_counter:OnIntervalThink()
	if IsServer() then
		local hNeutrinoChargesModifier = self:GetParent():FindModifierByName("modifier_neutrino_strike_charges")		
		self:SetStackCount(hNeutrinoChargesModifier:GetStackCount())
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_charges_counter:OnDestroy()
	if IsServer() then
		local hNeutrinoChargesModifier = self:GetParent():FindModifierByName("modifier_neutrino_strike_charges")		
		hNeutrinoChargesModifier:IncrementStackCount()

		local fChargesThink = self:GetAbility():GetLevelSpecialValueFor("charges_think_interval", self:GetAbility():GetLevel()-1)
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_neutrino_strike_charges_counter", { duration = fChargesThink })
	end
end

----------------------------------------------------------------------------------------------------------
--[[	modifier_neutrino_strike_amplify_target															]]	
----------------------------------------------------------------------------------------------------------
if modifier_neutrino_strike_amplify_target == nil then modifier_neutrino_strike_amplify_target = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:OnCreated( kv )
	if IsServer() then
		local fBaseAmplify = self:GetAbility():GetSpecialValueFor("base_magic_amp")
		self:SetStackCount(fBaseAmplify)

		-- placeholder particle
		local vParticleOrigin = self:GetParent():GetOrigin()
		vParticleOrigin.z = 100
		self.nFX = ParticleManager:CreateParticle("particles/heroes/hero_edgewalker/neutrino_strike_amplift_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nFX, 1, vParticleOrigin)
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:OnRefresh(kv)
	if IsServer() then
		local fStackingAmplify = self:GetAbility():GetSpecialValueFor("stacking_magic_amp")
		local fMaxStack = self:GetAbility():GetSpecialValueFor("max_magic_amp")
		self:SetStackCount(self:GetStackCount() + fStackingAmplify)
		if self:GetStackCount() > fMaxStack then
			self:SetStackCount(fMaxStack)
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:GetEffectName() return "particles/heroes/hero_edgewalker/neutrino_strike_amplift_overhead.vpcf" end 
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:DeclareFunctions() return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE } end  
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:CheckState() return { [MODIFIER_STATE_PASSIVES_DISABLED] = true } end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:GetModifierMagicalResistanceBonus() return -self:GetStackCount() end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() and params.damage_type == DAMAGE_TYPE_MAGICAL then
			local fDispersionDuration = self:GetAbility():GetSpecialValueFor("dispersion_duration")
			local fMaxRadius = self:GetAbility():GetSpecialValueFor("dispersion_radius")
			local fExtraDamage = params.damage * (self:GetStackCount()/100)
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_neutrino_strike_magic_damage_dispersion", { damage = fExtraDamage, duration = fDispersionDuration, radius = fMaxRadius })
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_amplify_target:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nFX, false)
		ParticleManager:ReleaseParticleIndex(self.nFX)
	end
end

----------------------------------------------------------------------------------------------------------
--[[	modifier_neutrino_strike_magic_damage_dispersion												]]	
----------------------------------------------------------------------------------------------------------
if modifier_neutrino_strike_magic_damage_dispersion == nil then modifier_neutrino_strike_magic_damage_dispersion = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_magic_damage_dispersion:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_magic_damage_dispersion:OnCreated(kv)
	if IsServer() then
		local fDispersionDuration = kv.duration
		local fMaxRadius = kv.radius
		self.fDisperseDamage = kv.damage
		self.fDisperseRate = fMaxRadius/(fDispersionDuration*30)
		self.fIncrementingRadius = 0
		self.tAOETargetsHit = { self:GetParent() }
		self:SetDuration(fDispersionDuration,true)
		self:StartIntervalThink(1/30)
	end	
end
----------------------------------------------------------------------------------------------------------
function modifier_neutrino_strike_magic_damage_dispersion:OnIntervalThink()
	if IsServer() then
		local hParent = self:GetParent()
		
		DebugDrawCircle(hParent:GetOrigin(), Vector(255,0,0), 1, self.fIncrementingRadius, false, 1/30)

		local tDispersionTargets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hParent:GetOrigin(), nil, self.fIncrementingRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 2, false)
		if #tDispersionTargets > 1 then
			for i=1, #tDispersionTargets do
				if not table.contains_element(self.tAOETargetsHit, tDispersionTargets[i]) then
					ApplyDamage({
						victim = tDispersionTargets[i],
						attacker = self:GetCaster(),
						damage_type = DAMAGE_TYPE_PURE,
						damage = self.fDisperseDamage,
						ability = self:GetAbility()
					})
				end
			end
		end
		self.fIncrementingRadius = self.fIncrementingRadius + self.fDisperseRate
	end
end
----------------------------------------------------------------------------------------------------------
--[[	utility																							]]	
----------------------------------------------------------------------------------------------------------
function table.contains_element(table, element)
	for _, value in pairs(table) do
    	if value == element then
      		return true
    	end
 	end
  	return false
end