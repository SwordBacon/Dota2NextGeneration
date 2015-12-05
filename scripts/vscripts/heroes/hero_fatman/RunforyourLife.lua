function Speedboost (keys)

	local caster = keys.caster
	local ability = keys.ability
	local modifier_name = "Speedboost"
	local dur = ability:GetDuration() 
	local attacker = keys.attacker
	local modifier = caster:FindModifierByName(modifier_name)
	local count = caster:GetModifierStackCount(modifier_name, caster)
	if attacker:IsHero() then
		if not modifier then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration = dur})
			caster:SetModifierStackCount(modifier_name, caster, 1)
		else
			caster:SetModifierStackCount(modifier_name, caster, count+1)
			modifier:SetDuration(dur, true)
		end
	end
end

function Decrease (keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_name = "Speedboost"
	local modifier = caster:FindModifierByName(modifier_name)
	local count = caster:GetModifierStackCount(modifier_name, caster)

	if modifier then
		if count and count > 1 then
            caster:SetModifierStackCount(modifier_name, caster, count-1)
        else
            caster:RemoveModifierByName(modifier_name)
        end
    end
end

function refresh (keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_name = "Speedboost"
	local modifier = caster:FindModifierByName(modifier_name)
	local count = caster:GetModifierStackCount(modifier_name, caster)		
           
    caster:SetModifierStackCount(modifier_name, caster, 0)
    caster:SetModifierStackCount(modifier_name, caster, count)
end