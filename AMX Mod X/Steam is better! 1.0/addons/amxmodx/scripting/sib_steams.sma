/*
 * SIB - Steam is better!
 * Subplugin: Steams
 */

#include <amxmodx>
#include <sib>

#define PLUGIN "SIB: Steams"
#define VERSION "1.1" // Build 20141101
#define AUTHOR "WiggPerson" // Kontakt: wiggperson@gmail.com

new i;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /steams","PrintAllSteamClients");
	register_clcmd("say_team /steams","PrintAllSteamClients");
}
public PrintAllSteamClients(id) {
	new szMessage[193], Players[32], iNum,iSteamNum, szName[32], szAdd[36];
	formatex(szMessage,charsmax(szMessage),"!g[SIB Steams]!y Steam clients: ");
	
	get_players(Players,iNum)
	for(i = 0; i < iNum; i++) {
		if(sib_is_steam(Players[i])) {
			iSteamNum++;
			
			get_user_name(Players[i],szName,charsmax(szName));
			
			if(iSteamNum == 1) {
				
				formatex(szAdd,charsmax(szAdd),"%s",szName)
				
				add(szMessage,charsmax(szMessage),szAdd);
			} else {
				formatex(szAdd,charsmax(szAdd),", %s",szName)
				
				add(szMessage,charsmax(szMessage),szAdd);
			}
		}	
	}
	
	color_chat(id,szMessage);
	
	return 1;
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
