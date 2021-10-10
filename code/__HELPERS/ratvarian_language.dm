// Regexes used to alter english to ratvarian style
#define RATVAR_OF_MATCH regex("(\\w)\\s(\[oO]\[fF])","g")
#define RATVAR_OF_REPLACEMENT "$1-$2"
#define RATVAR_GUA_MATCH regex("(\[gG]\[uU])(\[aA])","g")
#define RATVAR_GUA_REPLACEMENT "$1-$2"
#define RATVAR_TH_MATCH regex("(\[tT]\[hH]\\w)(\\w)","g")
#define RATVAR_TH_REPLACEMENT "$1`$2"
#define RATVAR_TI_MATCH regex("(\[tT]\[iI])(\\w)","g")
#define RATVAR_TI_REPLACEMENT "$1`$2"
#define RATVAR_ET_MATCH regex("(\\w)(\[eE]\[tT])","g")
#define RATVAR_ET_REPLACEMENT "$1-$2"
#define RATVAR_TE_MATCH regex("(\[tT]\[eE])(\\w)","g")
#define RATVAR_TE_REPLACEMENT "$1-$2"
#define RATVAR_PRE_AND_MATCH regex("(\\w)\\s(\[aA]\[nN]\[dD])(\\W)","g")
#define RATVAR_PRE_AND_REPLACEMENT "$1-$2$3"
#define RATVAR_POST_AND_MATCH regex("(\\W)(\[aA]\[nN]\[dD])\\s(\\w)","g")
#define RATVAR_POST_AND_REPLACEMENT "$1$2-$3"
#define RATVAR_TO_MATCH regex("(\\s)(\[tT]\[oO])\\s(\\w)","g")
#define RATVAR_TO_REPLACEMENT "$1$2-$3"
#define RATVAR_MY_MATCH regex("(\\s)(\[mM]\[yY])\\s(\\w)","g")
#define RATVAR_MY_REPLACEMENT "$1$2-$3"


// Regexes used to remove ratvarian styling from english
#define REVERSE_RATVAR_HYPHEN_PRE_AND_MATCH regex("(\\w)-(\[aA]\[nN]\[dD])","g") //specifically structured to support -emphasis-, including with -and-
#define REVERSE_RATVAR_HYPHEN_PRE_AND_REPLACEMENT "$1 $2"
#define REVERSE_RATVAR_HYPHEN_POST_AND_MATCH regex("(\[aA]\[nN]\[dD])-(\\w)","g")
#define REVERSE_RATVAR_HYPHEN_POST_AND_REPLACEMENT "$1 $2"
#define REVERSE_RATVAR_HYPHEN_TO_MY_MATCH regex("(\[tTmM]\[oOyY])-","g")
#define REVERSE_RATVAR_HYPHEN_TO_MY_REPLACEMENT "$1 "
#define REVERSE_RATVAR_HYPHEN_TE_MATCH regex("(\[tT]\[eE])-","g")
#define REVERSE_RATVAR_HYPHEN_TE_REPLACEMENT "$1"
#define REVERSE_RATVAR_HYPHEN_ET_MATCH regex("-(\[eE]\[tT])","g")
#define REVERSE_RATVAR_HYPHEN_ET_REPLACEMENT "$1"
#define REVERSE_RATVAR_HYPHEN_GUA_MATCH regex("(\[gG]\[uU])-(\[aA])","g")
#define REVERSE_RATVAR_HYPHEN_GUA_REPLACEMENT "$1$2"
#define REVERSE_RATVAR_HYPHEN_OF_MATCH regex("-(\[oO]\[fF])","g")
#define REVERSE_RATVAR_HYPHEN_OF_REPLACEMENT " $1"


/// Takes english and applies ratvarian styling rules (and rot13) to it.
/proc/text2ratvar(text)
	var/ratvarian = add_ratvarian_regex(text) //run the regexes twice, so that you catch people translating it beforehand
	ratvarian = rot13(ratvarian)
	return add_ratvarian_regex(ratvarian)


/// Runs regexes used to alter english to ratvarian style.
/proc/add_ratvarian_regex(text)
	var/ratvarian 	= replacetext(text, 		RATVAR_OF_MATCH, 		RATVAR_OF_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian,	RATVAR_GUA_MATCH, 		RATVAR_GUA_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian,	RATVAR_TH_MATCH, 		RATVAR_TH_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian,	RATVAR_TI_MATCH, 		RATVAR_TI_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_ET_MATCH, 		RATVAR_ET_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_TE_MATCH, 		RATVAR_TE_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_PRE_AND_MATCH,	RATVAR_PRE_AND_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_POST_AND_MATCH,	RATVAR_POST_AND_REPLACEMENT)
	ratvarian 		= replacetext(ratvarian, 	RATVAR_TO_MATCH, 		RATVAR_TO_REPLACEMENT)
	return replacetext(ratvarian, 				RATVAR_MY_MATCH, 		RATVAR_MY_REPLACEMENT)


/// Reverts ravarian styling and rot13 in text.
/proc/ratvar2text(ratvarian)
	var/text = remove_ratvarian_regex(ratvarian) //run the regexes twice, so that you catch people translating it beforehand
	text = replacetext(rot13(text), "`", "")
	return remove_ratvarian_regex(text)


/// Runs regexes used to remove ratvarian styling from english.
/proc/remove_ratvarian_regex(ratvarian)
	var/text 	= replacetext(ratvarian, 	REVERSE_RATVAR_HYPHEN_GUA_MATCH,		REVERSE_RATVAR_HYPHEN_GUA_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_PRE_AND_MATCH,	REVERSE_RATVAR_HYPHEN_PRE_AND_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_POST_AND_MATCH,	REVERSE_RATVAR_HYPHEN_POST_AND_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_TO_MY_MATCH,		REVERSE_RATVAR_HYPHEN_TO_MY_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_TE_MATCH,			REVERSE_RATVAR_HYPHEN_TE_REPLACEMENT)
	text 		= replacetext(text, 		REVERSE_RATVAR_HYPHEN_ET_MATCH,			REVERSE_RATVAR_HYPHEN_ET_REPLACEMENT)
	return replacetext(text, 				REVERSE_RATVAR_HYPHEN_OF_MATCH,			REVERSE_RATVAR_HYPHEN_OF_REPLACEMENT)
