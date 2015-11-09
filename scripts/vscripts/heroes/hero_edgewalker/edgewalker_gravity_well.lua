if edgewalker_gravity_well == nil then edgewalker_gravity_well = class({}) end
--------------------------------------------------------------------------------------------------------
if modifier_gravity_well_pull == nil then modifier_gravity_well_pull = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_gravity_well_pull:OnCreated(kv)
	if IsServer() then
		local hCaster, hAbility = self:GetCaster(), self:GetAbility()
		local fAreaRadius = hAbility:GetSpecialValueFor("radius")
		local fPullDistance = hAbility:GetLevelSpecialValueFor("pull_distance", hAbility:GetLevel()-1)
		local fGravityDamage = hAbility:GetLevelSpecialValueFor("damage", hAbility:GetLevel()-1)
		local vLocation = kv.location or self:GetParent():GetOrigin()

		local tUnits = FindUnitsInRadius(hCaster:GetTeamNumber(), vLocation, nil, fAreaRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

		--particle
		local nIndex = ParticleManager:CreateParticle("particles/heroes/hero_edgewalker/edgewalker_gravity_well_trigger.vpcf", PATTACH_ABSORIGIN, hCaster)
		ParticleManager:SetParticleControl(nIndex, 0, vLocation)
		ParticleManager:SetParticleControl(nIndex, 1, Vector(fAreaRadius,0,0))

		DebugDrawCircle(vLocation, Vector(255,0,0), 2, fAreaRadius, false, 0.3)
		if #tUnits > 0 then
			for i=1, #tUnits do
				local vPullDirection = GetGroundPosition((vLocation - tUnits[i]:GetOrigin()),  tUnits[i]):Normalized()
				local vPullToLocation = tUnits[i]:GetOrigin() + vPullDirection * fPullDistance
				FindClearSpaceForUnit(tUnits[i], vPullToLocation, false)
				ApplyDamage({
					victim = tUnits[i],
					attacker = hCaster,
					damage = fGravityDamage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = hAbility
					})
			end
		end
		self:Destroy()
	end
end
