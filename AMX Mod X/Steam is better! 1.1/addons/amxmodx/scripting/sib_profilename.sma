/*
 * SIB - Steam is better!
 * Subplugin: Profile Name
 */

#include <amxmodx>
#include <sib>

#define PLUGIN "SIB: Profile Name"
#define VERSION "1.0" // Build 20141101
#define AUTHOR "WiggPerson" // Kontakt: wiggperson@gmail.com

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

}

public client_putinserver(id) {
	if(sib_is_steam(id)) {
		new szName[32];
		sib_get_name(id,szName);
		
		set_user_info(id,"name",szName);
	}
}