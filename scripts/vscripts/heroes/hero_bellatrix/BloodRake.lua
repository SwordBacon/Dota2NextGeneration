function BloodRakeSelfDamage( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local self_damage = ability:GetLevelSpecialValueFor( "health_cost" , ability:GetLevel() - 1  )
	local HP = caster:GetHealth()
	local MagicResist = caster:GetMagicalArmorValue()
	local damageType = ability:GetAbilityDamageType()

	-- Calculate the magic damage
	local damagePostReduction = self_damage * (1 - MagicResist)
	
	-- If its lethal damage, set hp to 1, else do the full self damage
	if HP <= damagePostReduction then
		caster:SetHealth(1)
	else
		-- Self Damage
		ApplyDamage({ victim = caster, attacker = caster, damage = self_damage,	damage_type = damageType })
	end

end



function CasterStartLoc(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() - 1 ) + 0.5
	CasterStartLocation = caster:GetAbsOrigin()
	CasterDirection = caster:GetForwardVector()
	dummylocation = CasterStartLocation + (CasterDirection)
	ability:ApplyDataDrivenThinker(caster, caster:GetAbsOrigin(), "MarkLocation", {duration = duration})
end

function TeleportInFront (keys)
	local target = keys.target

	FindClearSpaceForUnit(target, dummylocation, false)
end

