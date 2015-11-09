if edgewalker_neutrino_strike == nil then edgewalker_neutrino_strike = class({}) end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:GetIntrinsicModifierName() return "modifier_neutrino_strike_charges" end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:GetCastAnimation() return ACT_DOTA_ATTACK end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:GetManaCost(iLevel)
	if IsServer() then
		local fInitialManaCost = self:GetLevelSpecialValueFor("initial_mana_cost", self:GetLevel()-1)
		local fManaPercentageCost = self:GetSpecialValueFor("addtl_mana_cost_percentage")
		local fTotalManaCost = fInitialManaCost + ( fManaPercentageCost/100  * self:GetCaster():GetMana() )
		return fTotalManaCost
	end
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnSpellStart()
	-- caster and ability handle
	local hCaster = self:GetCaster()

	-- projectile direction vector (caster to cursor)
	local vDirection = self:GetCursorPosition() - hCaster:GetOrigin()
	vDirection.z = 0.0
	vDirection = vDirection:Normalized()

	-- projectile origin level to attack pos height
	self.vAttachPosHeight = hCaster:GetAttachmentOrigin(hCaster:ScriptLookupAttachment("attach_attack1")).z
	self.vSpawnPoint = hCaster:GetOrigin()
	self.vSpawnPoint.z = self.vAttachPosHeight

	-- ability instance vars
	self.fProjectileSpeed = self:GetLevelSpecialValueFor("projectile_speed", self:GetLevel() - 1)
	self.fProjectileDistance = self:GetSpecialValueFor("projectile_distance")
	self.fProjectileWidth = self:GetLevelSpecialValueFor("projectile_width", self:GetLevel() - 1)
	self.fAOERadius = self:GetSpecialValueFor("aoe_radius")
	self.fDuration = self:GetSpecialValueFor("break_duration")

	local info = {
		EffectName 			= "particles/heroes/hero_edgewalker/edgewalker_cascade_event_projectile.vpcf",
		Ability 			= self,
		vSpawnOrigin 		= self.vSpawnPoint,
		vVelocity 			= vDirection * self.fProjectileSpeed,
		fDistance 			= self.fProjectileDistance,
		fStartRadius		= self.fProjectileWidth,
		fEndRadius			= self.fProjectileWidth,
		Source 				= hCaster,
		iUnitTargetTeam 	= DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType 	= DOTA_UNIT_TARGET_ALL
	}
	ProjectileManager:CreateLinearProjectile(info)
	self.bPortalIsHit = false
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnProjectileThink_ExtraData(vLocation, table)
	-- debug projectile
	DebugDrawSphere(vLocation, Vector(255,0,0), 255, self.fProjectileWidth, false, 1/30)
	-- vision
	AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, self.fProjectileWidth, 1/30, false)
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	if hTarget ~= nil then
		if hTarget:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			-- but if its a portal then let the projectile pass through
			if hTarget:GetUnitLabel() == "edgewalker_portal" then
				return false
			end
			-- valid enemy target
			print("projectile hit an enemy")
			local fAmplifyDuration = self:GetSpecialValueFor("debuff_duration")
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_neutrino_strike_amplify_target", { duration = fAmplifyDuration })
			local hCaster = self:GetCaster()
			local hEdgeWalkerAbility = hCaster:FindAbilityByName("edgewalker_gravity_well")
			if hEdgeWalkerAbility and hEdgeWalkerAbility:GetLevel() > 0 then
				CreateModifierThinker(hCaster, hEdgeWalkerAbility, "modifier_gravity_well_pull", { location = vLocation }, vLocation, hCaster:GetTeamNumber(), false )
			end
			return true
		-- target is a portal of caster's team	
		elseif hTarget:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
			-- if its a portal and and projectile isn't coming from a portal already
			if hTarget:GetUnitLabel() == "edgewalker_portal" and not self.bPortalIsHit then				
				print("projectile hit a portal")
				-- return true if there are nearby portals and false if none
				return self:OnPortalHit(hTarget, vLocation)
			end
		end
	else		
		self:OnProjectileFinish(vLocation)
	end	
	return false
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnProjectileFinish(vLocation)
	print("projectile reached end distance")
	local hCaster = self:GetCaster()
	local hEdgeWalkerAbility = hCaster:FindAbilityByName("edgewalker_gravity_well")
	if hEdgeWalkerAbility and hEdgeWalkerAbility:GetLevel() > 0 then
		CreateModifierThinker(hCaster, hEdgeWalkerAbility, "modifier_gravity_well_pull", { location = vLocation }, vLocation, hCaster:GetTeamNumber(), false )
	end
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnPortalHit(hPortal, vLocation)
	-- vars
	local hCaster = self:GetCaster()
	local fPortalSearchRadius = self:GetSpecialValueFor("portal_search_radius")
	-- look for other portals
	local tNearbyEntities = Entities:FindAllByNameWithin("npc_dota_thinker", vLocation, fPortalSearchRadius)
	local tNearbyPortals = {}
	for i=1, #tNearbyEntities do
		if tNearbyEntities[i]:GetUnitLabel() == "edgewalker_portal" and tNearbyEntities[i] ~= hPortal and tNearbyEntities[i]:GetOwner() == hCaster then
			table.insert(tNearbyPortals, tNearbyEntities[i])
		end
	end
	-- if there are nearby portals
	if #tNearbyPortals > 0 then
		-- set the hit condition true to avoid looping
		self.bPortalIsHit = true
		-- set off gravity well if it is leveled up, on portal that is hit by the projectile
		local hEdgeWalkerAbility = hCaster:FindAbilityByName("edgewalker_gravity_well")
		if hEdgeWalkerAbility and hEdgeWalkerAbility:GetLevel() > 0 then
			CreateModifierThinker(hCaster, hEdgeWalkerAbility, "modifier_gravity_well_pull", { location = vLocation }, vLocation, hCaster:GetTeamNumber(), false )
		end
		-- remaining distance 
		local fDistanceRemaining = self.fProjectileDistance - (vLocation - self.vSpawnPoint):Length2D()
		for i=1, #tNearbyPortals do
			-- get the new direction of projectile, using only getforwardvector results to a non zero velocity
			local vPortalOrigin = GetGroundPosition(tNearbyPortals[i]:GetOrigin(), tNearbyPortals[i])
			local vTargetLocation = GetGroundPosition((tNearbyPortals[i]:GetOrigin() + tNearbyPortals[i]:GetForwardVector() * fDistanceRemaining), tNearbyPortals[i])
			local vNewDirection = (vTargetLocation - vPortalOrigin):Normalized()
			-- correcting projectile height which is based off the caster's attack hand's height during onspellstart event
			local vNewSpawnPoint = tNearbyPortals[i]:GetOrigin()
			vNewSpawnPoint.z = self.vAttachPosHeight
			-- projectile info
			local info = {
				EffectName 			= "particles/heroes/hero_edgewalker/edgewalker_cascade_event_projectile.vpcf",
				Ability 			= self,
				vSpawnOrigin 		= vNewSpawnPoint,
				vVelocity 			= vNewDirection * self.fProjectileSpeed,
				fDistance 			= fDistanceRemaining,
				fStartRadius		= self.fProjectileWidth,
				fEndRadius			= self.fProjectileWidth,
				Source 				= hCaster,
				iUnitTargetTeam 	= DOTA_UNIT_TARGET_TEAM_BOTH,
				iUnitTargetType 	= DOTA_UNIT_TARGET_ALL	
			}
			ProjectileManager:CreateLinearProjectile(info)
			-- set off gravity well on the portal the projectile has now ported into
			local hEdgeWalkerAbility = hCaster:FindAbilityByName("edgewalker_gravity_well")
			if hEdgeWalkerAbility and hEdgeWalkerAbility:GetLevel() > 0 then
				CreateModifierThinker(hCaster, hEdgeWalkerAbility, "modifier_gravity_well_pull", { location = vNewSpawnPoint }, vNewSpawnPoint, hCaster:GetTeamNumber(), false )
			end
		end
		return true
	end
	return false
end
--------------------------------------------------------------------------------------------------------
function edgewalker_neutrino_strike:OnUpgrade()
	if IsServer() then
		local hCaster = self:GetCaster()
		if self:GetLevel() > 1 then
			local hChargeCounterModifier = hCaster:FindModifierByName("modifier_neutrino_strike_charges_counter")
			local fPreviousInterval, fInterval = self:GetLevelSpecialValueFor("charges_think_interval", self:GetLevel()-2), self:GetLevelSpecialValueFor("charges_think_interval", self:GetLevel()-1)
			local fRemainingDuration = hChargeCounterModifier:GetRemainingTime()
			local fNewDuration = fRemainingDuration * fInterval / fPreviousInterval
			print(fNewDuration)
			hChargeCounterModifier:SetDuration(fNewDuration, true)
			print(hChargeCounterModifier:GetDuration())
		end
	end
end
--------------------------------------------------------------------------------------------------------