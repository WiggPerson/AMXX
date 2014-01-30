<?php 

$apikey = $_GET["key"]; 
$steamid_steam = $_GET["steamid"];
$steamid = ConvertID($_GET["steamid"]); 
$info = $_GET["request_info"];
$url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .$apikey. "&steamids=" .$steamid. "&format=xml"; 

$xml = @simplexml_load_file($url) or die($errorMsg); 

$szSteamID = $xml->players->player->steamid;

if($szSteamID) {
    $szName = $xml->players->player->personaname;
    $szProfileURL = $xml->players->player->profileurl;

    $result = "steam"."#".$szName."#".$steamid_steam."#".$steamid."#".$szProfileURL;
    echo "lamboon".$result;
} else {
    echo "lamboon"."nonsteam";
}



?> 

<?php 

function ConvertID($steamId) { 
    $iServer = "0"; 
    $iAuthID = "0"; 
      
    $szTmp = strtok($steamId, ":"); 
      
    while(($szTmp = strtok(":")) !== false) 
    { 
        $szTmp2 = strtok(":"); 
        if($szTmp2 !== false) 
        { 
            $iServer = $szTmp; 
            $iAuthID = $szTmp2; 
        } 
    } 
    if($iAuthID == "0") 
        return "0"; 
  
    $steamId64 = bcmul($iAuthID, "2"); 
    $steamId64 = bcadd($steamId64, bcadd("76561197960265728", $iServer));  
      
    return $steamId64; 
} 

?>