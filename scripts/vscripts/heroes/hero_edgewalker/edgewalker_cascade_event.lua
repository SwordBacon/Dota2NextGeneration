if edgewalker_cascade_event == nil then edgewalker_cascade_event = class({}) end
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

	-- cursor pos priority
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

	-- vision
	AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, self.fPortalRadius, 1/30, false)
end
--------------------------------------------------------------------------------------------------------
function edgewalker_cascade_event:OnProjectileHit(hTarget, vLocation)
	-- target is nil on OnProjectileFinish event
	if hTarget == nil then
		self:OnProjectileFinish(vLocation)
	end
end
--------------------------------------------------------------------------------------------------------
function edgewalker_cascade_event:OnProjectileFinish(vLocation)
	-- vars
	local hCaster = self:GetCaster()
	local vLocGround =  GetGroundPosition(vLocation, hCaster)
	-- modifier that creates portal
	CreateModifierThinker(hCaster, self, "modifier_cascade_event_portal", { duration = self.fPortalDuration }, vLocGround, hCaster:GetTeamNumber(), false)
end