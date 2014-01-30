/* Alternatívny Redirect Plugin */

#include <amxmodx>
#include <rcon>

#define PLUGIN "Alternative Redirect Plugin" // Náhrada za xRedirect
#define VERSION "1.2" // Build 20140201
#define AUTHOR "WiggPerson" // Kontakt: WiggPerson@gmail.com

new const g_szPluginTag[] = "[ARP]";
new const g_szFileName[] = "servers.ini";

enum _:g_mServerINFO {
	m_szServerNAME[32],
	m_szServerIP[32],
	m_szServerPORT[32],
	m_szServerRCON[32]
};

enum _:g_mServerDATA {
	m_szPlayersNum[8],
	m_szMaxPlayersNum[8],
	m_szMapName[32]
	
}

new g_szConfigDir[128];
new g_szFilePath[128];
new g_aServerData[g_mServerDATA];

new Array:g_aServers;


public plugin_init() {
        
	register_plugin(PLUGIN, VERSION, AUTHOR);
        
	register_clcmd("say /servers","OpenServerMenu");
	register_clcmd("say /server","OpenServerMenu");
	register_clcmd("say /servery","OpenServerMenu");
	
	register_concmd("arp_getdata","RconSendData",ADMIN_RCON);
	
	g_aServers = ArrayCreate(g_mServerINFO);
        
	get_customdir(g_szConfigDir,charsmax(g_szConfigDir));
        
	formatex(g_szFilePath,charsmax(g_szFilePath),"%s/%s",g_szConfigDir,g_szFileName);
	
	if(file_exists(g_szFilePath)) {
		new File = fopen(g_szFilePath,"a+");
		
		new szLine[128], szServerNAME[32], szServerIP[32], szServerPORT[32], szServerRCON[32];
		
		while (fgets(File,szLine,charsmax(szLine))) {
			new aNewServer[g_mServerINFO];        
			parse(szLine,szServerNAME,charsmax(szServerNAME),szServerIP,charsmax(szServerIP),szServerPORT,charsmax(szServerPORT),szServerRCON,charsmax(szServerRCON));
			
			formatex(aNewServer[m_szServerNAME],31,szServerNAME);
			formatex(aNewServer[m_szServerIP],31,szServerIP);
			formatex(aNewServer[m_szServerPORT],31,szServerPORT);
			formatex(aNewServer[m_szServerRCON],31,szServerRCON);
			
			ArrayPushArray(g_aServers,aNewServer);
			server_print("%s Registrating server %s with IP: %s and PORT: %s!",g_szPluginTag,szServerNAME,szServerIP,szServerPORT);
		}
		fclose(File);
	} else {
		new File = fopen(g_szFilePath,"a+");
		server_print("%s Plugin ready to configure! Edit the %s File.",g_szPluginTag,g_szFileName);
		fclose(File);
	}
}

public RconSendData() {
	new szMapName[32];
	get_mapname(szMapName,charsmax(szMapName));
	
	server_print("%d#%d#%s",get_playersnum(),get_maxplayers(),szMapName)
}

public RconGetData(iStatus,szResult[]) {
	if(iStatus == RCON_OK) {
		new szData[48];
		formatex(szData,charsmax(szData),"%s",szResult);
		
		replace_all(szData,charsmax(szData),"#"," ");
		new pszPlayersNum[8],pszMaxPlayersNum[8],pszMapName[32];
		
		parse(szData,pszPlayersNum,charsmax(pszPlayersNum),pszMaxPlayersNum,charsmax(pszMaxPlayersNum),pszMapName,charsmax(pszMapName));
		
		formatex(g_aServerData[m_szPlayersNum],charsmax(g_aServerData[m_szPlayersNum]),"%s",pszPlayersNum);
		formatex(g_aServerData[m_szMaxPlayersNum],charsmax(g_aServerData[m_szMaxPlayersNum]),"%s",pszMaxPlayersNum);
		formatex(g_aServerData[m_szMapName],charsmax(g_aServerData[m_szMapName]),"%s",pszMapName);
	} else {
		server_print("%s Failed to get data from remote server.",g_szPluginTag);
	}
}

public OpenServerMenu(id) {
	
	new menu = menu_create("\y[ARP] Presmerovanie","ServerMenuDirecter");

	for (new i = 0; i < ArraySize(g_aServers); ++i) {
		new aServer[g_mServerINFO],szMenuText[128];
                
		ArrayGetArray(g_aServers,i,aServer);
		
		new iPort = str_to_num(aServer[m_szServerIP]);
		rcon_send(aServer[m_szServerIP],iPort,aServer[m_szServerRCON],"arp_getdata","RconGetData",10.0)
		
		formatex(szMenuText,charsmax(szMenuText),"\w%s^n\dIP: %s PORT: %s^n%s/%s %s",aServer[m_szServerNAME],aServer[m_szServerIP],aServer[m_szServerPORT],g_aServerData[m_szPlayersNum],g_aServerData[m_szMaxPlayersNum],g_aServerData[m_szMapName]);
                
		menu_additem(menu,szMenuText);
	}
        
	menu_display(id,menu);
}

public ServerMenuDirecter(id,menu,item) {
	if (item == MENU_EXIT) return;
        
	new aServer[g_mServerINFO], szCommand[128];
        
	ArrayGetArray(g_aServers,item,aServer);
        
	// Specialné podakovanie za tento FIXBUG patri Belo95135, dakujem :)
	formatex(szCommand,charsmax(szCommand),"^"reconnect^";^"Connect^" %s:%s",aServer[m_szServerIP],aServer[m_szServerPORT]);
        
	client_cmd(id,szCommand);
        
	return;
}

/* Stock z AMX Misc 1.8.2 */

stock get_customdir(name[],len)
{
	return get_localinfo("amxx_configsdir",name,len);
}
