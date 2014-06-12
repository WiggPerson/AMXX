#include <amxmodx>
#include <fakemeta>
#include <orpheu>

#define PLUGIN "Go home hackers!"
#define VERSION "1.0"
#define AUTHOR "WiggPerson, vlad"

new id, i;
new ip[25], hostname[33];
new final[64];

native cs_get_user_deaths(index); // Nepotrebujeme cely cstrike priclenit

public plugin_init() {
    register_plugin(PLUGIN,VERSION,AUTHOR);
    OrpheuRegisterHook(OrpheuGetFunction("Host_Status_f"), "onStatus", OrpheuHookPre);

    get_user_ip(0, ip, 24, 0); // Ziska ip server
    get_cvar_string("hostname", hostname, 32); // Ziska meno servera
    
    formatex(final, 63, "Server: %s (%s)", hostname, ip);
}

public OrpheuHookReturn:onStatus() {
    id = engfunc(EngFunc_GetCurrentPlayer) + 1;

    
    console_print(id, "%s^nHraci online:", final)
    for(i = 0; i < 32; i++) {
        if(is_user_connected(i)) {
            static name[33];
            get_user_name(i, name, 32);
            console_print(id, "#%d %s (Frags: %d Deaths: %d)", get_user_userid(i), name, get_user_frags(i), cs_get_user_deaths(i));
        
        }
    }
    
    //console_print(id, "Z bezbecnostnich dovodov tento prikaz bol upraveny.");
    
    return OrpheuSupercede; 
}
