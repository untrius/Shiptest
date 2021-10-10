#define TECHNOPHILE_MINIMUM_SACRIFICE_CHARGE 3000
#define TECHNOPHILE_CHARGE_PER_FAVOR 500

/**
  * # Religious Sects
  *
  * Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.
  *
  * Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  * The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  *
  */
/datum/religion_sect
/// Name of the religious sect
	var/name = "Religious Sect Base Type"
/// Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
/// Opening message when someone gets converted
	var/convert_opener
/// holder for alignments.
	var/alignment = ALIGNMENT_GOOD
/// Does this require something before being available as an option?
	var/starter = TRUE
/// The Sect's 'Mana'
	var/favor = 0 //MANA!
/// The max amount of favor the sect can have
	var/max_favor = 1000
/// The default value for an item that can be sacrificed
	var/default_item_favor = 5
/// Turns into 'desired_items_typecache', lists the types that can be sacrificed barring optional features in can_sacrifice()
	var/list/desired_items
/// Autopopulated by `desired_items`
	var/list/desired_items_typecache
/// Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/list/rites_list
/// Changes the Altar of Gods icon
	var/altar_icon
/// Changes the Altar of Gods icon_state
	var/altar_icon_state


/datum/religion_sect/New()
	if(desired_items)
		desired_items_typecache = typecacheof(desired_items)
	if(rites_list)
		var/listylist = generate_rites_list()
		rites_list = listylist
	on_select()


///Generates a list of rites with 'name' = 'type'
/datum/religion_sect/proc/generate_rites_list()
	. = list()
	for(var/rite_unchecked_type in rites_list)
		if(!ispath(rite_unchecked_type))
			continue
		var/datum/religion_rites/rite = rite_unchecked_type
		var/name_entry = "[initial(rite.name)]"
		if(initial(rite.desc))
			name_entry += " - [initial(rite.desc)]"
		if(initial(rite.favor_cost))
			name_entry += " ([initial(rite.favor_cost)] favor)"
		// ~if

		. += list("[name_entry]" = rite)
	// ~for


/// Activates once selected
/datum/religion_sect/proc/on_select()


/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/acolyte)
	to_chat(acolyte, "<span class='notice'>[convert_opener]</span")


/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering.
/datum/religion_sect/proc/can_sacrifice(obj/item/sacrifice_item, mob/living/acolyte)
	. = TRUE
	if(!is_type_in_typecache(sacrifice_item, desired_items_typecache))
		return FALSE


/// Activates when the sect sacrifices an item. Can provide additional benefits to the sacrificer, which can also be dependent on their holy role! If the item is suppose to be eaten, here is where to do it. NOTE INHER WILL NOT DELETE ITEM FOR YOU!!!!
/datum/religion_sect/proc/on_sacrifice(obj/item/sacrifice_item, mob/living/acolyte)
	return adjust_favor(default_item_favor, acolyte)


/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/acolyte)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if(favor + amount > max_favor)
		. = (max_favor-favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = clamp(0, max_favor, favor + amount)


/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/acolyte)
	favor = clamp(0,max_favor,amount)
	return favor


/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user, obj/structure/altar_of_gods/AOG)


