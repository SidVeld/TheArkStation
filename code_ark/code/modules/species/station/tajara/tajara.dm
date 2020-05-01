#define CULTURE_TAJARAN				"CMA Citizen"

#define FACTION_TAJARAN_HADII		"Hadii Family"
#define FACTION_TAJARAN_KAYTAM		"Kaytam Family"
#define FACTION_TAJARAN_NAZKIIN		"Nazkiin Family"
#define FACTION_TAJARAN_KAYTAM_KSD	"Khan-Shanu'Dar clan"
#define FACTION_TAJARAN_SHISHI		"Shi-Shi Family"
#define FACTION_TAJARAN_JAR			"Jar'Nash'Karr'Ree Family"
#define FACTION_TAJARAN_OTHER		"Other Family"

#define HOME_SYSTEM_AHDOMAI			"Ahdomai"

#include "language.dm"

#include "cultures_tajara.dm"
#include "factions_tajara.dm"
#include "locations_tajara.dm"
#include "religion_tajara.dm"
#include "accessory_tajara.dm"
#include "glasses_xeno_veil.dm"

/datum/species/tajara
	name = SPECIES_TAJARA
	name_plural = SPECIES_TAJARA

	icobase = 'code_ark/code/modules/species/station/tajara/sprites/body.dmi'
	deform =  'code_ark/code/modules/species/station/tajara/sprites/deformed_body.dmi'
	preview_icon = 'code_ark/code/modules/species/station/tajara/sprites/preview.dmi'
	tail = "tajtail"
	tail_animation = 'code_ark/code/modules/species/station/tajara/sprites_cloth/tail.dmi'
	default_h_style = "Tajaran Ears"

	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite/sharp)

	darksight_range = 7
	darksight_tint = DARKTINT_GOOD
	slowdown = -0.5
	brute_mod = 1.15
	burn_mod =  1.15
	flash_mod = 1.5
	hunger_factor = DEFAULT_HUNGER_FACTOR * 1.5

	gluttonous = GLUT_TINY
	hidden_from_codex = FALSE
	health_hud_intensity = 1.75

	min_age = 19
	max_age = 140 //good medicine?

	description = "The Tajaran are a species of furred mammalian bipeds hailing from the chilly planet of Ahdomai \
	in the Zamsiin-lr system. They are a naturally superstitious species, with the new generations growing up with tales \
	of the heroic struggles of their forebears against the Overseers. This spirit has led them forward to the \
	reconstruction and advancement of their society to what they are today. Their pride for the struggles they \
	went through is heavily tied to their spiritual beliefs. Recent discoveries have jumpstarted the progression \
	of highly advanced cybernetic technology, causing a culture shock within Tajaran society."

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80  //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	heat_discomfort_level = 292
	heat_discomfort_strings = list(
		"Your fur prickles in the heat.",
		"You feel uncomfortably warm.",
		"Your overheated skin itches."
		)
	cold_discomfort_level = 230

	primitive_form = "Farwa"

	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED
	appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_SKIN_COLOR | HAS_EYE_COLOR

	flesh_color = "#afa59e"
	base_color = "#333333"
	blood_color = "#862a51"
	organs_icon = 'code_ark/code/modules/species/station/tajara/sprites/organs.dmi'
	reagent_tag = IS_TAJARA

	move_trail = /obj/effect/decal/cleanable/blood/tracks/paw

	sexybits_location = BP_GROIN

	available_cultural_info = list(
		TAG_CULTURE =   list(
			CULTURE_TAJARAN,
			CULTURE_HUMAN,
			CULTURE_HUMAN_MARTIAN,
			CULTURE_HUMAN_MARSTUN,
			CULTURE_HUMAN_LUNAPOOR,
			CULTURE_HUMAN_LUNARICH,
			CULTURE_HUMAN_VENUSIAN,
			CULTURE_HUMAN_VENUSLOW,
			CULTURE_HUMAN_BELTER,
			CULTURE_HUMAN_PLUTO,
			CULTURE_HUMAN_EARTH,
			CULTURE_HUMAN_CETI,
			CULTURE_HUMAN_SPACER,
			CULTURE_HUMAN_SPAFRO,
			CULTURE_HUMAN_OTHER
		),
		TAG_HOMEWORLD = list(
			HOME_SYSTEM_AHDOMAI,
			HOME_SYSTEM_EARTH,
			HOME_SYSTEM_LUNA,
			HOME_SYSTEM_MARS,
			HOME_SYSTEM_VENUS,
			HOME_SYSTEM_CERES,
			HOME_SYSTEM_PLUTO,
			HOME_SYSTEM_TAU_CETI,
			HOME_SYSTEM_HELIOS,
			HOME_SYSTEM_TERSTEN,
			HOME_SYSTEM_LORRIMAN,
			HOME_SYSTEM_CINU,
			HOME_SYSTEM_YUKLID,
			HOME_SYSTEM_LORDANIA,
			HOME_SYSTEM_KINGSTON,
		)
	)

/*
/datum/species/tajaran/equip_survival_gear(var/mob/living/carbon/human/H)
	..()
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H),slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/tajblind(H),slot_glasses)
*/