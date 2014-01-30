/*
 * SIB - Steam is better!
 * Plugin API INC
 */

#if defined _sib_included
  #endinput
#endif
#define _sib_included

#pragma reqlib "sib"

/* Returns true if client is steam player */

native sib_is_steam(id);

/* Returns client's steam profile name into array */

native sib_get_name(id,array[32]);

/* Returns client's steam id into array */

native sib_get_steamid(id,array[32]);

/* Returns client's converted steam id into array */

native sib_get_converted_steamid(id,array[32]);

/* Returns client's steam profile url into array */

native sib_get_profile_url(id,array[128]);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