/// Replaces the bible's bless mechanic. Return TRUE if you want to not do the brain hit.
/datum/religion_sect/proc/sect_bless(mob/living/target_unchecked_type, mob/living/user)
	if(!ishuman(target_unchecked_type))
		return FALSE
	var/mob/living/carbon/human/target = target_unchecked_type
	for(var/body_part_untyped in target.bodyparts)
		var/obj/item/bodypart/body_part = body_part_untyped
		if(body_part.status == BODYPART_ROBOTIC)
			to_chat(user, "<span class='warning'>[GLOB.deity] refuses to heal this metallic taint!</span>")
			return TRUE
		// ~if
	// ~for

	var/heal_amt = 10
	var/list/hurt_limbs = target.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/hurt_limb_untyped in hurt_limbs)
			var/obj/item/bodypart/hurt_limb = hurt_limb_untyped
			if(hurt_limb.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				target.update_damage_overlays()
			// ~if
		// ~for
		target.visible_message("<span class='notice'>[user] heals [target] with the power of [GLOB.deity]!</span>")
		to_chat(target, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be healed!</span>")
		playsound(user, "punch", 25, TRUE, -1)
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	// ~if
	return TRUE
// ~sect_bless()


/**
  * # Puritain Sect
  *
  * Default religious sect
  *
  * Inhierits majority of behaviors from parent
  *
  */
/datum/religion_sect/puritanism
	name = "Puritanism (Default)"
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"


/**
  * # Technophile Sect
  *
  * Machine-oriented religious sect
  *
  * Heals robotic limbs instead of organic
  * Sacrifices power cell for favor preportional to the cell's charge
  * Trades large amount of favor to transform an organic into a synthetic
  *
  */
/datum/religion_sect/technophile
	name = "Technophile"
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte.<br>Bibles now recharge cyborgs and heal robotic limbs if targeted, but they do not heal organic limbs. You can now sacrifice cells, with favor depending on their charge."
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/cell)
	rites_list = list(/datum/religion_rites/synthconversion)
	altar_icon_state = "convertaltar-blue"


/datum/religion_sect/technophile/sect_bless(mob/living/target_unchecked_type, mob/living/user)
	if(iscyborg(target_unchecked_type))
		var/mob/living/silicon/robot/target_robot = target_unchecked_type
		var/charge_amt = 50
		if(target_unchecked_type.mind?.holy_role == HOLY_ROLE_HIGHPRIEST)
			charge_amt *= 2
		target_robot.cell?.charge += charge_amt
		target_robot.visible_message("<span class='notice'>[user] charges [target_robot] with the power of [GLOB.deity]!</span>")
		to_chat(target_robot, "<span class='boldnotice'>You are charged by the power of [GLOB.deity]!</span>")
		SEND_SIGNAL(target_robot, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
		return TRUE
	if(!ishuman(target_unchecked_type))
		return
	var/mob/living/carbon/human/target_human = target_unchecked_type

	//first we determine if we can charge them
	var/did_we_charge = FALSE
	var/obj/item/organ/stomach/ethereal/eth_stomach = target_human.getorganslot(ORGAN_SLOT_STOMACH)
	if(istype(eth_stomach))
		eth_stomach.adjust_charge(3 * ETHEREAL_CHARGE_SCALING_MULTIPLIER)    //WS Edit -- Ethereal Charge Scaling
		did_we_charge = TRUE

	//if we're not targetting a robot part we stop early
	var/obj/item/bodypart/body_part = target_human.get_bodypart(user.zone_selected)
	if(body_part.status != BODYPART_ROBOTIC)
		if(!did_we_charge)
			to_chat(user, "<span class='warning'>[GLOB.deity] scoffs at the idea of healing such fleshy matter!</span>")
		else
			target_human.visible_message("<span class='notice'>[user] charges [target_human] with the power of [GLOB.deity]!</span>")
			to_chat(target_human, "<span class='boldnotice'>You feel charged by the power of [GLOB.deity]!</span>")
			SEND_SIGNAL(target_human, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
			playsound(user, 'sound/machines/synth_yes.ogg', 25, TRUE, -1)
		return TRUE

	//charge(?) and go
	if(body_part.heal_damage(5,5,null,BODYPART_ROBOTIC))
		target_human.update_damage_overlays()

	target_human.visible_message("<span class='notice'>[user] [did_we_charge ? "repairs" : "repairs and charges"] [target_human] with the power of [GLOB.deity]!</span>")
	to_chat(target_human, "<span class='boldnotice'>The inner machinations of [GLOB.deity] [did_we_charge ? "repairs" : "repairs and charges"] you!</span>")
	playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
	SEND_SIGNAL(target_human, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE
// ~sect_bless()


/datum/religion_sect/technophile/can_sacrifice(obj/item/sacrifice_item, mob/living/acolyte)
	if(!..())
		return FALSE
	var/obj/item/stock_parts/cell/the_cell = sacrifice_item
	if(the_cell.charge < TECHNOPHILE_MINIMUM_SACRIFICE_CHARGE)   // stops people from grabbing cells out of APCs
		to_chat(acolyte, "<span class='notice'>[GLOB.deity] does not accept pity amounts of power.</span>")
		return FALSE
	return TRUE


/datum/religion_sect/technophile/on_sacrifice(obj/item/sacrifice_item, mob/living/acolyte)
	if(!is_type_in_typecache(sacrifice_item, desired_items_typecache))
		return
	var/obj/item/stock_parts/cell/the_cell = sacrifice_item
	adjust_favor(round(the_cell.charge / TECHNOPHILE_CHARGE_PER_FAVOR), acolyte)
	to_chat(acolyte, "<span class='notice'>You offer [the_cell]'s power to [GLOB.deity], pleasing them.</span>")
	qdel(sacrifice_item)


/**
  * # Clockwork Sect
  *
  * Brass-oriented religious sect
  *
  * Loosely associated with Ratvar
  * Does not mention Ratvar by name, so the Chaplain can still select thier religion and diety
  *
  * Sacrifices metal for favor preportional to amount
  * Trades small amount of favor to create brass
  *
  */
/datum/religion_sect/clockwork
	name = "Clockwork"
	desc = "A sect oriented around gears and brass."
	convert_opener = "Build for his honor, acolyte.<br>Bibles now teach the tongue of the Clockwork Justiciar. You can now sacrifice metal for favor."
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stack/sheet/metal)
	rites_list = list(/datum/religion_rites/transmute_brass)
	altar_icon_state = "convertaltar-red"


/datum/religion_sect/clockwork/on_conversion(mob/living/acolyte)
	..()
	acolyte.grant_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_MIND)
	to_chat(acolyte, "<span class='boldnotice'>The words of [GLOB.deity] fill your head!</span>")


/datum/religion_sect/clockwork/sect_bless(mob/living/target, mob/living/user)
	if(!target.has_language(/datum/language/ratvar, TRUE))
		target.grant_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_MIND)
		target.visible_message("<span class='notice'>[user] enlightens [target] with the power of [GLOB.deity]!</span>")
		to_chat(target, "<span class='boldnotice'>The words of [GLOB.deity] fill your head!</span>")

	target.visible_message("<span class='notice'>[user] blesses [target] with the power of [GLOB.deity]!</span>")
	playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
	SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE


/datum/religion_sect/clockwork/on_sacrifice(obj/item/sacrifice_item, mob/living/acolyte)
	if(!is_type_in_typecache(sacrifice_item, desired_items_typecache))
		return
	var/obj/item/stack/sheet/sheets = sacrifice_item
	adjust_favor(sheets.amount, acolyte)
	to_chat(acolyte, "<span class='notice'>You offer [sheets] to [GLOB.deity], pleasing them.</span>")
	qdel(sacrifice_item)


#undef TECHNOPHILE_MINIMUM_SACRIFICE_CHARGE
#undef TECHNOPHILE_CHARGE_PER_FAVOR
