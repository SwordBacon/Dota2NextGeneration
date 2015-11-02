if edgewalker_neutrino_strike == nil then edgewalker_neutrino_strike = class({}) end
--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_neutrino_strike_charges_thinker", "heroes/hero_edgewalker/modifier_neutrino_strike_charges_thinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutrino_strike_target_debuff", "heroes/hero_edgewalker/modifier_neutrino_strike_target_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_neutrino_strike_aoe_damage", "heroes/hero_edgewalker/modifier_neutrino_strike_aoe_damage", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:GetCastAnimation() return ACT_DOTA_ATTACK end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:GetIntrinsicModifierName() return "modifier_neutrino_strike_charges_thinker" end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnSpellStart()
	local hCaster = self:GetCaster()
	local hAbility = self

	-- proj direction vector
	local vDir = self:GetCursorPosition() - hCaster:GetOrigin()
	vDir.z = 0
	vDir = vDir:Normalized()

	-- projectile height
	local vAttachPosHeight = hCaster:GetAttachmentOrigin(hCaster:ScriptLookupAttachment("attach_attack1")).z
	self.vSpawnPoint = hCaster:GetOrigin()
	self.vSpawnPoint.z = vAttachPosHeight

	-- ability instance vars
	self.fProjectileSpeed = self:GetLevelSpecialValueFor("projectile_speed", self:GetLevel() - 1)
	self.fProjectileDistance = self:GetLevelSpecialValueFor("projectile_distance", self:GetLevel() - 1)
	self.fProjectileWidth = self:GetLevelSpecialValueFor("projectile_width", self:GetLevel() - 1)

	if self.fProjectileDistance > (self:GetCursorPosition() - hCaster:GetOrigin()):Length2D() then
		self.fProjectileDistance = (self:GetCursorPosition() - hCaster:GetOrigin()):Length2D()
	end

	local tProjectileInfo = 
	{
		EffectName 			= "particles/heroes/hero_edgewalker/edgewalker_neutrino_strike_linear_projectile.vpcf",
		Ability 			= self,
		vSpawnOrigin 		= self.vSpawnPoint,
		vVelocity 			= vDir * self.fProjectileSpeed,
		fDistance 			= self.fProjectileDistance,
		fStartRadius		= self.fProjectileWidth,
		fEndRadius			= self.fProjectileWidth,
		Source 				= hCaster,
		iUnitTargetTeam 	= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType 	= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags 	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	}
	self.nProjIndex = ProjectileManager:CreateLinearProjectile(tProjectileInfo)
	self.bPortalHit = false
	self.bGE_trigger = false
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnProjectileThink(vLocation)
	local debug = true
	if debug then
		DebugDrawSphere(vLocation, Vector(0,0,255), 255, self.fProjectileWidth, false, 1/30)
	end

	if not self.bPortalHit then
		local hCaster = self:GetCaster()
		local hAbi_ce = hCaster:FindAbilityByName("edgewalker_cascade_event")
		local tPortalTo = {}

		-- portal hit test
		hCaster.tPortalHistory = hCaster.tPortalHistory or {}
		for k,v in pairs(hCaster.tPortalHistory) do
			if GameRules:GetGameTime() <= tonumber(k) + hAbi_ce.fPortalDuration then
				local fDist = (vLocation - v):Length2D()
				-- check for nearby portals other than probable portal hit
				if fDist > hAbi_ce.fPortalRadius and fDist < 2000 then 
					table.insert(tPortalTo, v)
				-- portal hit check
				elseif fDist < hAbi_ce.fPortalRadius then 
					-- set to true to avoid looping
					self.bPortalHit = true
				end
			end
		end

		if self.bPortalHit and #tPortalTo > 0 then
			-- projectile continuation testing atm, i cant math
			local vDirection = ProjectileManager:GetLinearProjectileVelocity(self.nProjIndex) / self.fProjectileSpeed -- existing vector dir
			local fVec = (vLocation - self.vSpawnPoint):Length2D() -- distance covered
			local fRemainingDist = self.fProjectileDistance - fVec -- remaining distance

			for _,v in pairs(tPortalTo) do
				local vNewDir = RotatePosition(v, QAngle(0,0,0), vDirection)
				-- projectiles
				local info = 
				{
					EffectName 			= "particles/heroes/hero_edgewalker/edgewalker_neutrino_strike_linear_projectile.vpcf",
					Ability 			= self,
					vSpawnOrigin 		= v,
					vVelocity 			= vNewDir * self.fProjectileSpeed,
					fDistance 			= fRemainingDist,
					fStartRadius		= self.fProjectileWidth,
					fEndRadius			= self.fProjectileWidth,
					Source 				= hCaster,
					iUnitTargetTeam 	= DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetType 	= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					iUnitTargetFlags 	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
				}
				ProjectileManager:CreateLinearProjectile(info)
				-- debug
				if debug then
					local vTarget = v + vNewDir * fRemainingDist
					DebugDrawLine(v, vTarget, 255, 0, 0, false, self.fProjectileDistance/self.fProjectileSpeed)
				end
			end
			ProjectileManager:DestroyLinearProjectile(self.nProjIndex)
		else
			self.bPortalHit = false
		end
	end
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnProjectileHit(hTarget, vLocation)
	if hTarget and ( not hTarget:IsInvulnerable() ) then
		local hCaster = self:GetCaster()
		local fAOERadius, fDuration = self:GetSpecialValueFor("aoe_radius"), self:GetSpecialValueFor("break_duration")
		local units = FindUnitsInRadius(hCaster:GetTeamNumber(), vLocation, nil, fAOERadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		if units then
			for i=1, #units do
				units[i]:AddNewModifier(hCaster, self, "modifier_neutrino_strike_target_debuff", {duration = fDuration})
			end
		end
		return true
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnUpgrade()
	if IsServer() then
		if self:GetLevel() > 1 then
			local hCaster = self:GetCaster()
			local hChargeThinker = hCaster:FindModifierByName("modifier_neutrino_strike_charges_thinker")
			hChargeThinker:ForceRefresh()
		end
	end
end
--------------------------------------------------------------------------------------------------------
