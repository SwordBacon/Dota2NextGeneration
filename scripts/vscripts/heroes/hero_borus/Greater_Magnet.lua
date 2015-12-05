function greater_magnet_field (keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local wall_vacuum = ability:GetSpecialValueFor("radius")
	local wall_aoe = wall_vacuum - 100 
	local radius = ability:GetSpecialValueFor("radius")-100
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	local pos_charge = caster:FindAbilityByName("Positive_Charge")
	local neg_charge = caster:FindAbilityByName("Negative_Charge")
	local unit = keys.target
	
	local casterloc = caster:GetAbsOrigin()
	local targetloc = unit:GetAbsOrigin()
	local distance = (casterloc - targetloc):Length2D()
	local direction = (casterloc - targetloc):Normalized()

	if caster:HasModifier("Positive_Charge_Ally") and unit:HasModifier("Negative_Charge_Enemy") then
		if distance  < wall_aoe - 100 then
			
			pos_charge:ApplyDataDrivenModifier(caster, unit, "Positive_Charge_Enemy", {duration = duration})
			unit:RemoveModifierByName("Negative_Charge_Enemy")
		elseif distance > wall_aoe then
			unit:SetAbsOrigin(targetloc + direction * 5)
		end
	elseif caster:HasModifier("Positive_Charge_Ally") and unit:HasModifier("Positive_Charge_Enemy") then
		if distance > wall_aoe then
			unit:SetAbsOrigin(targetloc + direction * 5)
		end
	elseif caster:HasModifier("Negative_Charge_Ally") and unit:HasModifier("Positive_Charge_Enemy") then
		if distance  < wall_aoe - 100 then
			
			neg_charge:ApplyDataDrivenModifier(caster, unit, "Negative_Charge_Enemy", {duration = duration})
			unit:RemoveModifierByName("Positive_Charge_Enemy")
		elseif distance > wall_aoe then
			unit:SetAbsOrigin(targetloc + direction * 5)
		end
	elseif caster:HasModifier("Negative_Charge_Ally") and unit:HasModifier("Negative_Charge_Enemy") then
		if distance > wall_aoe then
			unit:SetAbsOrigin(targetloc + direction * 5)
		end

	elseif caster:HasModifier("Negative_Charge_Ally") and distance < wall_aoe then
		neg_charge:ApplyDataDrivenModifier(caster, unit, "Negative_Charge_Enemy", {duration = duration})
	elseif caster:HasModifier("Positive_Charge_Ally") and distance < wall_aoe then 
		pos_charge:ApplyDataDrivenModifier(caster, unit, "Positive_Charge_Enemy", {duration = duration})
	end

	
end
	
function start_greater_magnet (keys)
	local caster = keys.caster
	local ability = keys.ability
	local pos_charge = caster:FindAbilityByName("Positive_Charge")
	local neg_charge = caster:FindAbilityByName("Negative_Charge")
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	local radius = ability:GetSpecialValueFor("radius")-100

	

	--particle_pos = ParticleManager:CreateParticle("particles/borus/borus_greater_magnet_field_positive.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	--particle_neg = ParticleManager:CreateParticle("particles/borus/borus_greater_magnet_field_negative.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	--caster:RemoveModifierByName("Positive_Charge_Ally")
	--caster:RemoveModifierByName("Negative_Charge_Ally")

	local random = RandomFloat(0, 1)

	if random < 0.5 then 
		pos_charge:ApplyDataDrivenModifier(caster, caster, "Positive_Charge_Ally", {duration = duration})
		changeparticle = 1
		oldparticle = 0

		
	else
		neg_charge:ApplyDataDrivenModifier(caster, caster, "Negative_Charge_Ally", {duration = duration})
		changeparticle = 2
		oldparticle = 0 
	end
end

function createparticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")-100

	if oldparticle == changeparticle then
	else
		if changeparticle == 1 then
			ability:ApplyDataDrivenModifier(caster, caster, "posdummy", {})
			caster:RemoveModifierByName("negdummy")
			--ParticleManager:DestroyParticle( particle_neg, false )
			--ParticleManager:SetParticleControl(particle_pos, 1, Vector(radius, radius, radius))

			--particle_neg = ParticleManager:CreateParticle("particles/borus/borus_greater_magnet_field_negative.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		elseif changeparticle == 2 then
			ability:ApplyDataDrivenModifier(caster, caster, "negdummy", {})
			caster:RemoveModifierByName("posdummy")
			--ParticleManager:DestroyParticle( particle_pos, false )
			--ParticleManager:SetParticleControl(particle_neg, 1, Vector(radius, radius, radius))
			--particle_pos = ParticleManager:CreateParticle("particles/borus/borus_greater_magnet_field_positive.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end 

	oldparticle = changeparticle
	if caster:HasModifier("Positive_Charge_Ally") then
		changeparticle = 1
	elseif caster:HasModifier("Negative_Charge_Ally") then
		changeparticle = 2
	end
end

function removeparticles(keys)
	local caster = keys.caster
	--ParticleManager:DestroyParticle( particle_pos, false )	
	--ParticleManager:DestroyParticle( particle_neg, false )
	caster:RemoveModifierByName("posdummy")
	caster:RemoveModifierByName("negdummy")
	changeparticle = nil
	oldparticle = nil
end

function posdummy (keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")-100
	particle_pos = ParticleManager:CreateParticle("particles/borus/borus_greater_magnet_field_positive.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle_pos, 1, Vector(radius, radius, radius))
end

function negdummy (keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")-100

	particle_neg = ParticleManager:CreateParticle("particles/borus/borus_greater_magnet_field_negative.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle_neg, 1, Vector(radius, radius, radius))
end

function posdummy_clean (keys)
	local caster = keys.caster
	ParticleManager:DestroyParticle( particle_pos, false )
end
function negdummy_clean (keys)
	local caster = keys.caster
	ParticleManager:DestroyParticle( particle_neg, false )
end









