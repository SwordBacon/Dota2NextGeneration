function KillCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetAbilityDamage()
	local threshold = ability:GetLevelSpecialValueFor("kill_threshold", ability:GetLevel() - 1)

	local DamageTable = {
	victim = target,
	attacker = caster,
	ability = ability,
	damage = damage,
	damage_type = DAMAGE_TYPE_PURE
	}
	
	ApplyDamage(DamageTable)
	
	if target:GetHealthPercent() < threshold then
		target:Kill(ability, caster)
	end
end
