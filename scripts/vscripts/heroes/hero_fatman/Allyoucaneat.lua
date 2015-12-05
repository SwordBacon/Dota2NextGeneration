function heal (keys)

	local caster = keys.caster
	local ability = keys.ability
	local healvalue = ability:GetSpecialValueFor("Heal") / 100
	local interval = ability:GetSpecialValueFor("Interval")

	maxhp = caster:GetMaxHealth()
	currenthp = caster:GetHealth()
	caster:Heal((maxhp*healvalue*interval), caster)
end