-- Rip and Tear functions are here because I need to pass the damage value over from Unholy Ecstasy.
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
	print(target)
	target:SetHealth(target:GetHealth() + (damageTaken*damagereduction ))

	local damagecap= ability:GetLevelSpecialValueFor("damage_cap", ability:GetLevel() - 1 )
	damagedone = DamageCollection * bonusdamage * 0.01
	if damagedone > damagecap then
		damagedone = damagecap
	end
end

function BonusDamage (keys)
	local target = keys.attacker
	local unit = keys.caster
	local ability = keys.ability
	local bonusdamage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1 )

	print(target)

	local damage_table = {}
	damage_table.ability = ability
	damage_table.victim = target
	damage_table.attacker = unit
	damage_table.damage = damagedone
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	
	ApplyDamage(damage_table)
	unit:RemoveModifierByName("Unholy_Ecstasy_Bonus_Damage")
end

function FirstStrike(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local int_caster = caster:GetIntellect()
	local int_multiplier = ability:GetLevelSpecialValueFor( "int_multiplier_tooltip", ( ability:GetLevel() - 1 ) )
	local ini_damage = ability:GetLevelSpecialValueFor("ini_damage", ability:GetLevel() -1 )
	local heal = ability:GetLevelSpecialValueFor("damage_healed", ability:GetLevel() -1 )
	if damagedone == nil then
		damagedone = 0
	end

	
	if caster:HasModifier("Unholy_Ecstasy_Bonus_Damage") then
		local damage_table = {}
		damage_table.ability = ability
		damage_table.victim = target
		damage_table.attacker = caster 
		damage_table.damage =((int_caster * int_multiplier)+ ini_damage) + damagedone
		damage_table.damage_type = ability:GetAbilityDamageType()
		ApplyDamage(damage_table)
	else
		local damage_table = {}
		damage_table.ability = ability
		damage_table.victim = target
		damage_table.attacker = caster
		damage_table.damage =((int_caster * int_multiplier)+ ini_damage)
		damage_table.damage_type = ability:GetAbilityDamageType()
		ApplyDamage(damage_table)
	end

	
	if caster:HasModifier("Unholy_Ecstasy_Bonus_Damage") then
		caster:SetHealth( caster:GetHealth() + ((int_caster * int_multiplier)+ ini_damage + damagedone) * heal * 0.01 )
		caster:RemoveModifierByName("Unholy_Ecstasy_Bonus_Damage")
	else
		caster:SetHealth( caster:GetHealth() + ((int_caster * int_multiplier)+ ini_damage ) * heal * 0.01 )
	end
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
		local damage_table = {}
		damage_table.ability = ability
		damage_table.victim = target
		damage_table.attacker = caster
		damage_table.damage = ((int_caster 	* int_multiplier)+ ini_damage)
		damage_table.damage_type = ability:GetAbilityDamageType()
	
		ApplyDamage(damage_table)

		caster:SetHealth( caster:GetHealth() + ((int_caster * int_multiplier)+ ini_damage) * heal * 0.01 )
	end
end	
