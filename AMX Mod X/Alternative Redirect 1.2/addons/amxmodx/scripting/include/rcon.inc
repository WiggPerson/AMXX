#if !defined _engine_included
	#include <engine>
#endif

#if !defined _socket_included
	#include <sockets>
#endif

/*
	GoldSRC RCON Query include		     v. 0.1
	by serfreeman1337		http://gf.hldm.org/
*/

/*
	rcon_send(p[],port,szPass[],szCommand[],szForward[],Float:timeout)
	
	forward <my fwd>(iRconStatus,szResult[])
*/

enum _:RconReturn{
	RCON_CONNECTION_FAILED = -4,
	RCON_GET_CHALLENGE_FAILED,
	RCON_CREATE_FWD_FAIL,
	RCON_TIMEOUT,
	RCON_OK
}

enum _:RconSt{
	RCON_FAIL = -2,
	RCON_GET_CHALLENGE,
	RCON_IDLE
}

enum RconDataArray{
	RconSocket = 0,
	RconCommand[128],
	RconPassword[32],
	RconChallenge[16],
	RconForward,
	RconEntity,
	RconPlugin,
	RconStatus
}

const Float:RETRIVE_INTERVAL = 0.01

stock RconData[RconDataArray]
stock Float:RconTimeoutTime
stock Float:RconTimeout

stock rcon_send(ip[],port,szPass[],szCommand[],szForward[],Float:timeout = 5.0){
	new iErr
	
	if(!RconData[RconSocket])
		RconData[RconSocket] = socket_open(ip,port,SOCKET_UDP,iErr)
	
	if(iErr>0)
		return RCON_CONNECTION_FAILED
	
	RconData[RconStatus] = RCON_GET_CHALLENGE
	
	new send[256]
	
	formatex(send,255,"%c%c%c%cchallenge rcon",0xFF,0xFF,0xFF,0xFF)
	socket_send(RconData[RconSocket],send,strlen(send))
	
	formatex(RconData[RconPassword],31,szPass)
	formatex(RconData[RconCommand],127,szCommand)
	
	if(!is_valid_ent(RconData[RconEntity])){
		RconData[RconEntity] = create_entity("info_target")
		entity_set_string(RconData[RconEntity],EV_SZ_classname,"rcon_think")
		entity_set_float(RconData[RconEntity],EV_FL_nextthink,get_gametime() + RETRIVE_INTERVAL)
		
		register_think("rcon_think","_Rcon_Think")
	}else{
		entity_set_float(RconData[RconEntity],EV_FL_nextthink,get_gametime() + RETRIVE_INTERVAL)
	}
	
	RconTimeoutTime = timeout
	RconTimeout = get_gametime() + timeout
	
	if(!RconData[RconPlugin]){
		new plFile[64],plNull[1]
		get_plugin(-1,plFile,63,plNull,0,plNull,0,plNull,0,plNull,0)
		
		RconData[RconPlugin] = find_plugin_byfile(plFile,0)
	}
	
	if(!RconData[RconForward]){
		RconData[RconForward] = CreateOneForward(RconData[RconPlugin],szForward,FP_CELL,FP_STRING)
		
		if(RconData[RconForward]<0)
			return RCON_CREATE_FWD_FAIL
	}
	
	
	RconTimeout = get_gametime() + RconTimeoutTime
	
	return RCON_OK
}

public _Rcon_Disconnect(){
	entity_set_float(RconData[RconEntity],EV_FL_nextthink,999999.0)
	
	if(RconData[RconPlugin])
		RconData[RconPlugin] = 0
	
	if(RconData[RconForward]){
		DestroyForward(RconData[RconForward])
		RconData[RconForward] = 0
	}
	
	RconData[RconStatus] = 0
	RconData[RconChallenge][0] = 0
	RconData[RconPassword][0] = 0
	
	if(RconData[RconSocket]){
		socket_close(RconData[RconSocket])
		RconData[RconSocket] = 0
	}
}

public _Rcon_Think(){
	if(RconData[RconStatus] == RCON_FAIL){
		_Rcon_Disconnect()
		
		return
	}
	
	new data[512]
	
	if(socket_change(RconData[RconSocket],1000)){
		socket_recv(RconData[RconSocket],data,511)
		
		if(strlen(data)){
			entity_set_float(RconData[RconEntity],EV_FL_nextthink,999999.0)
		}else{
			entity_set_float(RconData[RconEntity],EV_FL_nextthink,get_gametime() + RETRIVE_INTERVAL)
		}
	}else{
		entity_set_float(RconData[RconEntity],EV_FL_nextthink,get_gametime() + RETRIVE_INTERVAL)
	}
	
	if(strlen(data)>0){
		new none[1],ret
		
		switch(RconData[RconStatus]){
			case RCON_GET_CHALLENGE:{
				parse(data,none,0,none,0,RconData[RconChallenge],10)
				
				if(strlen(RconData[RconChallenge])>0){
					RconData[RconStatus] = RCON_IDLE

					formatex(data,511,"%c%c%c%crcon %s ^"%s^" %s",0xFF,0xFF,0xFF,0xFF,RconData[RconChallenge],RconData[RconPassword],RconData[RconCommand])
					socket_send(RconData[RconSocket],data,strlen(data))
	
					entity_set_float(RconData[RconEntity],EV_FL_nextthink,get_gametime() + RETRIVE_INTERVAL)
					
				}else{
					RconData[RconStatus] = RCON_FAIL
					
					ExecuteForward(RconData[RconForward],none[0],RCON_GET_CHALLENGE_FAILED,RconData[RconChallenge])
				}
			}
			case RCON_IDLE:{
				if(strlen(data) || (strlen(data) - 1)){
					// remove ^n
					data[strlen(data)-1] = 0
				}
		
				// 0,1,2 - NULL
				// 3,4 - WTF?
				formatex(data,511,data[5]) // remove l
				
				ExecuteForward(RconData[RconForward],ret,RCON_OK,data)
				
				_Rcon_Disconnect()
			}
		}
	}
	
	if(get_gametime() > RconTimeout && RconData[RconStatus] != RCON_FAIL){
		new sda[12],ret
		formatex(sda,11,"%.2f",get_gametime())
		
		RconData[RconStatus] = RCON_FAIL
		
		ExecuteForward(RconData[RconForward],ret,RCON_TIMEOUT,sda)
		
		entity_set_float(RconData[RconEntity],EV_FL_nextthink,get_gametime() + RETRIVE_INTERVAL)
	}

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
