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

function CasterStartLoc (keys)
	local caster = keys.caster
	CasterStartLocation = caster:GetAbsOrigin()

function TeleportInFront (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	CasterLocation = caster:GetAbsOrigin()
	CasterDirection = caster:GetForwardVector()


	FindClearSpaceForUnit(target, CasterLocation + CasterDirection * 100, false)
end

