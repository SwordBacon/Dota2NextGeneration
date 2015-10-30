

function DamageInterval (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local target_max_hp = target:GetMaxHealth() /100
	local effect_damage = ability:GetLevelSpecialValueFor("PercentDamage", ability:GetLevel() - 1 )
	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = target_max_hp * effect_damage * 0.1
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS -- Doesnt trigger abilities and items that get disabled by damage

	ApplyDamage(damage_table)

end

function live_transfusion_start_charge( keys )
	-- Only start charging at level 1
	if keys.ability:GetLevel() ~= 1 then return end

	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_live_transfusion_stack_counter_datadriven"
	local maximum_charges = ability:GetLevelSpecialValueFor( "max_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.live_transfusion_charges = 1
	caster.start_charge = false
	caster.live_transfusion_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, 1 )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			-- Restore charge
			if caster.start_charge and caster.live_transfusion_charges < maximum_charges then
				-- Calculate stacks
				local next_charge = caster.live_transfusion_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= 3 then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
					live_transfusion_start_cooldown( caster, charge_replenish_time )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_charge = false
				end
				caster:SetModifierStackCount( modifierName, caster, next_charge )
				
				-- Update stack
				caster.live_transfusion_charges = next_charge
			end
			
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.live_transfusion_charges ~= maximum_charges then
				caster.start_charge = true
				return charge_replenish_time
			else
				return 0.5
			end
		end
	)
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Helper: Create timer to track cooldown
]]
function live_transfusion_start_cooldown( caster, charge_replenish_time )
	caster.live_transfusion_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.live_transfusion_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.live_transfusion_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Main: Check/Reduce charge, spawn dummy and cast the actual ability
]]
function LiveTransfusion( keys )
	-- Reduce stack if more than 0 else refund mana
	if keys.caster.live_transfusion_charges > 0 then
		-- variables
		local caster = keys.caster
		local target = keys.target_points[1]
		local ability = keys.ability
		local casterLoc = caster:GetAbsOrigin()
		local modifierName = "modifier_live_transfusion_stack_counter_datadriven"

		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )		
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )

		local ability_level = ability:GetLevel() - 1
		local target = keys.target_points[ 1 ]
		local direction = caster:GetForwardVector()
		local speed = (ability:GetLevelSpecialValueFor("transfusion_speed", ability:GetLevel() - 1 ) /33)
		local projectilespeed = (ability:GetLevelSpecialValueFor("transfusion_speed", ability:GetLevel() - 1 ))
		local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() - 1 )
		local hp_per_distance = ability:GetLevelSpecialValueFor("hp_cost", ability:GetLevel() - 1 )
		local damage_radius = ability:GetLevelSpecialValueFor("effect_radius", ability:GetLevel() - 1 )
		local duration = ability:GetDuration()
		if caster:HasScepter() then
			local effect_radius =  ability:GetLevelSpecialValueFor("effect_radius", ability:GetLevel() - 1 )
		else
			local effect_radius = ability:GetLevelSpecialValueFor("effect_radius_scepter", ability:GetLevel() - 1 )
		end
		local max_range = ability:GetLevelSpecialValueFor("transfusion_range", ability:GetLevel() - 1 )
		local hp_needed = hp_per_distance * speed


		
		-- Deplete charge
		local next_charge = caster.live_transfusion_charges - 1
		if caster.live_transfusion_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			live_transfusion_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.live_transfusion_charges = next_charge
		
		-- Check if stack is 0, display ability cooldown
		if caster.live_transfusion_charges == 0 then
			-- Start Cooldown from caster.live_transfusion_cooldown
			ability:StartCooldown( caster.live_transfusion_cooldown )
		else
			ability:EndCooldown()
		end
		
	
		StartPos = caster:GetAbsOrigin()
		distance = StartPos - target
		distance = distance:Length2D()
		traveled = 0

	
		projectiledistance = caster:GetHealth() / hp_per_distance
		if projectiledistance > 1000 then
			projectiledistance = 1000
			if projectiledistance > distance then
				projectiledistance = distance
			end
		end
		
		local projectileTable =
			{
			EffectName = "particles/bellatrix/bellatrix_live_transfusion.vpcf",
			Ability = ability,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = projectilespeed * direction,
			fDistance = projectiledistance,
			fStartRadius = damage_radius,
			fEndRadius = damage_radius,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = true,
			bProvidesVision = true,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
			}
		local projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )

		local i = 1

		caster:Stop()
		ProjectileManager:ProjectileDodge(caster)
		ability:ApplyDataDrivenModifier(caster, caster, "Blood_Visual", {})
		Timers:CreateTimer(function()
		if traveled < distance and caster:GetHealth() > hp_needed then
			traveled = traveled + speed
			caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * speed)
			caster:SetHealth(caster:GetHealth() -( hp_per_distance * speed ))
			i = i + 1
			if i == 3 then
			ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "modifier_bellatrix_thinker_buff_aura", {duration = duration})
			ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "modifier_bellatrix_thinker_debuff_aura", {duration = duration})
			i = 1
			end

			
			
			return 0.003
		else


			caster:RemoveModifierByName("Blood_Visual")
			return nil
		end
	end)
	else
		keys.ability:RefundManaCost()
	end
end

function Healup(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damagedone = keys.DamageDone
	local healpercent = ability:GetSpecialValueFor("impact_heal") / 100

	if target:IsHero() then
		caster:SetHealth(caster:GetHealth()+DamageDone * healpercent)
	end
end