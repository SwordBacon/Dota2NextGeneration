function Guard_Table(keys)
keys.caster.Guard_Reflected_units = {}
end

function Guard_Reflect(keys)
local caster = keys.caster
local attacker = keys.attacker
local damageTaken = keys.DamageTaken
local atkDamage = caster:GetAttackDamage()
local ability = keys.ability

if not caster.Guard_Reflected_units[ attacker:entindex() ] and not attacker:IsMagicImmune() then
		attacker:SetHealth( attacker:GetHealth() - atkDamage )
		keys.ability:ApplyDataDrivenModifier( caster, attacker, "modifier_guard_reflected", { } )
		caster:SetHealth( caster:GetHealth() + damageTaken )
		caster.Guard_Reflected_units[ attacker:entindex() ] = attacker
	end
end
