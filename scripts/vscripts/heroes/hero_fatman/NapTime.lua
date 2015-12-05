function Bulldoze (keys)

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	local dur = ability:GetLevelSpecialValueFor("bulldoze_duration", ability:GetLevel() - 1)


	if target:HasModifier("nap_time_dummy_enemy") then
	else
		local damage_table = {}

		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
		damage_table.ability = ability
		damage_table.damage = damage

		ApplyDamage(damage_table)

		ability:ApplyDataDrivenModifier(caster, target, "Bulldozed", {duration = dur})
		ability:ApplyDataDrivenModifier(caster, target, "nap_time_dummy_enemy", {duration = 10})
	end
end



