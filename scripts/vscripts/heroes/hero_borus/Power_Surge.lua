function Power_Surge (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local slowduration = ability:GetSpecialValueFor("slow_duration")
	local positive_damage = ability:GetLevelSpecialValueFor("Positive_Damage", ability:GetLevel() - 1)
	local negative_damage = ability:GetLevelSpecialValueFor("Negative_Damage", ability:GetLevel() - 1)

	
	if  target:HasModifier("Positive_Charge_Magnetic") or target:HasModifier("Negative_Charge_Magnetic") then 
		if target:HasModifier("Positive_Charge_Magnetic") then
			local remaining_duration = target:FindModifierByName("Positive_Charge_Magnetic"):GetRemainingTime()
			ability:ApplyDataDrivenModifier(caster, target, "Super_Positive_Charge_Magnetic", {duration = remaining_duration})
			target:RemoveModifierByName("Positive_Charge_Magnetic")
			if target:GetTeamNumber() ~= caster:GetTeamNumber() then
				local damage_table = {}

				damage_table.attacker = caster
				damage_table.victim = target
				damage_table.damage_type = DAMAGE_TYPE_MAGICAL
				damage_table.ability = ability
				damage_table.damage = positive_damage


				ApplyDamage(damage_table)
			end
		elseif target:HasModifier("Negative_Charge_Magnetic") then
			local remaining_duration = target:FindModifierByName("Negative_Charge_Magnetic"):GetRemainingTime()
			ability:ApplyDataDrivenModifier(caster, target, "Super_Negative_Charge_Magnetic", {duration = remaining_duration})
			target:RemoveModifierByName("Negative_Charge_Magnetic")
			if target:GetTeamNumber() ~= caster:GetTeamNumber() then
				local damage_table = {}

				damage_table.attacker = caster
				damage_table.victim = target
				damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
				damage_table.ability = ability
				damage_table.damage = negative_damage


				ApplyDamage(damage_table)
			end
		end
	else
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			ability:ApplyDataDrivenModifier(caster, target, "Power_Surge_Slow", {duration = slowduration})
		end
	end
end


