if modifier_gravity_well == nil then modifier_gravity_well = class({}) end
--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_gravity_well_trigger", "heroes/hero_edgewalker/modifier_gravity_well_trigger", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
function modifier_gravity_well:OnCreated(kv)
	if IsServer() then		
		local hParent = self:GetParent()
		local hAbility = self

		for i=0, hParent:GetAbilityCount() - 1 do
			if hParent:GetAbilityByIndex(i) == nil then
				break
			end
			local a = hParent:GetAbilityByIndex(i)
			print(a:GetAbilityName())
			-- bitfield helper to determine ability behavior
			local bFlag = function(...)
				return bit.band(a:GetBehavior(),...) ~= 0
			end
			-- works only on ability_lua baseclass !IMPORTANT
			if a:GetClassname() == "ability_lua" then						
				-- if its a projectile based, OnProjectileHit function should exist
				if a.OnProjectileHit then						
					-- override functions
					local _OnSpellStart = a.OnSpellStart
					function a:OnSpellStart(vLocation)
						self.bGE_trigger = false
						_OnSpellStart(self, vLocation)
					end
					local _OnProjectileHit = a.OnProjectileHit -- old func
					function a:OnProjectileHit(hTarget, vLocation) -- new/override func
						if not self.bGE_trigger then
							hAbility:OnTrigger(vLocation)
							self.bGE_trigger = true
						end
						return _OnProjectileHit(self, hTarget, vLocation) 					
					end
					
				--[[ TODO:
				elseif bFlag(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and a.OnProjectileHit == nil then
				elseif bFlag(DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
					 ]]
				elseif bFlag(DOTA_ABILITY_BEHAVIOR_POINT) and a.OnProjectileHit == nil then
				end
			end
			--[[ TODO: Sounds impossible tbh]]
			if a:GetClassname() == "ability_datadriven" then
			end
		end		
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_gravity_well:OnTrigger(vLocation)
	if IsServer() then
		print("OnTrigger")
		local hCaster = self:GetCaster()
		CreateModifierThinker(hCaster, self:GetAbility(), "modifier_gravity_well_trigger", {}, vLocation, hCaster:GetTeamNumber(), false)
	end
end