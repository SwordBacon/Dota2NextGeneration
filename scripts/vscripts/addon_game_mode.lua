if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end
--------------------------------------------------------------------------------------------------------
require("util")
require("libraries.timers")
require("libraries.vector_target")
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
	PrecacheResource( "particle_folder", "particles/heroes/hero_edgewalker", context )
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