/*
* SIB - Steam is better!
* Plugin Core
*/

#include <amxmodx>
#include <sockets>

#define PLUGIN "SIB: Core"
#define VERSION "1.1" // Build 20141101
#define AUTHOR "WiggPerson" // Kontakt: wiggperson@gmail.com

#define TASK_ID_ANSWER 1921
#define TASK_ID_KILL 9192

new const g_szPluginTag[] = "[SIB]";
new const g_szFileName[] = "steam_api.cfg";

enum g_mSteamApiINFO {
	m_iServerHOST,	
	m_iServerFILE,
	m_iServerAPIKEY
}
enum g_mCvarsINFO {
	m_iCvarName,
	m_iCvarValue
}

enum _:g_mPlayerINFO {
	m_szIsSteam[16],
	
	m_szName[32],
	m_szSteamID[32],
	m_szConvertedSteamID[32],
	m_szProfileURL[128],
}

new const g_szCvars[][][] = {
	{ "amx_steamapi_host" , "localhost" },
	{ "amx_steamapi_file" , "steam_api.php" },
	{ "amx_steamapi_apikey" , "" }
};

new g_szConfigDir[128];
new g_szFilePath[128];
new g_szData[256];
new g_szSteamInfo[256]
new g_szPlayerData[33][g_mPlayerINFO];
new g_Socket;
new i;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	get_customdir(g_szConfigDir,charsmax(g_szConfigDir));
	
	formatex(g_szFilePath,charsmax(g_szFilePath),"%s/%s",g_szConfigDir,g_szFileName);
	
	if(file_exists(g_szFilePath)) {
		new File = fopen(g_szFilePath,"a+");
		
		new szLine[128], szCvarName[64], szCvarValue[64];
		
		while(fgets(File,szLine,charsmax(szLine))) {
			parse(szLine,szCvarName,charsmax(szCvarName),szCvarValue,charsmax(szCvarValue));
			register_cvar(szCvarName,szCvarValue);
			
			server_print("%s Registrating cvar ^"%s^" with value ^"%s^".",g_szPluginTag,szCvarName,szCvarValue);
		}
		fclose(File);
		
		} else {
		new File = fopen(g_szFilePath,"a+");
		
		new szPutLine[64];
		
		for(i = 0; i < sizeof(g_szCvars); i++) {
			formatex(szPutLine,charsmax(szPutLine),"^"%s^" ^"%s^"^n",g_szCvars[i][m_iCvarName],g_szCvars[i][m_iCvarValue]);
			
			fputs(File,szPutLine);
		}
		
		server_print("%s Plugin ready to configure! Edit the %s file.",g_szPluginTag,g_szFileName);
		
		fclose(File);
		
	}
	
}

public client_authorized(id) {
	SocketSendRequest(id);
}

public plugin_natives() {
	register_library("sib");
	
	register_native("sib_is_steam","_sib_is_steam");
	register_native("sib_get_name","_sib_get_name");
	register_native("sib_get_steamid","_sib_get_steamid");
	register_native("sib_get_converted_steamid","_sib_get_converted_steamid");
	register_native("sib_get_profile_url","_sib_get_profile_url");
}

public _sib_is_steam(iPlugin,iParams) {
	new id = get_param(1);
	
	if(equali(g_szPlayerData[id][m_szIsSteam],"steam")) {
		return 1;
	}
	
	return 0;
}

public _sib_get_name(iPlugin,iParams) {
	new id = get_param(1);
	
	set_string(2,g_szPlayerData[id][m_szName],31);
}

public _sib_get_steamid(iPlugin,iParams) {
	new id = get_param(1);
	
	set_string(2,g_szPlayerData[id][m_szSteamID],31);
}

public _sib_get_converted_steamid(iPlugin,iParams) {
	new id = get_param(1);
	
	set_string(2,g_szPlayerData[id][m_szConvertedSteamID],31);
}

public _sib_get_profile_url(iPlugin,iParams) {
	new id = get_param(1);
	
	set_string(2,g_szPlayerData[id][m_szProfileURL],127);
}

public SocketSendRequest(id) {
	new iError
	new szHOST[32], szFILE[32], szAPIKEY[64];
	
	get_cvar_string(g_szCvars[m_iServerHOST][m_iCvarName],szHOST,charsmax(szHOST));
	get_cvar_string(g_szCvars[m_iServerFILE][m_iCvarName],szFILE,charsmax(szFILE));
	get_cvar_string(g_szCvars[m_iServerAPIKEY][m_iCvarName],szAPIKEY,charsmax(szAPIKEY));
	
	g_Socket = socket_open(szHOST, 80, SOCKET_TCP, iError);
	
	switch (iError)
	{
		case 1:
		{
			server_print("%s Unable to create socket.",g_szPluginTag);
			return 0;
		}
		case 2:
		{
			server_print("%s Unable to connect to host.",g_szPluginTag);
			return 0;
		}
		case 3:
		{
			server_print("%s Unable to connect to the HTTP port.",g_szPluginTag);
			return 0;
		}
	}	
	
	new szSteamID[64];
	get_user_authid(id,szSteamID,charsmax(szSteamID));
	
	new szMessage[1024];
	formatex(szMessage,charsmax(szMessage),"/%s?key=%s&steamid=%s",szFILE,szAPIKEY,szSteamID);
	
	new szMessageBuffer[1024];
	formatex(szMessageBuffer,charsmax(szMessageBuffer),"GET %s HTTP/1.1^nHost:%s^r^n^r^n",szMessage, szHOST);
	
	socket_send(g_Socket,szMessageBuffer,charsmax(szMessageBuffer));
	
	set_task(0.1, "SocketWaitForAnswer", TASK_ID_ANSWER + id, "", 0, "a", 150) 
	set_task(16.0, "SocketCloseConnection", TASK_ID_KILL + id, "", 0, "", 0)
	
	return 1;
	
}

public SocketWaitForAnswer(iTask) {
	new id = iTask - TASK_ID_ANSWER;
	
	if(socket_change(g_Socket)) {
		socket_recv(g_Socket,g_szData,charsmax(g_szData));
		
		new szDummy[256]
		split(g_szData, szDummy, charsmax(szDummy), g_szSteamInfo, charsmax(g_szSteamInfo), "lamboon")		
		
		new p_szIsSteam[16], p_szName[32], p_szSteamID[32], p_szConvertedSteamID[32], p_szProfileURL[128];
		
		replace_all(g_szSteamInfo,charsmax(g_szSteamInfo),"#"," ");
		parse(g_szSteamInfo,p_szIsSteam,charsmax(p_szIsSteam),p_szName,charsmax(p_szName),p_szSteamID,charsmax(p_szSteamID),p_szConvertedSteamID,charsmax(p_szConvertedSteamID),p_szProfileURL,charsmax(p_szProfileURL));
		
		formatex(g_szPlayerData[id][m_szIsSteam],15,p_szIsSteam);
		formatex(g_szPlayerData[id][m_szName],31,p_szName);
		formatex(g_szPlayerData[id][m_szSteamID],31,p_szSteamID);
		formatex(g_szPlayerData[id][m_szConvertedSteamID],31,p_szConvertedSteamID);
		formatex(g_szPlayerData[id][m_szProfileURL],127,p_szProfileURL);
		
		
		socket_close(g_Socket);
		remove_task(TASK_ID_KILL + id);
		
	}
}

public SocketCloseConnection(iTask) {
	socket_close(g_Socket);
}

/* Stock from AMX Misc 1.8.2 */

stock get_customdir(name[],len)
{
	return get_localinfo("amxx_configsdir",name,len);
}
