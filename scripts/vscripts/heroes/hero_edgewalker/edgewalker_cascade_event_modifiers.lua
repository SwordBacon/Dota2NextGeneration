----------------------------------------------------------------------------------------------------------
--[[	modifier_cascade_event_portal 																	]]
----------------------------------------------------------------------------------------------------------
if modifier_cascade_event_portal == nil then modifier_cascade_event_portal = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal:DeclareFunctions() return { MODIFIER_PROPERTY_FORCE_DRAW_MINIMAP } end
----------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal:GetForceDrawOnMinimap() return 1 end
----------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal:OnCreated(kv)
	if IsServer() then
		local hCaster, hParent = self:GetCaster(), self:GetParent()
		local vParentOrigin = hParent:GetOrigin()
		-- vector target direction
		local vForward = hParent:GetForwardVector()
		if hParent:GetClassname() == "npc_dota_thinker" then
			vForward = self:GetAbility():GetDirectionVector()
		end
		self.hPortal = CreateUnitByName("npc_edgewalker_portal", vParentOrigin, false, nil, hCaster, hCaster:GetTeamNumber())
		self.hPortal:SetForwardVector(vForward)
		-- !IMPORTANT to avoid units getting stuck with portals
		ResolveNPCPositions(vParentOrigin, self.hPortal:GetHullRadius())

		-- face text in front of portal, a placeholder ofc
		local fPortalRadius = self:GetAbility():GetSpecialValueFor("portal_radius")
		local fPortalDuration = self:GetAbility():GetSpecialValueFor("portal_duration")
		local vTextLoc = vParentOrigin + vForward * (fPortalRadius/2)
		DebugDrawText(vTextLoc, "FACE", true, fPortalDuration)

		-- portal particle
		if self:GetAbility():GetAbilityName() == "edgewalker_cascade_event" then
			self.nPortalParticle = ParticleManager:CreateParticle("particles/heroes/hero_edgewalker/edgewalker_cascade_event_portal_vector.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hCaster)
			ParticleManager:SetParticleAlwaysSimulate(self.nPortalParticle)
			ParticleManager:SetParticleControl(self.nPortalParticle, 0, vParentOrigin)
			ParticleManager:SetParticleControl(self.nPortalParticle, 1, vParentOrigin)
			ParticleManager:SetParticleControl(self.nPortalParticle, 2, vParentOrigin)
			ParticleManager:SetParticleControlForward(self.nPortalParticle, 2, vForward)
		end

		-- if parent has movement capability, start interval think which updates portal position and forward vector
		if hParent:HasMovementCapability() then
			self:StartIntervalThink(1/30)
		end

		-- debug portal radius
		DebugDrawCircle(vParentOrigin, Vector(255,0,0), 1, fPortalRadius, false, fPortalDuration)

		-- gravity well
		local hEdgeWalkerAbility = hCaster:FindAbilityByName("edgewalker_gravity_well")
		if hEdgeWalkerAbility and hEdgeWalkerAbility:GetLevel() > 0 then
			CreateModifierThinker(hCaster, hEdgeWalkerAbility, "modifier_gravity_well_pull", { location = vParentOrigin }, vParentOrigin, hCaster:GetTeamNumber(), false )
		end
	end
end
----------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal:OnIntervalThink()
	if IsServer() then
		-- update portal position and forward vector
		local hParent = self:GetParent()
		local vPosition = GetGroundPosition(hParent:GetOrigin(), hParent)
		local vForward = hParent:GetForwardVector()
		local fPortalRadius = self:GetAbility():GetSpecialValueFor("portal_radius")
		self.hPortal:SetOrigin(vPosition)
		self.hPortal:SetForwardVector(vForward)

		-- update particle pos and face
		if self:GetAbility():GetAbilityName() == "edgewalker_cascade_event" then
			ParticleManager:SetParticleControl(self.nPortalParticle, 0, vPosition)
			ParticleManager:SetParticleControl(self.nPortalParticle, 1, vPosition)
			ParticleManager:SetParticleControl(self.nPortalParticle, 2, vPosition)
			ParticleManager:SetParticleControlForward(self.nPortalParticle, 2, vForward)
		else
			local vLineTarget = vPosition + vForward * 200
			DebugDrawLine(vPosition, vLineTarget, 255, 255, 0, false, 1/30)
		end
	end	
end
----------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal:OnDestroy()
	if IsServer() then 
		-- destroy and release portal particle
		if self:GetParent():GetClassname() == "npc_dota_thinker" then
			ParticleManager:DestroyParticle(self.nPortalParticle, false)
			ParticleManager:ReleaseParticleIndex(self.nPortalParticle)
		end

		-- delete portal entity on modifier destroy
		UTIL_Remove(self.hPortal)

		-- gravity well
		local hCaster = self:GetCaster()
		local hEdgeWalkerAbility = hCaster:FindAbilityByName("edgewalker_gravity_well")
		if hEdgeWalkerAbility and hEdgeWalkerAbility:GetLevel() > 0 then
			CreateModifierThinker(hCaster, hEdgeWalkerAbility, "modifier_gravity_well_pull", { location = self:GetParent():GetOrigin() }, self:GetParent():GetOrigin(), hCaster:GetTeamNumber(), false )
		end
	end
end

----------------------------------------------------------------------------------------------------------
--[[	modifier_cascade_event_portal_tooltip 															]]
----------------------------------------------------------------------------------------------------------
if modifier_cascade_event_portal_tooltip == nil then modifier_cascade_event_portal_tooltip = class({}) end
----------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal_tooltip:OnCreated()
	if IsServer() then

	end
end

function modifier_cascade_event_portal_tooltip:OnIntervalThink()
	if IsServer() then

	end
end