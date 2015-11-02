if edgewalker_gravity_well == nil then edgewalker_gravity_well = class({}) end
--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_gravity_well", "heroes/hero_edgewalker/modifier_gravity_well", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
function edgewalker_gravity_well:GetIntrinsicModifierName()	return "modifier_gravity_well" end
--------------------------------------------------------------------------------------------------------