function UnholyEcstasy (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit
	local damageTaken = keys.DamageTaken
	local damagereduction = (ability:GetLevelSpecialValueFor("damage_reduction", ability:GetLevel() - 1 ) /100)
	local bonusdamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1 )
	if DamageCollection == nil then
		DamageCollection = 0
	end
		  DamageCollection = DamageCollection + (damageTaken*damagereduction)
	print(DamageCollection)
	target:SetHealth(target:GetHealth() + (damageTaken*damagereduction ))
end

function BonusDamage (keys)
	local target = keys.target
	local unit = keys.caster
	local ability = keys.ability
	local bonusdamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1 )
	local damage_table = {}
	damage_table.ability = ability
	damage_table.victim = target
	damage_table.attacker = unit
	damage_table.damage = DamageCollection * bonusdamage * 0.01
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	
	ApplyDamage(damage_table)
	unit:RemoveModifierByName("Unholy_Ecstasy_Bonus_Damage")
end

