
_G.DEBUG_DRAW = true


if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end
--------------------------------------------------------------------------------------------------------
require("util")
require("libraries.vector_target")
require("lua_modifiers")

--------------------------------------------------------------------------------------------------------
function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	VectorTarget:Precache( context )

	-- edgewalker particles
	PrecacheResource( "particle_folder", "particles/heroes/hero_edgewalker", context )
	PrecacheUnitByNameSync("npc_edgewalker_portal",  context)
	PrecacheUnitByNameSync("npc_reality_shift_ward",  context)
	
	-- placeholders
	PrecacheResource( "particle_folder", "particles/items_fx", context )
	PrecacheResource( "particle_folder", "particles/status_fx", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_bane", context )
end
--------------------------------------------------------------------------------------------------------
-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end
--------------------------------------------------------------------------------------------------------
function CAddonTemplateGameMode:InitGameMode()	

	VectorTarget:Init()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end
--------------------------------------------------------------------------------------------------------
-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
--------------------------------------------------------------------------------------------------------