----------------------------------------------------------------------------------------------------------
--[[	modifier_reality_shift_spawn_ward		 														]]
----------------------------------------------------------------------------------------------------------
if modifier_reality_shift_spawn_ward == nil then modifier_reality_shift_spawn_ward = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_spawn_ward:OnCreated(kv)
	if IsServer() then
		local hCaster = self:GetAbility():GetCaster()
		local vLocation = kv.location or self:GetAbility():GetCursorPosition() or self:GetParent():GetOrigin() or self:GetCaster():GetOrigin()
		self.hWard = CreateUnitByName("npc_reality_shift_ward", vLocation, false, nil, hCaster, hCaster:GetTeamNumber())
		self.hWard:SetControllableByPlayer(hCaster:GetPlayerID(), false)
		self.hWard:AddNewModifier(hCaster, self:GetAbility(), "modifier_reality_shift_ward_aura", { duration = self:GetDuration() })

		if hCaster:HasModifier("modifier_item_ultimate_scepter") then
			self.hWard:AddNewModifier(hCaster, self:GetAbility(), "modifier_cascade_event_portal", { duration = self:GetDuration() })
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_spawn_ward:OnDestroy()
	if IsServer() then
		self.hWard:ForceKill(false)
	end
end

----------------------------------------------------------------------------------------------------------
--[[	modifier_reality_shift_aura		 																]]
----------------------------------------------------------------------------------------------------------
if modifier_reality_shift_ward_aura == nil then modifier_reality_shift_ward_aura = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:IsAura() return true end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:GetModifierAura()	return "modifier_reality_shift_ward_effect" end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_range") end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:CheckState() return { [MODIFIER_STATE_MAGIC_IMMUNE] = true } end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:GetAuraEntityReject( hEntity )
	if IsServer() then	
		if hEntity == self:GetParent() then	return true	end
	end
	return false
