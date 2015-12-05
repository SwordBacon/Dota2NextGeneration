function Metal_Rod (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local rodspacing = ability:GetSpecialValueFor("Rod_Spacing")
	local rodelements = ability:GetSpecialValueFor("Rod_Elements")
	local rodsize = ability:GetSpecialValueFor("Metal_Rod_Size")
	local direction_to_target_point = caster:GetForwardVector()
	local leash_duration = ability:GetLevelSpecialValueFor("leash_duration", ( ability:GetLevel() - 1 ))
	local duration =ability:GetDuration()

	local direction_to_target_point_normal = Vector(-direction_to_target_point.y, direction_to_target_point.x, direction_to_target_point.z)
	local vector_distance_from_center = (direction_to_target_point_normal * (rodelements * rodspacing))
	local one_end_point = target_point - vector_distance_from_center
	local other_end_point = target_point + vector_distance_from_center

	--Display the Ice Wall particles in a line.
	--local metal_rod_particle_effect = ParticleManager:CreateParticle("particles/borus/metal_rod_metalblock.vpcf", PATTACH_ABSORIGIN, keys.caster)
	--ParticleManager:SetParticleControl(metal_rod_particle_effect, 0, target_point - vector_distance_from_center)
	--ParticleManager:SetParticleControl(metal_rod_particle_effect, 1, target_point + vector_distance_from_center)

	--Timers:CreateTimer({
	--	endTime = duration,
	--	callback = function()
	--		ParticleManager:DestroyParticle(metal_rod_particle_effect, false)
	--	end
	--})

	for i=0, rodelements, 1 do
		local metal_rod_unit = CreateUnitByName("npc_magnet_unit", one_end_point + direction_to_target_point_normal * (rodspacing * i), false, nil, nil, caster:GetTeam())
		 
		--We give the ice wall dummy unit its own instance of Ice Wall both to more easily make it apply the correct intensity of slow (based on Quas' level)
		--and because if Invoker uninvokes Ice Wall and the spell is removed from his toolbar, existing modifiers originating from that ability can start to error out.
		metal_rod_unit:AddAbility("Metal_Rod")
		local metal_rod_unit_ability = metal_rod_unit:FindAbilityByName("Metal_Rod")
		if metal_rod_unit_ability ~= nil then
			metal_rod_unit_ability:ApplyDataDrivenModifier(metal_rod_unit, metal_rod_unit, "metal_rod_modifier_dummy", {duration = -1})
		end
				metal_rod_unit.parent_caster = keys.caster  --Store the reference to the Invoker that spawned this Ice Wall unit.
		
		--Remove the Ice Wall auras after the duration ends, and the dummy units themselves after their aura slow modifiers will have all expired.
		Timers:CreateTimer({
			endTime = duration,
			callback = function()
				metal_rod_unit:RemoveModifierByName("metal_rod_modifier_dummy")
				metal_rod_unit:RemoveSelf()
				
			end
		})
	end

	for i=1, rodelements, 1 do
		local metal_rod_unit = CreateUnitByName("npc_magnet_unit", other_end_point - direction_to_target_point_normal * (rodspacing * i), false, nil, nil, caster:GetTeam())
		 
		--We give the ice wall dummy unit its own instance of Ice Wall both to more easily make it apply the correct intensity of slow (based on Quas' level)
		--and because if Invoker uninvokes Ice Wall and the spell is removed from his toolbar, existing modifiers originating from that ability can start to error out.
		metal_rod_unit:AddAbility("Metal_Rod")
		local metal_rod_unit_ability = metal_rod_unit:FindAbilityByName("Metal_Rod")
		if metal_rod_unit_ability ~= nil then
			metal_rod_unit_ability:ApplyDataDrivenModifier(metal_rod_unit, metal_rod_unit, "metal_rod_modifier_dummy", {duration = -1})
		end
				metal_rod_unit.parent_caster = keys.caster  --Store the reference to the Invoker that spawned this Ice Wall unit.
		
		--Remove the Ice Wall auras after the duration ends, and the dummy units themselves after their aura slow modifiers will have all expired.
		Timers:CreateTimer({
			endTime = duration,
			callback = function()
				metal_rod_unit:RemoveModifierByName("metal_rod_modifier_dummy")
				metal_rod_unit:RemoveSelf()		
			end
		})
	end
end
