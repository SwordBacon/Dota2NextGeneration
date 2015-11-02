if modifier_cascade_event_portal_tooltip == nil then modifier_cascade_event_portal_tooltip = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal_tooltip:IsPurgeable() return false end
--------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal_tooltip:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
--------------------------------------------------------------------------------------------------------
function modifier_cascade_event_portal_tooltip:GetTexture() return "wisp_relocate" end