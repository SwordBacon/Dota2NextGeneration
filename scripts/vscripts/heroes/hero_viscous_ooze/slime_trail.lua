function SlimeTrailInitializeCaster( keys )
	local caster = keys.caster
	local ability = keys.ability
	
	local vision_aoe = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	
	caster.slime_puddle = caster:GetAbsOrigin()
	
	ability:CreateVisibilityNode(caster.slime_puddle, vision_aoe, duration)
	
end

function SlimeTrailDistanceCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage_percent = keys.damage
	
	local caster_location = caster:GetAbsOrigin()
	local thinker_location = caster.slime_puddle

	local distance = (caster_location - thinker_location):Length2D()
	local slime_distance = ability:GetLevelSpecialValueFor("slime_distance", (ability:GetLevel() - 1))
	
	if distance >= slime_distance then
		caster:RemoveModifierByName("modifier_slime_puddle_creator")
		local damage_table = {}

		damage_table.attacker = caster
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.ability = ability
		damage_table.victim = caster

		damage_table.damage = caster:GetBaseMaxHealth() * damage_percent / 100

	ApplyDamage(damage_table)
	end
end

function SlimeTrailDisablePhase( keys )
	local caster = keys.caster
	local ability = keys.ability
	
	local attacker = keys.attacker
	local damage = keys.damage
	
	if attacker:IsHero() and attacker:GetPlayerOwner() ~= caster:GetPlayerOwner() then
		caster:RemoveModifierByName("modifier_slime_puddle_phased")
		caster:RemoveModifierByName("modifier_slime_puddle_phase_timer")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_slime_puddle_phase_timer", {})
	end
end
