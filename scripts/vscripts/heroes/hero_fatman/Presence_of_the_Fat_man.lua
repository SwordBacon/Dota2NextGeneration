function LevelingUp (keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_name = "Extra_Strength"
	local modifier = caster:FindModifierByName(modifier_name)
	



	if ability:GetLevel() == 1 then
		ability:ApplyDataDrivenModifier(caster, caster, "Presence_of_the_Fat_Man_aura1", {})
		caster:RemoveModifierByName("Presence_of_the_Fat_Man_aura2")
		caster:RemoveModifierByName("Presence_of_the_Fat_Man_aura3")
		ability:ApplyDataDrivenModifier( caster, caster, modifier_name, {} )
		caster:SetModifierStackCount( modifier_name, caster, 0 )
		
	elseif ability:GetLevel() == 2 then
		ability:ApplyDataDrivenModifier(caster, caster, "Presence_of_the_Fat_Man_aura2", {})
		caster:RemoveModifierByName("Presence_of_the_Fat_Man_aura3")
	elseif ability:GetLevel() == 3 then
		ability:ApplyDataDrivenModifier(caster, caster, "Presence_of_the_Fat_Man_aura3", {})
	end
end

function DamageInterval (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_name_enemy = "Minus_Strength"
	DamageTick = ability:GetSpecialValueFor("DamageTick") / 100
	CasterHP = caster:GetHealth()
	interval = ability:GetSpecialValueFor("DamageInterval")
	if target:IsHero() then
		if not target:HasModifier(modifier_name_enemy) then
			ability:ApplyDataDrivenModifier(caster, target, modifier_name_enemy, {})
			target:SetModifierStackCount(modifier_name_enemy, caster, 0)
			print("DONT EXIST")
		end
	end	


	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = CasterHP * DamageTick * interval
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS -- Doesnt trigger abilities and items that get disabled by damage

	ApplyDamage(damage_table)
end

function Extra_Strength( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local modifier_name = "Extra_Strength"
	local modifier_name_enemy = "Minus_Strength"
	local modifier = caster:FindModifierByName(modifier_name)
	local strcharges = caster:GetModifierStackCount(modifier_name, caster)
	target.mincharges = target:GetModifierStackCount(modifier_name_enemy, caster)

	
	caster:SetModifierStackCount(modifier_name, caster, strcharges +1 )
	caster:CalculateStatBonus()
	
	target:SetModifierStackCount(modifier_name_enemy, caster, target.mincharges +1)
	target:CalculateStatBonus()
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
	
end
		
