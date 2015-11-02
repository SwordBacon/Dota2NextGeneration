if modifier_gravity_well_trigger == nil then modifier_gravity_well_trigger = class({}) end

function modifier_gravity_well_trigger:OnCreated(kv)
	if IsServer() then
		local hCaster = self:GetCaster()
		self.fAOERadius = 200 -- test/placeholder
		self.fPullDistance = self:GetAbility():GetLevelSpecialValueFor("pull_distance", self:GetAbility():GetLevel() - 1)
		self.fDamage = self:GetAbility():GetLevelSpecialValueFor("damage", self:GetAbility():GetLevel() - 1)
		self.vCenter = self:GetParent():GetOrigin()
		self.tUnits = FindUnitsInRadius(hCaster:GetTeamNumber(), self.vCenter, nil, self.fAOERadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		
		--particle
		local nIndex = ParticleManager:CreateParticle("particles/heroes/hero_edgewalker/edgewalker_gravity_well_trigger.vpcf", PATTACH_ABSORIGIN, hCaster)
		ParticleManager:SetParticleControl(nIndex, 0, self.vCenter)
		ParticleManager:SetParticleControl(nIndex, 1, Vector(self.fAOERadius,0,0))
		
		if self.tUnits then
			DebugDrawCircle(self:GetParent():GetOrigin(), Vector(255,0,0), 2, self.fAOERadius, false, 1.0)
			for i=1, #self.tUnits do
				local hTarget = self.tUnits[i]
				local vDir = GetGroundPosition((self.vCenter - hTarget:GetOrigin()), hTarget):Normalized()
				local vNewLocation = hTarget:GetOrigin() + vDir * self.fPullDistance
				FindClearSpaceForUnit(hTarget, vNewLocation, false)
				ApplyDamage({
					victim = hTarget,
					attacker = hCaster,
					damage = self.fDamage,
					damage_type = DAMAGE_TYPE_MAGICAL
					})
			end			
		end
		self:Destroy()
	end
end