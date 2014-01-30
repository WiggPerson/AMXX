/*
 * SIB - Steam is better!
 * Subplugin: Steam Info
 */

#include <amxmodx>
#include <sib>

#define PLUGIN "SIB: Connect Info"
#define VERSION "1.1" // Build 20141101
#define AUTHOR "WiggPerson" // Kontakt: wiggperson@gmail.com

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("amx_steam","PlayerSendInfo",ADMIN_ALL,"amx_steam <playername>");
}

public PlayerSendInfo(id) {
	new szPlayerName[32], szMessage[193];
	read_argv(1,szPlayerName,charsmax(szPlayerName));
	
	client_print(id,print_console,"[SIB Steam Info] Searching for %s ...",szPlayerName);
	
	new iTarget = find_player("a",szPlayerName);
	if(iTarget) {
		if(sib_is_steam(id)) {
			new szSteamName[32], szGameName[32], szSteamID[32], szConvertedSteamID[32], szProfileURL[128];
			
			sib_get_name(id,szSteamName);
			sib_get_steamid(id,szSteamID);
			sib_get_converted_steamid(id,szConvertedSteamID);
			sib_get_profile_url(id,szProfileURL);
			
			get_user_name(id,szGameName,charsmax(szGameName));
			
			
			formatex(szMessage,charsmax(szMessage),"[SIB Steam Info] Client was found! User Steam Infos:");
			client_print(id,print_console,szMessage);
			client_print(id,print_console,"[SIB Steam Info] Profile Name: %s",szSteamName);
			client_print(id,print_console,"[SIB Steam Info] IN-Game Name: %s",szGameName);
			client_print(id,print_console,"[SIB Steam Info] SteamID: %s",szSteamID);
			client_print(id,print_console,"[SIB Steam Info] Converted SteamID: %s",szConvertedSteamID);
			client_print(id,print_console,"[SIB Steam Info] Steam Profile URL: %s",szProfileURL);
			
			
			return 1;
		
		} else {
			formatex(szMessage,charsmax(szMessage),"[SIB Steam Info] Client is Nonsteam player!")
			client_print(id,print_console,szMessage);
			
			return 1;
		}
	} else {
			formatex(szMessage,charsmax(szMessage),"[SIB Steam Info] Client was not found.")
			client_print(id,print_console,szMessage);
			
			return 1;		
	}
	
	return 1;
}
