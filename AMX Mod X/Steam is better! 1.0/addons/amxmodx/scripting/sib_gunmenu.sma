/*
 * SIB - Steam is better!
 * Subplugin: Gun Menu
 */

#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <cstrike>
#include <sib>

#define PLUGIN "SIB: Gun Menu"
#define VERSION "1.1" // Build 20141101
#define AUTHOR "WiggPerson" // Kontakt: wiggperson@gmail.com

new g_iHasGun[33];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Spawn,"player","PlayerSpawned",1);
	register_clcmd("say /gun","OpenGunMenu");
	register_clcmd("say_team /gun","OpenGunMenu");
}

public OpenGunMenu(id) {
	new Menu = menu_create("\rSIB Gun Menu","PlayerSelectedGun");
	
	menu_additem(Menu,"M4 + Deagle + Grenats");
	menu_additem(Menu,"AK47 + Deagle + Grenats");
	menu_additem(Menu,"AWP + Deagle + Grenats");
	
	menu_display(id,Menu);
}

public PlayerSpawned(id) {
	g_iHasGun[id] = 0;
	OpenGunMenu(id);
}

public PlayerSelectedGun(id,menu,item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return 1;
	}
	
	if(sib_is_steam(id)) {
		if(g_iHasGun[id] == 0) {
			switch(item) {
				case 0: {
					give_item(id,"weapon_m4a1");
					give_item(id,"weapon_deagle");
					give_item(id,"weapon_hegrenade");
					give_item(id,"weapon_flashbang");
					give_item(id,"weapon_smokegrenade");
					
					cs_set_user_bpammo(id,CSW_M4A1,120);
					cs_set_user_bpammo(id,CSW_DEAGLE,80);
					
					color_chat(id,"!g[SIB Gun Menu]!y Selected: M4 + DEAGLE + GRENATAS. GL & HF!");
					
				}
				case 1: {
					give_item(id,"weapon_ak47");
					give_item(id,"weapon_deagle");
					give_item(id,"weapon_hegrenade");
					give_item(id,"weapon_flashbang");
					give_item(id,"weapon_smokegrenade");
					
					cs_set_user_bpammo(id,CSW_AK47,120);
					cs_set_user_bpammo(id,CSW_DEAGLE,80);
					
					color_chat(id,"!g[SIB Gun Menu]!y Selected: AK47 + DEAGLE + GRENATAS. GL & HF!");
					
				}			
				case 2: {
					give_item(id,"weapon_awp");
					give_item(id,"weapon_deagle");
					give_item(id,"weapon_hegrenade");
					give_item(id,"weapon_flashbang");
					give_item(id,"weapon_smokegrenade");
					
					cs_set_user_bpammo(id,CSW_AWP,120);
					cs_set_user_bpammo(id,CSW_DEAGLE,80);

					color_chat(id,"!g[SIB Gun Menu]!y Selected: AWP + DEAGLE + GRENATAS. GL & HF!");
				}			
			}
			
			g_iHasGun[id] = 1;
		
		} else {
			color_chat(id,"!g[SIB Gun Menu]!y You have already selected guns in this round!");
		}
	} else {
		color_chat(id,"!g[SIB Gun Menu]!y You cannot select guns 'cause you are !gNonsteam!y client!");
	}
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
