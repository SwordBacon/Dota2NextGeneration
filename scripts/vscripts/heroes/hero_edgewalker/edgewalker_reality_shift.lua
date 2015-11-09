if edgewalker_reality_shift == nil then edgewalker_reality_shift = class({}) end
--------------------------------------------------------------------------------------------------------
function edgewalker_reality_shift:GetCastAnimation() return ACT_DOTA_CAST_ABILITY_4 end
--------------------------------------------------------------------------------------------------------
function edgewalker_reality_shift:OnInventoryContentsChanged()
	if self:GetCaster():HasItemInInventory("item_ultimate_scepter") or self:GetCaster():HasModifier("modifier_item_ultimate_scepter") then
		if not self:GetCaster():HasModifier("modifier_reality_shift_charges") and self:GetLevel() > 0  then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_reality_shift_charges", {})
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------
function edgewalker_reality_shift:OnUpgrade()
	if self:GetCaster():HasItemInInventory("item_ultimate_scepter") or self:GetCaster():HasModifier("modifier_item_ultimate_scepter") then
		if not self:GetCaster():HasModifier("modifier_reality_shift_charges") and self:GetLevel() > 0 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_reality_shift_charges", {})
		end
	end
end
--------------------------------------------------------------------------------------------------------
function edgewalker_reality_shift:OnSpellStart()
	local hCaster = self:GetCaster()
	local fWardLifetime = self:GetSpecialValueFor("ward_duration")
	CreateModifierThinker(hCaster, self, "modifier_reality_shift_spawn_ward", { duration = fWardLifetime }, self:GetCursorPosition(), hCaster:GetTeamNumber(), false)

	if hCaster:HasModifier("modifier_reality_shift_charges") then
		local hChargesMod = hCaster:FindModifierByName("modifier_reality_shift_charges")
		if hChargesMod:GetStackCount() > 0 then
			self:EndCooldown()
		end
	end
end
--------------------------------------------------------------------------------------------------------