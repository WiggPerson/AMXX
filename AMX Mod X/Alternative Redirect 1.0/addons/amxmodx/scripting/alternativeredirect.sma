/* Alternatívny Redirect Plugin */

#include <amxmodx>
#include <dhudmessage>

#define PLUGIN "Alternativny Redirect Plugin" // Náhrada za xRedirect
#define VERSION "1.0" // Build 2013121
#define AUTHOR "WiggPerson" // Kontakt: WiggPerson@gmail.com

new const g_szPluginTag[] = "[ARP]";
new const g_szFileName[] = "servers.ini";

new g_szConfigDir[128];
new g_szFilePath[128];

new Array:g_aServers;

enum _:g_mServerINFO {
	m_szServerNAME[32],
	m_szServerIP[32],
	m_szServerPORT[32]
};

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("say /servers","OpenServerMenu");
	register_clcmd("say /server","OpenServerMenu");
	register_clcmd("say /servery","OpenServerMenu");
	
	g_aServers = ArrayCreate(g_mServerINFO);
	
	get_customdir(g_szConfigDir,charsmax(g_szConfigDir));
	
	formatex(g_szFilePath,charsmax(g_szFilePath),"%s/%s",g_szConfigDir,g_szFileName);
	
	new File = fopen(g_szFilePath,"a+");
	
	new szLine[128], szServerNAME[32], szServerIP[32], szServerPORT[32];
	
	while (fgets(File,szLine,charsmax(szLine))) {
		new aNewServer[g_mServerINFO];	
		parse(szLine,szServerNAME,charsmax(szServerNAME),szServerIP,charsmax(szServerIP),szServerPORT,charsmax(szServerPORT));
		
		formatex(aNewServer[m_szServerNAME],31,szServerNAME);
		formatex(aNewServer[m_szServerIP],31,szServerIP);
		formatex(aNewServer[m_szServerPORT],31,szServerPORT);
		
		ArrayPushArray(g_aServers,aNewServer);
		
		server_print("%s Registrovanie serveru %s s IP: %s a PORTOM: %s",g_szPluginTag,szServerNAME,szServerIP,szServerPORT);
	}

	fclose(File);
	
}

public OpenServerMenu(id) {
	new menu = menu_create("\y[ARP] Presmerovanie","ServerMenuDirecter");

	for (new i = 0; i < ArraySize(g_aServers); ++i) {
		new aServer[g_mServerINFO],szMenuText[128];
		
		ArrayGetArray(g_aServers,i,aServer);
		
		formatex(szMenuText,charsmax(szMenuText),"\w%s^n\dIP: %s PORT: %s",aServer[m_szServerNAME],aServer[m_szServerIP],aServer[m_szServerPORT]);
		
		menu_additem(menu,szMenuText);
	}
	
	menu_display(id,menu);
}

public ServerMenuDirecter(id,menu,item) {
	if (item == MENU_EXIT) return;
	
	new aServer[g_mServerINFO], szCommand[128];
	
	ArrayGetArray(g_aServers,item,aServer);
	
	formatex(szCommand,charsmax(szCommand),"echo ^"Pre potvrdenie stlac ENTER^";messagemode ^"Connect %s:%s^"",aServer[m_szServerIP],aServer[m_szServerPORT]);
	
	client_cmd(id,szCommand);
	
	set_dhudmessage(0, 255, 0, -1.0, -1.0, 0, 6.0, 5.0, 0.1, 0.1);
	show_dhudmessage(id,"Pre potvrdenie stlac ENTER");
	
	return;
}

/* Stock z AMX Misc 1.8.2 */

stock get_customdir(name[],len)
{
	return get_localinfo("amxx_configsdir",name,len);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
