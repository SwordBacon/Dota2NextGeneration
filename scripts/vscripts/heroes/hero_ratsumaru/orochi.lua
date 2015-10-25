
function orochi_start_charge( keys )



	if keys.ability:GetLevel() ~= 1 then return end

	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_orochi_stacks"
	local maximum_charges = ability:GetLevelSpecialValueFor( "orochi_max_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "orochi_replenish_time", ( ability:GetLevel() - 1 ) )

	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.orochi_charges = maximum_charges
	caster.start_charge = false
	caster.orochi_cooldown = ability:GetLevelSpecialValueFor( "cooldown_timer", (ability:GetLevel() - 1 ) )
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, maximum_charges )
	

	Timers:CreateTimer(function()
		
			if caster.start_charge and caster.orochi_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.orochi_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= 6 then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_charge = false
				end
				if caster:HasModifier("modifier_orochi_bloodlust") then
				else
					caster:SetModifierStackCount( modifierName, caster, next_charge )
				end
				-- Update stack
				caster.orochi_charges = next_charge
			end
			
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.orochi_charges ~= maximum_charges then
				Timers:CreateTimer(charge_replenish_time, function()
					if GameRules:GetGameTime() >= caster.last_attack + charge_replenish_time then
						caster.start_charge = true
					end

				end)
			return charge_replenish_time
			else
				return 0.5
				
			end
				
	end)
end
function orochi_On_Atk( keys )
	local modifierName = "modifier_orochi_stacks"
	local AttackDamage = keys.DamageDealt
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local next_charge = caster.orochi_charges
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "orochi_replenish_time", ( ability:GetLevel() - 1 ) )
		  int_multiplier = ability:GetLevelSpecialValueFor( "int_multiplier_tooltip", ( ability:GetLevel() - 1 ) )
	 	  int_caster = caster:GetIntellect()
	caster.last_attack = GameRules:GetGameTime()
	
	if 	caster.orochi_charges == 6 then
		
		local damage_table = {}

			damage_table.attacker = caster
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType()
			damage_table.victim = target

			damage_table.damage = int_caster * int_multiplier * caster.orochi_charges * 0.25
			ApplyDamage(damage_table)
			caster.orochi_charges = caster.orochi_charges - 1
			caster:SetModifierStackCount( modifierName, caster, caster.orochi_charges )
	elseif caster.orochi_charges == 5 then
		
		local damage_table = {}

			
			damage_table.attacker = caster
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType()
			damage_table.victim = target

			damage_table.damage = int_caster * int_multiplier * caster.orochi_charges * 0.25
			ApplyDamage(damage_table)
			caster.orochi_charges = caster.orochi_charges - 1
			caster:SetModifierStackCount( modifierName, caster, caster.orochi_charges )
	elseif caster.orochi_charges == 4 then
		
		local damage_table = {}

			
			damage_table.attacker = caster
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType()
			damage_table.victim = target

			damage_table.damage = int_caster * int_multiplier * caster.orochi_charges * 0.25
			ApplyDamage(damage_table)
			caster.orochi_charges = caster.orochi_charges - 1
			caster:SetModifierStackCount( modifierName, caster, caster.orochi_charges )
	elseif caster.orochi_charges == 3 then
		
		local damage_table = {}

			
			damage_table.attacker = caster
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType()
			damage_table.victim = target

			damage_table.damage = int_caster * int_multiplier * caster.orochi_charges * 0.25
			ApplyDamage(damage_table)
			caster.orochi_charges = caster.orochi_charges - 1
			caster:SetModifierStackCount( modifierName, caster, caster.orochi_charges )
	elseif caster.orochi_charges == 2 then
		
		local damage_table = {}
			
			damage_table.attacker = caster
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType()
			damage_table.victim = target

			damage_table.damage = int_caster * int_multiplier * caster.orochi_charges * 0.25
			ApplyDamage(damage_table)
			caster.orochi_charges = caster.orochi_charges - 1
			caster:SetModifierStackCount( modifierName, caster, caster.orochi_charges )
	elseif caster.orochi_charges == 1 then
		
		local damage_table = {}

			damage_table.attacker = caster
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType()
			damage_table.victim = target

			damage_table.damage = int_caster * int_multiplier * caster.orochi_charges * 0.25
			ApplyDamage(damage_table)
			caster.orochi_charges = caster.orochi_charges - 1
			caster:SetModifierStackCount( modifierName, caster, caster.orochi_charges )
			if ability:IsCooldownReady() then
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_orochi_bloodlust", {})
				ability:StartCooldown(caster.orochi_cooldown)
			end
	end
end


