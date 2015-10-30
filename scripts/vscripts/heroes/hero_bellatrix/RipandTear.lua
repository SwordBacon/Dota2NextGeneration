function FirstStrike(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local int_caster = caster:GetIntellect()
	local int_multiplier = ability:GetLevelSpecialValueFor( "int_multiplier_tooltip", ( ability:GetLevel() - 1 ) )
	local ini_damage = ability:GetLevelSpecialValueFor("ini_damage", ability:GetLevel() -1 )
	local heal = ability:GetLevelSpecialValueFor("damage_healed", ability:GetLevel() -1 )


	local damage_table = {}
	damage_table.ability = ability
	damage_table.victim = target
	damage_table.attacker = caster
	damage_table.damage = ((int_caster * int_multiplier)+ ini_damage)
	damage_table.damage_type = ability:GetAbilityDamageType()
	
	ApplyDamage(damage_table)
	caster:SetHealth( caster:GetHealth() + ((int_caster * int_multiplier)+ ini_damage) * heal * 0.01 )
end

function SecondStrike(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local int_caster = caster:GetIntellect()
	local int_multiplier = ability:GetLevelSpecialValueFor("int_multiplier_tooltip", ability:GetLevel() -1 )
	local ini_damage = ability:GetLevelSpecialValueFor("ini_damage", ability:GetLevel() -1 )
	local heal = ability:GetLevelSpecialValueFor("damage_healed", ability:GetLevel() -1 )
	caster:Stop()
    if caster:IsHexed() or caster:IsStunned() or caster:IsRooted() or caster:IsOutOfGame() then
    else
    	caster:StartSwingGesture( ACT_DOTA_ATTACK)
		local damage_table = {}
		damage_table.ability = ability
		damage_table.victim = target
		damage_table.attacker = caster
		damage_table.damage = ((int_caster * int_multiplier)+ ini_damage)
		damage_table.damage_type = ability:GetAbilityDamageType()
	
		ApplyDamage(damage_table)

		caster:SetHealth( caster:GetHealth() + ((int_caster * int_multiplier)+ ini_damage) * heal * 0.01 )
	end
end