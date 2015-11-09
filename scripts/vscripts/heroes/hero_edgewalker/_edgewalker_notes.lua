--[[

Notes:

Ability dependecies: VECTOR TARGET LIB by Kallisti
Precache: 
	VectorTarget:Precache( context )
	
	-- edgewalker particles
	PrecacheResource( "particle_folder", "particles/heroes/hero_edgewalker", context )
	PrecacheUnitByNameSync("npc_edgewalker_portal",  context)
	PrecacheUnitByNameSync("npc_reality_shift_ward",  context)
	
	-- placeholders
	PrecacheResource( "particle_folder", "particles/items_fx", context )
	PrecacheResource( "particle_folder", "particles/status_fx", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_bane", context )

1. Cascade Event: Need to know the range of "nearby" portals

2. Neutrino Strike:
	a. Neutrino dispersion damage is PURE. Can not be magical to avoid infinite loop. Though this problem exists only on attacks that has magic dmg (Ancient Apparition's E) since you can filter out ability damage to avoid the infinite loop. But better safe than sorry.

	b. Neutrino projectile does not support infinite loop (until max distance) between portals. Projectile only teleports once. To prevent crashes (projectile calculation overload when 3 or more portals are close to each other)

	c. Scrapped the AOE amplify target of neutrino strike. When testing, shit's OP AF, even more with the break mechanic. At the moment, it only amplifies the projectile hit target (with break ofc) and AOE dispersion if damaged by magic. Let me know if I have to change it back.

3. Gravity Well:
	a. Dependencies: Gravity Well activation code snippets are scattered in other spells. Portal hit test is fully inside the neutrino strike ability code. The former being "fixable" by overriding onprojectilehit/onspellstart functions of abilities and using setmodifiergainedfilter for portal oncreated and ondestroy events. The other is impossible, unless Valve pass the table in OnProjectileThink_ExtraData second param. I'd fix both if anyone can figure this out. 

	b. Gravity Well applies after Neutrino Strike Amplify Target buff so it	automatically triggers Dispersion Damage in AOE, which I believe is the intended result since this hero has no damage besides gravity well.

	c. Gravity Well center is at the location of projectile hit and not at the origin of the projectile target. Let me know if this is the intended result.

4. UI does not update on properties (movespeed, magic resist etc etc) and buff duration changes. Volvo pls.

5. Looking for sounds suggestion, not necessarily from the game. Details/Particulars are same as below.
	Need particles for:
	a. Neutrino strike orbs / projectile
	b. Cascade Event projectile
	c. Cascade Event portal, preferrably an continuosly emitting particle.
	d. Cascade Event projectile triggering portal particle
	e. Neutrino Strike amplify target debuff particle (obvious particle for break mechanic)
	f. Neutrino Strike Dispersion particle
	g. Gravity Well pull particle
	h. Reality Shift ward model suggestion/particles (explosion, root)



]]