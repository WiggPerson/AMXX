/*
	Copyright (C) 2014 WiggPerson

	"LICENCIA BEERWARE" (Preloûil a upravil WiggPerson):
	
	WiggPerson napÌsal tento s˙bor. Pokiaæ s˙hlasÌte s touto licenciou, 
	mÙûete si s t˝mto s˙borom robiù, Ëo chcete. 
	Ak ma niekedy stretnete a budete si myslieù, ûe t· vec za to stojÌ, 
	mÙûete mi na opl·tku k˙più pivo. S pozdravom, WiggPerson.
	
	
	
*/

#include "amxmodx.inc"

/*
	Store victim's attackers and they damage
	g_aPlayerAttacker[Victim][Attacker] = Damage;

*/

new g_aPlayerAttackers[33][33];

/*
	Called when plugin inits
	void plugin_init();

*/

public plugin_init() {
	
	// Plugin registring ...
	
	register_plugin("I killed him too!", "1.0a", "WiggPerson");

	// Events registring ...
	
	register_event("Damage","onDamage","b","2!0","3=0","4!0");
	register_event("HLTV","onRound","b","1=0","2=0");
	register_event("DeathMsg","onDeath","a");
}

/*
	Called when attacker hurt victim
	void onDamage(iVictim);
	
	int iVictim = victim
*/

public onDamage(iVictim) {
	
	// Getting attacker and victim's damage
	static iAttacker; iAttacker = get_user_attacker(iVictim);
	static iDamage; iDamage = read_data(2);
	
	// Inserting into variable damage datas
	
	if(is_user_connected(iAttacker) && iAttacker != 0) {
		if(g_aPlayerAttackers[iVictim][iAttacker] == 0) 
			g_aPlayerAttackers[iVictim][iAttacker] = iDamage;		
		else 
			g_aPlayerAttackers[iVictim][iAttacker] += iDamage;
	}
}

/*
	Called when a new round inits
	void onRound(iPlayer);
	
	int iPlayer = Player
*/

public onRound(iPlayer) {

	// Nulling iPlayers taked damage
	
	new i;
	for(i = 0; i < 33; ++i)
		g_aPlayerAttackers[iPlayer][i] = 0;	
}

/*
	Called when someone kill someone 
	void onRound(iPlayer);
	
	int iPlayer = Player
*/

public onDeath() {
	new iAttacker = read_data(1);
	new iVictim = read_data(2);
	
	if(is_user_connected(iAttacker) && iAttacker != 0) {
		new szAttackersOldName[32], i, szAttackers[128];
		get_user_name(iAttacker, szAttackersOldName, sizeof(szAttackersOldName) - 1);
			
		client_print(0,print_chat,"Your old name: %s", szAttackersOldName);
		
		new count;
		for(i = 0; i < 33; ++i) {
			if(g_aPlayerAttackers[iVictim][i] == 0) continue;
			
			new nvm[32]; count++;
			get_user_name(i, nvm, 31);
			
			client_print(0,print_chat,"Killed by else: %s Damage: %d", nvm, g_aPlayerAttackers[iVictim][i]);
	
		}
		
		if(count == 1) {		
			client_print(0,print_chat,"Yourself: %s",szAttackersOldName);
		} else if(count > 1) {
			g_aPlayerAttackers[iVictim][iAttacker] = 0;
			
			new iFirst, iFirstDamage;
			for(i = 0; i < 33; ++i) {
				if(g_aPlayerAttackers[iVictim][i] == 0) continue;
				
				if(g_aPlayerAttackers[iVictim][i] > iFirstDamage) {
					iFirst = i;
					iFirstDamage = g_aPlayerAttackers[iVictim][i];
				}
			}
			
			new szFirstName[64];
			get_user_name(iFirst,szFirstName,63);
			
			formatex(szAttackers,127,"Dual: %s and %s",szAttackersOldName,szFirstName);
			
			client_print(0,print_chat,"%s",szAttackers);
		}		
	}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
