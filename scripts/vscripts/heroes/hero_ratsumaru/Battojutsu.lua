function battojutsu_learn (keys)
	caster = keys.caster
	local ability = keys.ability
	local battojutsu_e = keys.ability:GetLevel()
	local w_level =	keys.caster:FindAbilityByName("W")
	local r_level =	keys.caster:FindAbilityByName("R")
	if w_level ~= nil and w_level:GetLevel() ~= battojutsu_e then
		w_level:SetLevel(battojutsu_e)
		r_level:SetLevel(battojutsu_e)
	end
end








function RR (keys)
	caster = keys.caster
	local ability = keys.ability
	target = keys.target
	local e = keys.caster:FindAbilityByName("Battojutsu(e)")
	local w = keys.caster:FindAbilityByName("W")
	local r = keys.caster:FindAbilityByName("R")
	dummyModifierName = "modifier_Battojutsu_dummy_datadriven"
	dummy = CreateUnitByName( caster:GetName(), caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
	caster:PerformAttack(target, true, true, true, false)
	
	if w:IsCooldownReady() and e:IsCooldownReady() then	 		
		cast_1 = 3
	elseif w:IsCooldownReady() or e:IsCooldownReady() then
		cast_2 = 3
 	else
	 	cast_3 = 3
	 	if cast_1 == 1 and cast_2 == 2 and cast_3 == 3 then
			print("Rairyusen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_rairyusen", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 1 and cast_2 == 3 and cast_3 == 2 then
			print("Ryumeisen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_ryumeisen", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 2 and cast_2 == 1 and cast_3 == 3 then
			print("Amakakeru")
			caster:PerformAttack(target, true, true, true, false)
			if target:GetHealthPercent() < 7.5 then
				local damage_table = {}

				damage_table.attacker = caster
				damage_table.damage_type = e:GetAbilityDamageType()
				damage_table.victim = target
				damage_table.damage = 50000

				ApplyDamage(damage_table)
			end
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end

		elseif cast_1 == 2 and cast_2 == 3 and cast_3 == 1 then
			print("Ryukansen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_maim", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 3 and cast_2 == 2 and cast_3 == 1 then
			print("Kairyusen")
				caster:PerformAttack(target, true, true, true, false)
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 3 and cast_2 == 1 and cast_3 == 2 then
			print("Hiryusen")
			caster:PerformAttack(target, true, true, true, false)
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		end
		
	end
	
end	 		

function EE (keys)
	caster = keys.caster
	local ability = keys.ability
	target = keys.target
	local e = keys.caster:FindAbilityByName("Battojutsu(e)")
	local w = keys.caster:FindAbilityByName("W")
	local r = keys.caster:FindAbilityByName("R")
		FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
		caster:PerformAttack(target, true, true, true, false)
	if w:IsCooldownReady() and r:IsCooldownReady() then	 		
		cast_1 = 1
	elseif w:IsCooldownReady() or r:IsCooldownReady() then
		cast_2 = 1
 	else
	 	cast_3 = 1
	 	if cast_1 == 1 and cast_2 == 2 and cast_3 == 3 then
			print("Rairyusen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_rairyusen", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 1 and cast_2 == 3 and cast_3 == 2 then
			print("Ryumeisen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_ryumeisen", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 2 and cast_2 == 1 and cast_3 == 3 then
			print("Amakakeru")
			caster:PerformAttack(target, true, true, true, false)
			if target:GetHealthPercent() < 7.5 then
				local damage_table = {}

				damage_table.attacker = caster
				damage_table.damage_type = e:GetAbilityDamageType()
				damage_table.victim = target
				damage_table.damage = 50000

				ApplyDamage(damage_table)
			end
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 2 and cast_2 == 3 and cast_3 == 1 then
			print("Ryukansen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_maim", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 3 and cast_2 == 2 and cast_3 == 1 then
			print("Kairyusen")
				caster:PerformAttack(target, true, true, true, false)
				if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 3 and cast_2 == 1 and cast_3 == 2 then
			print("Hiryusen")
			caster:PerformAttack(target, true, true, true, false)
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		end
		
	end

end


function WW (keys)
	 caster = keys.caster
	local ability = keys.ability
	target = keys.target
	local e = keys.caster:FindAbilityByName("Battojutsu(e)")
	local w = keys.caster:FindAbilityByName("W")
	local r = keys.caster:FindAbilityByName("R")
		FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )
	 	caster:PerformAttack(target, true, true, true, false)
	if e:IsCooldownReady() and r:IsCooldownReady() then	 		
		cast_1 = 2

	elseif e:IsCooldownReady() or r:IsCooldownReady() then
		cast_2 = 2
 	else
	 	cast_3 = 2
	 	if cast_1 == 1 and cast_2 == 2 and cast_3 == 3 then
			print("Rairyusen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_rairyusen", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 1 and cast_2 == 3 and cast_3 == 2 then
			print("Ryumeisen")
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_ryumeisen", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 2 and cast_2 == 1 and cast_3 == 3 then
			print("Amakakeru")
			caster:PerformAttack(target, true, true, true, false)
			if target:GetHealthPercent() < 7.5 then
				local damage_table = {}

				damage_table.attacker = caster
				damage_table.damage_type = e:GetAbilityDamageType()
				damage_table.victim = target
				damage_table.damage = 50000

				ApplyDamage(damage_table)
			end
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 2 and cast_2 == 3 and cast_3 == 1 then
			print("Ryukansen")
		
			keys.ability:ApplyDataDrivenModifier(caster, caster, "Battojutsu_aoe_dummy_maim", {})
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 3 and cast_2 == 2 and cast_3 == 1 then
			print("Kairyusen")
				caster:PerformAttack(target, true, true, true, false)
				if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		elseif cast_1 == 3 and cast_2 == 1 and cast_3 == 2 then
			print("Hiryusen")
			caster:PerformAttack(target, true, true, true, false)
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
			if dummy:IsNull() then
			else
				dummy:RemoveSelf()
			end
		end
		
	end

end



function AoE_Damage(event)
	local caster = event.caster
	local target = event.target
	local atkDamage = caster:GetAttackDamage()
	local e = event.ability
	local damage_table = {}

		damage_table.attacker = caster
		damage_table.damage_type = e:GetAbilityDamageType()
		damage_table.victim = target
		damage_table.damage = atkDamage

		ApplyDamage(damage_table)
end



function cooldowns(keys)
	 caster = keys.caster
	 ability = keys.ability

	local e = keys.caster:FindAbilityByName("Battojutsu(e)")
	local w = keys.caster:FindAbilityByName("W")
	local r = keys.caster:FindAbilityByName("R")
	local cooldown = e:GetLevelSpecialValueFor( "CD", ( e:GetLevel() - 1 ) )
	if ability == e then
		if cast_1 == 3 and cast_2 == 2 and cast_3 == nil then
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
		--elseif cast_1 = 3 and cast_2 = 1 and cast_3 = nil then
		elseif cast_1 == 3 and cast_2 == nil and cast_3 == nil then
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
		end
	end
	if dummy:IsNull() then
	else
		dummy:RemoveSelf()
	end
	e:StartCooldown(cooldown)
	r:StartCooldown(cooldown)
	w:StartCooldown(cooldown)
	caster:RemoveModifierByName("PauseAttacking")


end