end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_aura:OnDeath( params )
	if IsServer() then
		local hParent, hCaster = self:GetParent(), self:GetCaster()
		local fRadius = self:GetAbility():GetSpecialValueFor("aura_range")
		local vParticleOrigin = GetGroundPosition(hParent:GetOrigin(), hParent)

		local nIndex = ParticleManager:CreateParticle("particles/items_fx/ethereal_blade_explosion.vpcf", PATTACH_ABSORIGIN, hParent)
		ParticleManager:SetParticleControl(nIndex, 1, vParticleOrigin)

		local units = FindUnitsInRadius(hCaster:GetTeamNumber(), hParent:GetOrigin(), nil, fRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		if #units > 0 then
			for i=1, #units do	
				ApplyDamage({
				victim = units[i],
				attacker = hCaster,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage = self:GetAbility():GetLevelSpecialValueFor("explosion_damage", self:GetAbility():GetLevel() -1 ),
				ability = self:GetAbility()
				})
				local fRootDuration = self:GetAbility():GetSpecialValueFor("root_duration")
				-- modifier_reality_shift_root
				units[i]:AddNewModifier(hCaster, self:GetAbility(), "modifier_rooted", { duration = fRootDuration })
			end	
		end
		hParent:ForceKill(false)
	end
	return 0
end

----------------------------------------------------------------------------------------------------------
--[[	modifier_reality_shift_root		 																]]
----------------------------------------------------------------------------------------------------------
if modifier_reality_shift_root == nil then modifier_reality_shift_root = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_root:GetEffectName() return "particles/units/heroes/hero_bane/bane_fiends_grip.vpcf" end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_root:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_root:GetStatusEffectName() return "particles/status_fx/status_effect_fiendsgrip.vpcf" end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_root:CheckState() return { [MODIFIER_STATE_ROOTED] = true } end

----------------------------------------------------------------------------------------------------------
--[[	modifier_reality_shift_ward_effect		 														]]
----------------------------------------------------------------------------------------------------------
if modifier_reality_shift_ward_effect == nil then modifier_reality_shift_ward_effect = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_effect:OnCreated(kv)
	if IsServer() then
		self:SetDuration(self:GetAbility():GetSpecialValueFor("stickiness"), true)
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_effect:IsHidden() return false end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_effect:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_effect:GetModifierMagicalResistanceBonus(params)
	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			return self:GetAbility():GetLevelSpecialValueFor("parent_buff_value", self:GetAbility():GetLevel()-1)
		elseif self:GetParent():GetUnitName() == "npc_reality_shift_ward" then
			return 
		else
			return -self:GetAbility():GetSpecialValueFor("debuff_value")
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_effect:GetModifierMoveSpeedBonus_Percentage(params)
	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			return self:GetAbility():GetLevelSpecialValueFor("parent_buff_value", self:GetAbility():GetLevel()-1)
		elseif self:GetParent():GetUnitName() == "npc_reality_shift_ward" then
			return 
		else
			return -self:GetAbility():GetSpecialValueFor("debuff_value")
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_effect:GetStatusEffectName()
	if IsServer() then
		if not self:GetParent():GetUnitName() == "npc_reality_shift_ward" or self:GetParent() ~= self:GetCaster() then
			return "particles/items_fx/ghost.vpcf"
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_reality_shift_ward_effect:CheckState()
	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
		end
		return {[MODIFIER_STATE_DISARMED] = true}
	end
end

----------------------------------------------------------------------------------------------------------
--[[	modifier_reality_shift_charges		 															]]
----------------------------------------------------------------------------------------------------------
if modifier_reality_shift_charges == nil then modifier_reality_shift_charges = class({}) end
-------------------------------------------------------------------------------------------------------------------
function modifier_reality_shift_charges:DestroyOnExpire() return false end
-------------------------------------------------------------------------------------------------------------------
function modifier_reality_shift_charges:OnCreated(kv)
	if IsServer() then
		if self:GetAbility():IsCooldownReady() then
			self:SetStackCount(2)
		else
			self:SetStackCount(1)
			local fDur = self:GetAbility():GetLevelSpecialValueFor("charge_cooldown", self:GetAbility():GetLevel()-1)
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_reality_shift_charges_counter", { duration = fDur })
		end
		self:GetAbility():EndCooldown()
	end
end
-------------------------------------------------------------------------------------------------------------------
function modifier_reality_shift_charges:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end
-------------------------------------------------------------------------------------------------------------------
function modifier_reality_shift_charges:OnAbilityExecuted(params)		
	if IsServer() then
		local hAbility = self:GetAbility()
		if params.unit == self:GetParent() and params.ability == hAbility then
			local nStackCount = self:GetStackCount()
			if nStackCount > 0 then
				self:DecrementStackCount()
				if self:GetStackCount() < 1 then
					local cd = hAbility:GetLevelSpecialValueFor("charge_cooldown", hAbility:GetLevel()-1)
					hAbility:StartCooldown(self:GetRemainingTime())
				else
					hAbility:EndCooldown()
				end	
				if self:GetStackCount() < 2 then
					local fDur = self:GetAbility():GetLevelSpecialValueFor("charge_cooldown", self:GetAbility():GetLevel()-1)
					self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_reality_shift_charges_counter", { duration = fDur })
				end
			end
		end
	end
end


----------------------------------------------------------------------------------------------------------
--[[	modifier_reality_shift_charges_counter (PROXY) 													]]
----------------------------------------------------------------------------------------------------------
if modifier_reality_shift_charges_counter == nil then modifier_reality_shift_charges_counter = class({}) end
-------------------------------------------------------------------------------------------------------------------
function modifier_reality_shift_charges_counter:OnDestroy()
	if IsServer() then
		local hChargesTooltip = self:GetCaster():FindModifierByName("modifier_reality_shift_charges")
		if hChargesTooltip:GetStackCount() < 2 then
			hChargesTooltip:IncrementStackCount()
			if hChargesTooltip:GetStackCount() < 2 then
				local fDur = self:GetAbility():GetLevelSpecialValueFor("charge_cooldown", self:GetAbility():GetLevel()-1)
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_reality_shift_charges_counter", { duration = fDur })
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------