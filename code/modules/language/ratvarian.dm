/**
  * # The Ratvarian Language
  *
  * In the lore of the Servants of Ratvar, the Ratvarian tongue is a timeless language and full of power. It sounds like gibberish, much like Nar'Sie's language, but is in fact derived from
  * aforementioned language.
  *
  * While the canon states that the language of Ratvar and his servants is incomprehensible to the unenlightened as it is a derivative of the most ancient known language, in reality it is
  * actually very simple. To translate a plain English sentence to Ratvar's tongue, simply move all of the letters thirteen places ahead, starting from "a" if the end of the alphabet is reached.
  * This cipher is known as "rot13" for "rotate 13 places" and there are many sites online that allow instant translation between English and rot13 - one of the benefits is that moving the translated
  * sentence thirteen places ahead changes it right back to plain English.
  *
  * There are, however, a few parts of the Ratvarian tongue that aren't typical and are implemented for fluff reasons. Some words may have graves, or hyphens (prefix and postfix), making the plain
  * English translation apparent but disjoined (for instance, "Orubyq zl-cbjre!" translates directly to "Behold my-power!") although this can be ignored without impacting overall quality. When
  * translating from Ratvar's tongue to plain English, simply remove the disjointments and use the finished sentence. This would make "Orubyq zl-cbjre!" into "Behold my power!" after removing the
  * abnormal spacing, hyphens, and grave accents.
  *
  * List of nuances:
  * - Any time the WORD "of" occurs, it is linked to the previous word by a hyphen. (i.e. "V nz-bs Ratvar." directly translates to "I am-of Ratvar.")
  * - Any time "th", followed by any two letters occurs, you add a grave (`) between those two letters, i.e; "Thi`s"
  * - In the same vein, any time "ti", followed by one letter occurs, you add a grave (`) between "i" and the letter, i.e; "Ti`me"
  * - Whereever "te" or "et" appear and there is another letter next to the e(i.e; "m"etal, greate"r"), add a hyphen between "e" and the letter, i.e; "M-etal", "Greate-r"
  * - Where "gua" appears, add a hyphen between "gu" and "a", i.e "Gu-ard"
  * - Where the WORD "and" appears it is linked to all surrounding words by hyphens, i.e; "Sword-and-shield"
  * - Where the WORD "to" appears, it is linked to the following word by a hyphen, i.e; "to-use"
  * - Where the WORD "my" appears, it is linked to the following word by a hyphen, i.e; "my-light"
  *
  */
/datum/language/ratvar
	name = "Ratvarian"
	desc = "A timeless language full of power and incomprehensible to the unenlightened."
	var/static/random_speech_verbs = list("clanks", "clinks", "clunks", "clangs")
	ask_verb = "requests"
	exclaim_verb = "proclaims"
	whisper_verb = "imparts"
	key = "R"
	flags = LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	default_priority = 10
	spans = list(SPAN_ROBOT)
	icon_state = "ratvar"

/datum/language/ratvar/scramble(var/input)
	. = text2ratvar(input)

/datum/language/ratvar/get_spoken_verb(msg_end)
	if(!msg_end)
		return pick(random_speech_verbs)
	return ..()
