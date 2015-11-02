if edgewalker_cascade_event == nil then edgewalker_cascade_event = class({}) end
--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_cascade_event_portal_tooltip", "heroes/hero_edgewalker/modifier_cascade_event_portal_tooltip", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
function edgewalker_cascade_event:GetCastAnimation() return ACT_DOTA_CAST_ABILITY_1 end
--------------------------------------------------------------------------------------------------------
function edgewalker_cascade_event:OnSpellStart()
	-- caster and ability handle
	local hCaster = self:GetCaster()

	-- projectile direction vector (caster to cursor)
	local vDirection = self:GetCursorPosition() - hCaster:GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	-- projectile origin level to attack pos height
	local vAttachPosHeight = hCaster:GetAttachmentOrigin(hCaster:ScriptLookupAttachment("attach_attack1")).z
	self.vSpawnPoint = hCaster:GetOrigin()
	self.vSpawnPoint.z = vAttachPosHeight

	-- ability instance vars saved in ability table for reference in other functions
	self.fProjectileSpeed = self:GetSpecialValueFor("projectile_speed")
	self.fProjectileDistance = self:GetSpecialValueFor("projectile_distance")
	self.fPortalDuration = self:GetSpecialValueFor("portal_duration")
	self.fPortalRadius = self:GetSpecialValueFor("portal_radius")

	if self.fProjectileDistance > (self:GetCursorPosition() - hCaster:GetOrigin()):Length2D() then
		self.fProjectileDistance = (self:GetCursorPosition() - hCaster:GetOrigin()):Length2D()
	end

	-- projectile table
	local tProjectileInfo = {
		EffectName 			= "particles/heroes/hero_edgewalker/edgewalker_cascade_event_projectile.vpcf",
		Ability 			= self,
		vSpawnOrigin 		= self.vSpawnPoint,
		vVelocity 			= vDirection * self.fProjectileSpeed,
		fDistance 			= self.fProjectileDistance,
		fStartRadius		= 0,
		fEndRadius			= 0,
		Source 				= hCaster
	}
	
	-- saved projectile index for determining projectile finish vector location
	self.nProjectileIndex = ProjectileManager:CreateLinearProjectile(tProjectileInfo)
end
--------------------------------------------------------------------------------------------------------
function edgewalker_cascade_event:OnProjectileThink(vLocation)
	DebugDrawSphere(vLocation, Vector(255,0,0), 255, 10, false, 1/30)
end
--------------------------------------------------------------------------------------------------------
function edgewalker_cascade_event:OnProjectileHit(hTarget, vLocation)
	-- target is nil on OnProjectileFinish event
	if 	hTarget == nil then
		local hCaster = self:GetCaster()

		-- determine vLocation from projectile velocity
		local vDirection = ProjectileManager:GetLinearProjectileVelocity(self.nProjectileIndex) / self.fProjectileSpeed
		local vLocation = self.vSpawnPoint + vDirection * self.fProjectileDistance
	
		-- for debugging  
		DebugDrawCircle(vLocation, Vector(255,0,0), 1, self.fPortalRadius, false, self.fPortalDuration)
	
		-- particle placeholder
		local nParticleIndex = ParticleManager:CreateParticle("particles/heroes/hero_edgewalker/edgewalker_cascade_event_portal.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
		ParticleManager:SetParticleControl(nParticleIndex, 0, vLocation)
		Timers:CreateTimer(self.fPortalDuration, function() 
			ParticleManager:DestroyParticle(nParticleIndex, false)
			ParticleManager:ReleaseParticleIndex(nParticleIndex)
		end)
	
		-- modifier tooltip
		local fTooltipDuration = self:GetSpecialValueFor("portal_duration")
		hCaster:AddNewModifier(hCaster, self, "modifier_cascade_event_portal_tooltip", {duration = fTooltipDuration})
	
		-- portal table to store portal locations
		hCaster.tPortalHistory = hCaster.tPortalHistory or {}
		local t = hCaster.tPortalHistory
		local fNow = GameRules:GetGameTime()
		t[fNow] = vLocation
	
		-- delete portal location kv after portal duration
		for k in pairs(t) do
			if tonumber(k) <= GameRules:GetGameTime() - self.fPortalDuration then
				t[k] = nil
			end
		end
	end
	return false
end