/*
 * SIB - Steam is better!
 * Subplugin: Connect info
 */

#include <amxmodx>
#include <sib>

#define PLUGIN "SIB: Connect Info"
#define VERSION "1.1" // Build 20141101
#define AUTHOR "WiggPerson" // Kontakt: wiggperson@gmail.com


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public client_putinserver(id) {
	new szMessage[193], szName[32], szSteam[16], szSteamID[32];
	get_user_name(id,szName,charsmax(szName));
	get_user_authid(id,szSteamID,charsmax(szSteamID));
	
	if(sib_is_steam(id)) {
		formatex(szSteam,charsmax(szSteam),"Steam");		
		formatex(szMessage,charsmax(szMessage),"!g[SIB Connect Info]!y Pripojil sa k nam !g%s!y hrac !team%s!y (SteamID: !g%s!y)",szSteam,szName,szSteamID);
		color_chat(0,szMessage);
	} else {
		formatex(szSteam,charsmax(szSteam),"Nonsteam");
		formatex(szMessage,charsmax(szMessage),"!g[SIB Connect Info]!y Pripojil sa k nam !g%s!y hrac !team%s!y (SteamID: !g%s!y)",szSteam,szName,szSteamID);
		color_chat(0,szMessage);
	}
}

/* Stock from http://amxmodx.cz/viewtopic.php?f=38&t=451 */

stock color_chat(id, const input[], any:...)
{
	new count = 1, players[32], msgid
	static msg[191]
	msgid = get_user_msgid("SayText")
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4") // Green Color
	replace_all(msg, 190, "!y", "^1") // Default Color
	replace_all(msg, 190, "!team", "^3") // Team Color

	
	if (id) players[0] = id; else get_players(players, count, "c")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
			message_begin(MSG_ONE_UNRELIABLE, msgid, _, players[i])  
			write_byte(players[i]);
			write_string(msg);
			message_end();
			}
		}
	}
}
