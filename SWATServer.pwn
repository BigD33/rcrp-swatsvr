#include <a_samp>

#undef MAX_PLAYERS
#undef MAX_VEHICLES
#define MAX_PLAYERS (50)
#define MAX_VEHICLES (100)

#include <a_mysql>
#include <zcmd>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <EasyDialog>

#define             mysql_host          "127.0.0.1"
#define             mysql_user          "root"
#define             mysql_password      ""
#define             mysql_database      "swatserver"

#define             WHITE               0xFFFFFFFF
#define             GREY                0x808080FF
#define             LIGREY              0x808080C8
#define             BLUE                0x0073FFFF
#define             CYAN                0x32ffffff
#define             DARKCYAN            0x54ADCCff
#define             LIBLUE              0x009ffbFF
#define             GREEN               0x00E228FF
#define             LIGREEN             0x00FF28FF
#define             PINK                0xFFAFD7FF
#define             PURPLE              0xDB00AFFF
#define             YELLOW              0xF5FF00FF
#define             CHEESE              0xffff5fFF
#define             TRANSPARENT         0xFFFFFF00
#define             ORANGE              0xFF8000C8
#define             ORANGE2             0xdb6d06FF
#define             RED                 0xE60000FF
#define             DARKRED             0x964646FF
#define             ACTION              0xC2A2DAAA
#define             BLACK               0x00000000
#define             DARKGREEN           0x00aa00FF
#define             RADIOBROWN          0x967100FF

#define             MAX_INTERIORS           115
#define             MAX_TELEPORTS           115

#define AdminOnly   "You are not authorised to use this command."

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

main()
{
	print("\n----------------------------------");
	print("SWAT Server by BigD and t0mbXD :^)");
	print("----------------------------------\n");
}
native WP_Hash(buffer[], len, const str[]);

PreloadAnimLib(playerid, animlib[])
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);

new ConnectionHandle;
new szMessage[256];
new SWATDoor[7];
new szQuery[1024];
new DataTimer;
new playa[32];
new Float: specPosX[MAX_PLAYERS];
new Float: specPosY[MAX_PLAYERS];
new Float: specPosZ[MAX_PLAYERS];
new Anim_PlayerLooping[MAX_PLAYERS];
new Anim_ClearOut[MAX_PLAYERS];
new Anim_Animation[MAX_PLAYERS];
new swatgate1, swatOpen = 0, swatext;
new vehiclecount = 0;
new DoorStatus[7];
new passAtt[MAX_PLAYERS] = 0;
new PlayerAnimsLoaded[MAX_PLAYERS];
new aDuty[MAX_PLAYERS];
new RubberBullets[MAX_PLAYERS];
new GunShotWound[MAX_PLAYERS][7];
new gPlayerUsingLoopingAnim[MAX_PLAYERS];
new IsSpectating[MAX_PLAYERS];
new WhoSpectating[MAX_PLAYERS];

new AdminNames[][] =
{
	"Level 1", "Level 2", "Level 3", "Level 4"
};
new aWeaponNames[][] =
{
	{"Fist"}, {"Brass Knuckles"}, {"Golf Club"}, {"Nightstick"}, {"Knife"},
	{"Baseball Bat"}, {"Shovel"}, {"Pool Cue"}, {"Katana"}, {"Chainsaw"},
	{"Purple Dildo"}, {"Small White Vibrator"}, {"Big White Vibrator"},
	{"Small Silver Vibrator"}, {"Flowers"}, {"Cane"}, {"Grenade"}, {"Teargas"},
	{"Molotov Cocktail"}, {" "}, {" "}, {" "}, {"9mm"}, {"Silenced Pistol"},
	{"Desert Eagle"}, {"Shotgun"}, {"Sawn-off Shotgun"},
	{"Spas 12"}, {"Micro Uzi (Mac 10)"}, {"MP5"}, {"AK-47"}, {"M4"}, {"Tec9"},
	{"Country Rifle"},{"Sniper Rifle"}, {"Rocket Launcher (RPG)"},
	{"Heat-Seeking Rocket Launcher"},{"Flamethrower"}, {"Minigun"},
	{"Satchel Charges"}, {"Detonator"},{"Spray Can"}, {"Fire Extinguisher"},
	{"Camera"}, {"Night Vision Goggles"}, {"Thermal Goggles"},
	{"Parachute"}
};
new aVehicleNames[][] =
{
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
	"Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
	"Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
	"Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
	"Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
	"Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
	"Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
	"Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
	"Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
	"FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
	"Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
	"Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
	"Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
	"Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
	"Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
	"Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
	"Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
	"Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
	"Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Cruiser", "SFPD Cruiser", "LVPD Cruiser",
	"Police Ranger", "Picador", "S.W.A.T Van", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
	"Boxville", "Tiller", "Utility Trailer"
};

#define SendClientMessageF(%1,%2,%3) \
	SendClientMessage(%1, %2, (format(szMessage, sizeof(szMessage), %3), szMessage))

#define RCRP::%0(%1) forward %0(%1); public %0(%1)
enum pData
{
	AccID,
	Password[129],
	SkinID,
	AdminLevel,
	FirstLogin,
	LatestIP[16],
	AdminReg[24],
	AdmnIP[16],
};
enum iData
{
	ID,
	InteriorID,
	InteriorVW,
	ExteriorID,
	ExteriorVW,
	Float: iPos[3],
	Float: ePos[3],
	LabelText[128],
	Text3D: Label,
	PickupID,
	InteriorLoaded,
};
enum vData
{
	VehicleID,
	ModelID,
	ScriptID,
	Float: vPos[4],
	Colour1,
	Colour2,
	VehicleLoaded,
};
enum tData
{
	ID,
	Name[128],
	Float: tPos[3],
	TeleportLoaded,
};
new pVariables[MAX_PLAYERS][pData];
new iVariables[MAX_INTERIORS][iData];
new vVariables[MAX_VEHICLES][vData];
new tVariables[MAX_TELEPORTS][tData];

public OnGameModeInit()
{
	ConnectionHandle = mysql_connect(mysql_host,mysql_user,mysql_database,mysql_password);
	SetGameModeText("SWAT Server - 0.1");
	DisableInteriorEnterExits();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	
	mysql_tquery(ConnectionHandle, "SELECT * FROM interiors", "LoadInteriors", "i");
	mysql_tquery(ConnectionHandle, "SELECT * FROM vehicles", "LoadVehicles", "i");
	mysql_tquery(ConnectionHandle, "SELECT * FROM teleports", "LoadTeleports", "i");
	
	swatgate1 = CreateDynamicObject(976, -354.50000, 1732.00000, 41.80000,   0.00000, 0.00000, 90.00000);
	swatext = CreateObject(19353, -313.7413, 1774.9657, 45.2813,   0.00000, 0.00000, 38.52000);
	SetObjectMaterialText(swatext, "Special Weapons and Tactics", 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 20, 1, 0xFFFFFFFF, 0, OBJECT_MATERIAL_TEXT_ALIGN_CENTER);
	
	SWATDoor[0] = CreateDynamicObject(3089, -328.1891, 1781.1094, 999.4085, 0.0000, 0.0000, 0.0000);
	SWATDoor[1] = CreateDynamicObject(3089, -327.9846, 1791.4232, 999.4085, 0.0000, 0.0000, 90.0000);
	SWATDoor[2] = CreateDynamicObject(19303, -327.9943, 1787.4910, 999.5308, 0.0000, 0.0000, 90.0000);
	SWATDoor[3] = CreateDynamicObject(3089, -323.0453, 1793.3356, 999.4085, 0.0000, 0.0000, 0.0000);
	SWATDoor[4] = CreateDynamicObject(3089, -331.9164, 1799.4480, 999.4085, 0.0000, 0.0000, 0.0000);
	SWATDoor[5] = CreateDynamicObject(3089, -327.1169, 1799.4480, 999.4085,  0.0000, 0.0000, 0.0000);
	SWATDoor[6] = CreateDynamicObject(3089, -322.3239, 1799.4480, 999.4085, 0.0000, 0.0000, 0.0000);
	DataTimer = SetTimer("SaveData", 1000*60*30, true);
	return 1;
}

public OnGameModeExit()
{
	foreach(Player, i)
	{
		SavePlayerData(i);
	}
	SaveVehicles();
	SaveInteriors();
	mysql_close(ConnectionHandle);
	KillTimer(DataTimer);
	return 1;
}
stock LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
	Anim_PlayerLooping[playerid] = 1;
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
	Anim_Animation[playerid]++;
}
forward StopLoopingAnim(playerid);
public StopLoopingAnim(playerid)
{
	gPlayerUsingLoopingAnim[playerid] = 0;
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
}
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(issuerid != INVALID_PLAYER_ID)
	{
		new Float:Damage;
		new Float:health, Float:armour, Float: dist, Float:poz[3], dam;

		GetPlayerHealth(playerid,health);
		GetPlayerArmour(playerid,armour);
		GetPlayerPos(playerid, poz[0], poz[1], poz[2]);
		dist = GetPlayerDistanceFromPoint(issuerid, poz[0], poz[1], poz[2]);
		dam = floatround(dist);

		SetPVarInt(playerid, "dK", issuerid);
		SetPVarInt(playerid, "dR", weaponid);

		new newdamage = 0;

		switch(GetPlayerWeapon(issuerid)){
			case 0: { // Fist
				Damage = 7;
				newdamage = 1;
			}
			case 1,2,3,5,6,7: { // Misc Melee
				Damage = 18;
				newdamage = 1;
			}
			case 22: { //9mm
				Damage = 18;
				newdamage = 1;
			}

			case 24: { // Deagle
				Damage = 50;
				newdamage = 1;
			}
			case 25: { // Shotgun
				if(RubberBullets[issuerid] == 1)
				{
					GetPlayerHealth(playerid, health);
					SetPlayerHealth(playerid, health);
					GetPlayerArmour(playerid, armour);
					SetPlayerArmour(playerid, armour);

					new string[128];
					format(string, sizeof(string), "You hit %s with a rubberbullet.", pName(playerid));
					SendClientMessage(issuerid, WHITE, string);
					format(string, sizeof(string), "You were hit with a rubberbullet by %s", pName(issuerid));
					SendClientMessage(playerid, WHITE, string);
					format(string, sizeof(string), "* %s was hit by a rubberbullet, forcing him to the ground.", pName(playerid));
					CloseMessage(playerid, PURPLE, string);

					LoopingAnim(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 1);

					TogglePlayerControllable(playerid, 0);
					SetTimerEx("ClearAnims", 20*1000, false, "i", playerid);
				}
				else
				{
					Damage = 75 - (dam * 2);
					if(Damage <= 0) Damage = 2;
					newdamage = 1;
				}
			}
			case 27: {
				Damage = 25 - (dam * 2);
				if(Damage <= 0) Damage = 2; // SPAS 12
				newdamage = 1;
			}
			case 29: { // MP5
				Damage = 17;
				newdamage = 1;
			}
			case 31: { // M4
				Damage = 26;
				newdamage = 1;
			}
			case 30: { // AK
				Damage = 25;
				newdamage = 1;
			}
			case 33: {
				Damage = 65; //Country Rifle
				newdamage = 1;
			}
			case 34: { // Sniper
				Damage = 90;
				newdamage = 1;
			}
			case 28,32: {
				Damage = 17; //Uzi
				newdamage = 1;
			}
			case 8,4: {
				Damage = 30; //Katana / Knife
				newdamage = 1;
			}
		}

		switch(bodypart)
		{
			case 3: Damage = Damage - (Damage / 3.8);
			case 4: Damage = Damage - (Damage / 4.0);
			case 5: Damage = Damage - (Damage / 2.4);
			case 6: Damage = Damage - (Damage / 2.5);
			case 7: Damage = Damage - (Damage / 3.0);
			case 8: Damage = Damage - (Damage / 2.9);
		}
		GunShotWound[playerid][bodypart - 3] ++;
		if(newdamage == 1){
			if(armour == 0){
				health = health - Damage;
				if(health < 0){
					health = health - health;
				}
			}

			else{
				armour = armour - Damage;
				if(armour < 0){
					health = health + armour;
					armour = 0;
				}
			}
			SetPlayerHealth(playerid, health);
			SetPlayerArmour(playerid, armour);
		}
	}
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	GetPlayerIp(playerid, pVariables[playerid][LatestIP], 16);
	SavePlayerData(playerid);
	SetPlayerColor(playerid, WHITE);
	mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "SELECT * FROM `accounts` WHERE `Username` = '%s'", pName(playerid));
	mysql_tquery(ConnectionHandle, szQuery, "CheckAccount", "i", playerid);
	
	SendClientMessageF(playerid, YELLOW, "Welcome to the SWAT Training Server, {F5FF00}%s.", RemoveUnderScore(playerid));
	PlayerJoinMessage(playerid);
	
	if(!PlayerAnimsLoaded[playerid])
	{
		PreloadAnimLib(playerid,"BOMBER");
		PreloadAnimLib(playerid,"RAPPING");
		PreloadAnimLib(playerid,"SHOP");
		PreloadAnimLib(playerid,"BEACH");
		PreloadAnimLib(playerid,"SMOKING");
		PreloadAnimLib(playerid,"FOOD");
		PreloadAnimLib(playerid,"ON_LOOKERS");
		PreloadAnimLib(playerid,"DEALER");
		PreloadAnimLib(playerid,"MISC");
		PreloadAnimLib(playerid,"SWEET");
		PreloadAnimLib(playerid,"RIOT");
		PreloadAnimLib(playerid,"PED");
		PreloadAnimLib(playerid,"POLICE");
		PreloadAnimLib(playerid,"CRACK");
		PreloadAnimLib(playerid,"CARRY");
		PreloadAnimLib(playerid,"COP_AMBIENT");
		PreloadAnimLib(playerid,"PARK");
		PreloadAnimLib(playerid,"INT_HOUSE");
		PreloadAnimLib(playerid,"KNIFE");
		PreloadAnimLib(playerid,"BD_FIRE");
		PreloadAnimLib(playerid,"MISC");
		PreloadAnimLib(playerid,"RAPPING");
		PreloadAnimLib(playerid,"SHOP");
		PreloadAnimLib(playerid,"BLOWJOBZ");
		PreloadAnimLib(playerid,"PARK");
		PreloadAnimLib(playerid,"GYMNASIUM");
		PreloadAnimLib(playerid,"PAULNMAC");
		PreloadAnimLib(playerid,"CAR");
		PreloadAnimLib(playerid,"GANGS");
		PreloadAnimLib(playerid,"GHANDS");
		PreloadAnimLib(playerid,"MEDIC");
		PreloadAnimLib(playerid,"Attractors");
		PreloadAnimLib(playerid,"HEIST9");
		PlayerAnimsLoaded[playerid] = 1;
		TogglePlayerSpectating(playerid, false);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SavePlayerData(playerid);
	return 1;
}
RCRP::CreateVehicleEx(modelid, Float: vehx, Float: vehy, Float: vehz, Float: veha, colour1, colour2)
{
	new vehicle = GetNextVehicleID();
	
	vVariables[vehicle][VehicleID] = vehicle;
	vVariables[vehicle][ModelID] = modelid;
	vVariables[vehicle][vPos][0] = vehx;
	vVariables[vehicle][vPos][1] = vehy;
	vVariables[vehicle][vPos][2] = vehz;
	vVariables[vehicle][vPos][3] = veha;
	vVariables[vehicle][Colour1] = colour1;
	vVariables[vehicle][Colour2] = colour2;
	vVariables[vehicle][ScriptID] = CreateVehicle(vVariables[vehicle][ModelID], vVariables[vehicle][vPos][0], vVariables[vehicle][vPos][1], vVariables[vehicle][vPos][2], vVariables[vehicle][vPos][3], vVariables[vehicle][Colour1], vVariables[vehicle][Colour2], -1);
	
	vVariables[vehicle][VehicleLoaded] = 1;
	mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "INSERT INTO vehicles (ModelID, VehX, VehY, VehZ, VehA, Colour1, Colour2) VALUES ('%d', '%f', '%f', '%f', '%f', '%d', '%d')",
	vVariables[vehicle][ModelID],
	vVariables[vehicle][vPos][0],
	vVariables[vehicle][vPos][1],
	vVariables[vehicle][vPos][2],
	vVariables[vehicle][vPos][3],
	vVariables[vehicle][Colour1],
	vVariables[vehicle][Colour2]);
	mysql_tquery(ConnectionHandle, szQuery);
	return true;
}
RCRP::CreateInterior(playerid, interiorid, interiorvw, Float: interiorx, Float: interiory, Float: interiorz, name[])
{
	new Float: bPos[3];
	new interior = GetNextInteriorID();

	GetPlayerPos(playerid, bPos[0], bPos[1], bPos[2]);

	iVariables[interior][InteriorID] = interiorid;
	iVariables[interior][InteriorVW] = interiorvw;
	iVariables[interior][iPos][0] = interiorx;
	iVariables[interior][iPos][1] = interiory;
	iVariables[interior][iPos][2] = interiorz;
	iVariables[interior][ePos][0] = bPos[0];
	iVariables[interior][ePos][1] = bPos[1];
	iVariables[interior][ePos][2] = bPos[2];
	format(iVariables[interior][LabelText], 128, "%s", name);
	iVariables[interior][PickupID] = CreateDynamicPickup(1272, 23, iVariables[interior][ePos][0], iVariables[interior][ePos][1], iVariables[interior][ePos][2]+0.3, iVariables[interior][ExteriorVW], iVariables[interior][ExteriorID], -1, 50);
	iVariables[interior][Label] = CreateDynamic3DTextLabel(iVariables[interior][LabelText], YELLOW, iVariables[interior][ePos][0], iVariables[interior][ePos][1], iVariables[interior][ePos][2]+0.8, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, iVariables[interior][ExteriorVW], iVariables[interior][ExteriorID], -1, 15);

	iVariables[interior][InteriorLoaded] = 1;
	mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "INSERT INTO interiors (InteriorID, InteriorVW, ExteriorID, ExteriorVW, iPosX, iPosY, iPosZ, ePosX, ePosY, ePosZ, LabelText) VALUES ('%d', '%d', '0', '0', '%f', '%f', '%f', '%f', '%f', '%f', '%s')",
	iVariables[interior][InteriorID],
	iVariables[interior][InteriorVW],
	iVariables[interior][iPos][0],
	iVariables[interior][iPos][1],
	iVariables[interior][iPos][2],
	iVariables[interior][ePos][0],
	iVariables[interior][ePos][1],
	iVariables[interior][ePos][2],
	iVariables[interior][LabelText]);
	mysql_tquery(ConnectionHandle, szQuery);
	return true;
}
RCRP::CheckAccount(playerid)
{
	if(playerid != INVALID_PLAYER_ID)
	{
		if(cache_num_rows())
		{
			pVariables[playerid][AccID] = cache_get_field_content_int(0, "AccID");
			cache_get_field_content(0, "Password", pVariables[playerid][Password], ConnectionHandle, 129);
			format(szMessage,sizeof(szMessage),"{FFFFFF}Welcome back, %s\n\nPlease enter your password below to login:", RemoveUnderScore(playerid));
			Dialog_Show(playerid, LoginDialog, DIALOG_STYLE_PASSWORD, "{FFFFFF}SWAT Training Server - Login", szMessage, "Login", "Exit");
		}
		else
		{
			SendClientMessageF(playerid, WHITE, "The account %s does not exist, please contact an administrator if you need an account for training.", RemoveUnderScore(playerid));
			Kick(playerid);
		}
	}
	return 1;
}
RCRP::SaveData()
{
	foreach(Player, i)
	{
		SavePlayerData(i);
	}
	SaveInteriors();
	SaveVehicles();
	return true;
}
RCRP::CloseMessage(playerid, colour, string[])
{
	new Float: PlayerX, Float: PlayerY, Float: PlayerZ;
	foreach(Player, i)
	{
		if(IsPlayerConnected(i))
		{
			if(!IsPlayerInAnyVehicle(playerid))
			{
				GetPlayerPos(playerid, PlayerX, PlayerY, PlayerZ);
				if(IsPlayerInRangeOfPoint(i, 12, PlayerX, PlayerY, PlayerZ))
				{
					if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerInterior(playerid) == GetPlayerInterior(i))
					{
						SendClientMessage(i, colour, string);
					}
				}
			}
			else
			{
				GetPlayerPos(playerid, PlayerX, PlayerY, PlayerZ);
				if(GetPlayerVehicleID(playerid) == GetPlayerVehicleID(i))
				{
					SendClientMessage(i, colour, string);
				}
				else if(IsPlayerInRangeOfPoint(i, 12, PlayerX, PlayerY, PlayerZ))
				{
					if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerInterior(playerid) == GetPlayerInterior(i))
					{
						SendClientMessage(i, colour, string);
					}
				}
			}
		}
	}
	return 1;
}
RCRP::CreateAccount(playerid, name[], AdminRegistered[], AdminIP[])
{
	if(playerid != INVALID_PLAYER_ID)
	{
		if(cache_num_rows())
		{
			SendClientMessageF(playerid, WHITE, "The account %s already exists; please pick a new name.", RemoveUnderScore(playerid));
		}
		else
		{
			new hashpass[129];
			WP_Hash(hashpass, sizeof(hashpass), "changeme");
			mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "INSERT INTO `accounts` (Username, Password, AdminRegistered, AdminIP) VALUES ('%e', '%e', '%e', '%e')", name, hashpass, AdminRegistered, AdminIP);
			mysql_tquery(ConnectionHandle, szQuery);
			SendClientMessageF(playerid, WHITE, "The account %s has been created, password is changeme.", name);
		}
	}
	return 1;
}
public OnPlayerSpawn(playerid)
{
	if(IsSpectating[playerid] == 1)
	{
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetPlayerPos(playerid, specPosX[playerid], specPosY[playerid], specPosZ[playerid]);
		IsSpectating[playerid] = 0;
		SetPlayerSkin(playerid, pVariables[playerid][SkinID]);
	}
	else
	{
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetPlayerPos(playerid, -314.455047, 1774.518432, 43.640625);
		SetPlayerSkin(playerid, pVariables[playerid][SkinID]);
	}
	return 1;
}
public OnPlayerText(playerid, text[])
{
	new message[128];
	format(message, sizeof(message), "%s says: %s", RemoveUnderScore(playerid), text);
	ProxDetector(30.0, playerid, message, -1);
	return 0;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_SPRINT))
	{
		ClearAnimations(playerid);
	}
	return 1;
}
public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}
public OnPlayerUpdate(playerid)
{
	if(GetPlayerVehicleID(playerid) == 427 || GetPlayerVehicleID(playerid) == 528)
	{
		SetVehicleHealth(GetPlayerVehicleID(playerid), 10000);
	}
	return 1;
}
RCRP::LoadPlayerData(playerid)
{
	if(!cache_num_rows()) return true;

	pVariables[playerid][AccID] = cache_get_field_content_int(0, "AccID");
	pVariables[playerid][SkinID] = cache_get_field_content_int(0, "SkinID");
	pVariables[playerid][AdminLevel] = cache_get_field_content_int(0, "AdminLevel");
	pVariables[playerid][FirstLogin] = cache_get_field_content_int(0, "FirstLogin");
	cache_get_field_content(0, "AdminRegistered", pVariables[playerid][AdminReg], ConnectionHandle, 24);
	cache_get_field_content(0, "AdminIP", pVariables[playerid][AdmnIP], ConnectionHandle, 16);
	
	SetSpawnInfo(playerid, 4, pVariables[playerid][SkinID], -314.455047, 1774.518432, 43.640625, 1,-1, -1, -1, -1, -1, -1);
	SetPlayerSkin(playerid, pVariables[playerid][SkinID]);
	SpawnPlayer(playerid);
	SetTimerEx("SkinSet", 1000, false, "i", playerid);
	
	if(pVariables[playerid][FirstLogin] == 0)
	{
		Dialog_Show(playerid, PasswordDialog, DIALOG_STYLE_PASSWORD, "Change Password", "Please change your password", "Okay", "");
	}
	return 1;
}
RCRP::LoadInteriors()
{
	for(new i = 0, x = cache_num_rows(); i < x; i++)
	{
		iVariables[i][ID] = cache_get_field_content_int(i, "ID");
		iVariables[i][InteriorID] = cache_get_field_content_int(i, "InteriorID");
		iVariables[i][InteriorVW] = cache_get_field_content_int(i, "InteriorVW");
		iVariables[i][ExteriorID] = cache_get_field_content_int(i, "ExteriorID");
		iVariables[i][ExteriorVW] = cache_get_field_content_int(i, "ExteriorVW");
		iVariables[i][iPos][0] = cache_get_field_content_float(i, "iPosX");
		iVariables[i][iPos][1] = cache_get_field_content_float(i, "iPosY");
		iVariables[i][iPos][2] = cache_get_field_content_float(i, "iPosZ");
		iVariables[i][ePos][0] = cache_get_field_content_float(i, "ePosX");
		iVariables[i][ePos][1] = cache_get_field_content_float(i, "ePosY");
		iVariables[i][ePos][2] = cache_get_field_content_float(i, "ePosZ");
		cache_get_field_content(i, "LabelText", iVariables[i][LabelText], ConnectionHandle, 128);
		iVariables[i][InteriorLoaded] = 1;
		iVariables[i][PickupID] = CreateDynamicPickup(1272, 23, iVariables[i][ePos][0], iVariables[i][ePos][1], iVariables[i][ePos][2], iVariables[i][ExteriorVW], iVariables[i][ExteriorID], -1, 50);
		iVariables[i][Label] = CreateDynamic3DTextLabel(iVariables[i][LabelText], YELLOW, iVariables[i][ePos][0], iVariables[i][ePos][1], iVariables[i][ePos][2]+0.8, 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, iVariables[i][ExteriorVW], iVariables[i][ExteriorID], -1, 15);
		printf("ID: %d", iVariables[i][ID]);
		printf("Interior ID: %d", iVariables[i][InteriorID]);
	}
	return 1;
}
RCRP::LoadVehicles()
{
	for(new i = 0, x = cache_num_rows(); i < x; i++)
	{
		vVariables[i][VehicleID] = cache_get_field_content_int(i, "VehicleID");
		vVariables[i][ModelID] = cache_get_field_content_int(i, "ModelID");
		vVariables[i][vPos][0] = cache_get_field_content_float(i, "VehX");
		vVariables[i][vPos][1] = cache_get_field_content_float(i, "VehY");
		vVariables[i][vPos][2] = cache_get_field_content_float(i, "VehZ");
		vVariables[i][vPos][3] = cache_get_field_content_float(i, "VehA");
		vVariables[i][Colour1] = cache_get_field_content_int(i, "Colour1");
		vVariables[i][Colour2] = cache_get_field_content_int(i, "Colour2");
		vVariables[i][VehicleLoaded] = 1;
		vVariables[i][ScriptID] = CreateVehicle(vVariables[i][ModelID], vVariables[i][vPos][0], vVariables[i][vPos][1], vVariables[i][vPos][2], vVariables[i][vPos][3], vVariables[i][Colour1], vVariables[i][Colour2], -1);
	}
	return 1;
}
RCRP::LoadTeleports()
{
	for(new i = 0, x = cache_num_rows(); i < x; i++)
	{
		tVariables[i][ID] = cache_get_field_content_int(i, "id");
		cache_get_field_content(i, "Name", tVariables[i][Name], ConnectionHandle, 128);
		tVariables[i][tPos][0] = cache_get_field_content_float(i, "PosX");
		tVariables[i][tPos][1] = cache_get_field_content_float(i, "PosY");
		tVariables[i][tPos][2] = cache_get_field_content_float(i, "PosZ");
	}
	return 1;
}
RCRP::SkinSet(playerid)
{
	SetPlayerSkin(playerid, pVariables[playerid][SkinID]);
	return 1;
}
RCRP::GMX()
{
	SendRconCommand("gmx");
	return 1;
}
RCRP::IsPlayerAdminLevel(playerid, adminlevel)
{
	if(IsPlayerAdmin(playerid) || pVariables[playerid][AdminLevel] >= adminlevel) return 1;
	return 0;
}
RCRP::PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		tempposx = (oldposx -x);
		tempposy = (oldposy -y);
		tempposz = (oldposz -z);
		//printf("DEBUG: X:%f Y:%f Z:%f",posx,posy,posz);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return true;
		}
	}
	return false;
}
GetVehicleModelIDFromName(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if(strfind(aVehicleNames[i], vname, true) != -1)
		return i + 400;
	}
	return -1;
}
stock GetPlayerStats(playeridof, playeridfor)
{
	format(szMessage, sizeof(szMessage), "-------[You are viewing %s's statistics]-------", pName(playeridof));
	SendClientMessage(playeridfor, WHITE, szMessage);
	format(szMessage, sizeof(szMessage), "[AccID: %d | Character Name: %s | Admin Level: %d | Skin ID: %d]", pVariables[playeridof][AccID], pName(playeridof), pVariables[playeridof][AdminLevel], pVariables[playeridof][SkinID]);
	SendClientMessage(playeridfor, WHITE, szMessage);
	format(szMessage, sizeof(szMessage), "[Admin Registered: %s | Admin IP: %s | Recent IP: %s]", pVariables[playeridof][AdminReg], pVariables[playeridof][AdmnIP], pVariables[playeridof][LatestIP]);
	SendClientMessage(playeridfor, WHITE, szMessage);
	return 1;
}
stock BackAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp,animback)
{
	Anim_ClearOut[playerid] = animback;
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
	Anim_Animation[playerid]++;
}
stock ProxDetector(Float:radi, playerid, string[],color)
{
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	foreach(Player,i)
	{
		if(IsPlayerInRangeOfPoint(i,radi,x,y,z))
		{
			SendClientMessage(i,color,string);
		}
	}
}
stock GetXYInFrontOfPlayer(playerid, &Float:x2, &Float:y2, Float:distance)
{
	new Float:a;

	GetPlayerPos(playerid, x2, y2, a);
	GetPlayerFacingAngle(playerid, a);

	if(GetPlayerVehicleID(playerid))
	{
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x2 += (distance * floatsin(-a, degrees));
	y2 += (distance * floatcos(-a, degrees));
}
stock MakeSWAT(playerid)
{
	GivePlayerWeapon(playerid, 31, 1000);
	GivePlayerWeapon(playerid, 34, 1000);
	GivePlayerWeapon(playerid, 27, 1000);
	GivePlayerWeapon(playerid, 24, 1000);
	GivePlayerWeapon(playerid, 46, 1000);
	GivePlayerWeapon(playerid, 17, 10);
	SetPlayerSkin(playerid, 285);
	SetPlayerArmour(playerid, 125);
	SetPlayerHealth(playerid, 100);
	return 1;
}
stock MakeCriminal(playerid)
{
	GivePlayerWeapon(playerid, 24, 1000);
	GivePlayerWeapon(playerid, 30, 1000);
	SetPlayerSkin(playerid, 20);
	SetPlayerArmour(playerid, 100);
	SetPlayerHealth(playerid, 100);
	return 1;
}
stock GetWeaponModelIDFromName(wname[])
{
	for(new i = 0; i < 48; i++) {
		if (i == 19 || i == 20 || i == 21) continue;
		if (strfind(aWeaponNames[i], wname, true) != -1) {
			return i;
		}
	}
	return -1;
}
stock AdminMsg(string[], level)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(pVariables[i][AdminLevel] >= level)
		{
			SendClientMessage(i, RED, string);
		}
	}
	return 1;
}
stock IsNameTaken(name[])
{
	mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "SELECT * FROM accounts WHERE Username = '%s'", name);
	new Cache:result =  mysql_query(ConnectionHandle, szQuery, true);

	if(cache_num_rows()){cache_delete(result); return 1;}
	cache_delete(result);
	return 0;
}
stock IsInteriorTaken(name[])
{
	mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "SELECT * FROM interiors WHERE LabelText = '%s'", name);
	new Cache:result =  mysql_query(ConnectionHandle, szQuery, true);

	if(cache_num_rows()){cache_delete(result); return 1;}
	cache_delete(result);
	return 0;
}
stock RemoveUnderScore(playerid)
{
	new playersName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playersName, MAX_PLAYER_NAME);
	for(new i = 0; i < strlen(playersName); i++)
	{
		if(playersName[i] == '_')
		{
			playersName[i] = ' ';
		}
	 }
	return playersName;
}
stock IsValidSkin(skinid)
{
	if(skinid == 74 || skinid > 299 || skinid < 1) return 0;
	return 1;
}
stock IsValidWeatherID(weatherid)
{
	if(weatherid < 0 || weatherid > 50) return 0;
	return 1;
}
stock IsValidVehicleID(vehicleid)
{
	if(vehicleid < 400 || vehicleid > 611) return 0;
	return 1;
}
stock SyntaxMsg(playerid, string[])
{
	SendClientMessage(playerid, GREY, string);
	return 1;
}
stock SysMsg(playerid, string[])
{
	SendClientMessage(playerid, GREY, string);
	return 1;
}
stock ErrorMsg(playerid, string[])
{
	SendClientMessage(playerid, RED, string);
	return 1;
}
stock pName(playerid)
{
	new playersName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playersName, MAX_PLAYER_NAME);
	return playersName;
}
stock PlayerJoinMessage(playerid)
{
	new JoinMessage[128];
	format(JoinMessage, 128, "%s has joined the server. {FFFFFF}IP: %s, ID: %d.", pName(playerid), pVariables[playerid][LatestIP], playerid);

	foreach(Player, i)
	{
		if(IsPlayerAdminLevel(i, 1))
		{
			SendClientMessage(i, GREY, JoinMessage);
		}
	}
}
stock strmatch(const String1[], const String2[])
{
	if ((strcmp(String1, String2, true, strlen(String2)) == 0) && (strlen(String2) == strlen(String1))) return true;
	else return false;
}
stock SavePlayerData(playerid)
{
	mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "UPDATE accounts SET SkinID = %d, AdminLevel = %d, FirstLogin = %d, Password = '%s', LatestIP = '%s', AdminRegistered = '%s' WHERE AccID = %d",
	pVariables[playerid][SkinID],
	pVariables[playerid][AdminLevel],
	pVariables[playerid][FirstLogin],
	pVariables[playerid][Password],
	pVariables[playerid][LatestIP],
	pVariables[playerid][AdminReg],
	pVariables[playerid][AccID]);
	mysql_tquery(ConnectionHandle, szQuery);
	return 1;
}
stock SaveInteriors()
{
	for(new i = 0; i < MAX_INTERIORS; i++)
	{
		mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "UPDATE interiors SET InteriorID = %d, InteriorVW = %d, ExteriorID = %d, ExteriorVW = %d, iPosX = %f, iPosY = %f, iPosZ = %f, ePosX = %f, ePosY = %f, ePosZ = %f, LabelText = '%s' WHERE ID = %d",
		iVariables[i][InteriorID],
		iVariables[i][InteriorVW],
		iVariables[i][ExteriorID],
		iVariables[i][ExteriorVW],
		iVariables[i][iPos][0],
		iVariables[i][iPos][1],
		iVariables[i][iPos][2],
		iVariables[i][ePos][0],
		iVariables[i][ePos][1],
		iVariables[i][ePos][2],
		iVariables[i][LabelText],
		iVariables[i][ID]);
		mysql_tquery(ConnectionHandle, szQuery);
		return 1;
	}
	return true;
}
stock SaveVehicles()
{
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
		mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "UPDATE vehicles SET ModelID = %d, VehX = %f, VehY = %f, VehZ = %f, VehA = %f, Colour1 = %d, Colour2 = %d WHERE VehicleID = %d",
		vVariables[i][ModelID],
		vVariables[i][vPos][0],
		vVariables[i][vPos][1],
		vVariables[i][vPos][2],
		vVariables[i][vPos][3],
		vVariables[i][Colour1],
		vVariables[i][Colour2],
		vVariables[i][VehicleID]);
		mysql_tquery(ConnectionHandle, szQuery);
		return 1;
	}
	return true;
}
stock SaveTeleports()
{
	for(new i = 0; i < MAX_TELEPORTS; i++)
	{
		mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "UPDATE teleports SET Name = %s, PosX = %f, PosY = %f, PosZ = %f WHERE id = %d",
		tVariables[i][Name],
		tVariables[i][tPos][0],
		tVariables[i][tPos][1],
		tVariables[i][tPos][2],
		tVariables[i][ID]);
		return 1;
	}
	return true;
}
stock GetNextInteriorID()
{
	new i = 0;
	while(i != MAX_INTERIORS)
	{
		if(iVariables[i][InteriorLoaded] == 0)
		{
			return i;
		}
		i++;
	}
	return -1;
}
stock GetNextVehicleID()
{
	new i = 0;
	while(i != MAX_VEHICLES)
	{
		if(vVariables[i][VehicleLoaded] == 0)
		{
			return i;
		}
		i++;
	}
	return -1;
}
stock GetNextTeleportID()
{
	new i = 0;
	while(i != MAX_TELEPORT)
	{
		if(tVariables[i][TeleportLoaded] == 0)
		{
			return i;
		}
		i++;
	}
	return -1;
}
stock GetPlayerID(playername[])
{
	if(IsNumeric(playername))
		if(IsPlayerConnected(strval(playername)))
			return strval(playername);
		else return INVALID_PLAYER_ID;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected( i ) )
		{
			new playername2[ MAX_PLAYER_NAME ];
			GetPlayerName(i, playername2, sizeof(playername2));
			if(strmatch(playername2, playername))
			{
				return i;
			}
		}
	}
	return INVALID_PLAYER_ID;
}
stock IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}
CMD:sit(playerid, params[])
{
	new anim;
	if(sscanf(params, "i", anim)) return SendClientMessage(playerid, -1, "USAGE: /sit [1-4]");
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 1;

	switch(anim)
	{
		case 1: BackAnim(playerid,"PED","SEAT_down",4.1,0,0,1,0,0,8); // 1,0,8
		case 2: LoopingAnim(playerid,"MISC","seat_lr",2.0,1,0,0,0,0);
		case 3: LoopingAnim(playerid,"MISC","seat_talk_01",2.0,1,0,0,0,0);
		case 4: LoopingAnim(playerid,"MISC","seat_talk_02",2.0,1,0,0,0,0);
		default: SendClientMessage(playerid, -1, "USAGE: /sit [1-4]");
	}
	return 1;
}
CMD:fall(playerid, params[])
{
	new anim;
	if(sscanf(params, "i", anim)) return SendClientMessage(playerid, -1, "USAGE: /fall [1-2]");
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 1;

	switch(anim)
	{
		case 1: LoopingAnim(playerid,"PED","KO_skid_front",4.1,0,1,1,1,0);
		case 2: LoopingAnim(playerid,"PED","KO_skid_back",4.1,0,1,1,1,0);
		case 3: LoopingAnim(playerid, "PED","FLOOR_hit_f", 4.0, 1, 0, 0, 0, 0);
		default: SendClientMessage(playerid, -1, "USAGE: /fall [1-2]");
	}
	return 1;
}
CMD:xyz(playerid, params[])
{

	new Float:X, Float:Y, Float:Z, interiorid;
	if(sscanf(params, "fffD(0)", X, Y, Z, interiorid)) return SysMsg(playerid, "[Usage] /xyz [x] [y] [z] [interior id]");

	SetPlayerPos(playerid, X, Y, Z);
	SetPlayerInterior(playerid, interiorid);
	return 1;
}
CMD:pm(playerid, params[])
{
	new pid, pmsg[128];
	if(sscanf(params, "us[128]", pid, pmsg)) return SendClientMessage(playerid, -1, "> USAGE: /pm [playerid/playername] [message]");
	if(!IsPlayerConnected(pid)) return SendClientMessage(playerid, RED, "The player you have tried to message isn't currently online.");

	format(szMessage, sizeof(szMessage), "[PM from %s, ID %d] %s", RemoveUnderScore(playerid), playerid,  pmsg);
	SendClientMessage(pid, YELLOW, szMessage);

	format(szMessage, sizeof(szMessage), "[PM to %s, ID %d] %s", RemoveUnderScore(pid), pid, pmsg);
	SendClientMessage(playerid, YELLOW, szMessage);

	return 1;
}
CMD:gate(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 20, -354.50000, 1732.00000, 41.80000))
	{
		if(swatOpen == 0)
		{
			swatOpen = 1;
			MoveDynamicObject(swatgate1, -354.50000, 1741.0000, 41.80000, 2);
		}
		else
		{
			swatOpen = 0;
			MoveDynamicObject(swatgate1, -354.50000, 1732.00000, 41.80000, 2);
		}
	}
	return 1;
}
CMD:rubberbullets(playerid, params[])
{
	if(GetPlayerWeapon(playerid) == 25)
	{
		if(RubberBullets[playerid] == 0)
		{
			SendClientMessage(playerid, BLUE, "Rubber Bullets activated.");
			RubberBullets[playerid] = 1;
		}
		else
		{
			SendClientMessage(playerid, BLUE, "Rubber Bullets deactivated.");
			RubberBullets[playerid] = 0;
		}
	}
	return 1;
}
CMD:spec(playerid, params[])
{
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "You are not authorised to use this command.");
	
	new id = GetPlayerID(playa);
	if(sscanf(params, "u", id)) return SendClientMessage(playerid, GREY, "[Usage] /spec [playerid or name]");
	if(id == playerid)return SendClientMessage(playerid, GREY,"You cannot spec yourself.");
	if(id == INVALID_PLAYER_ID)return SendClientMessage(playerid, GREY, "Invalid player ID.");
	
	GetPlayerPos(playerid, specPosX[playerid], specPosY[playerid], specPosZ[playerid]);
	TogglePlayerSpectating(playerid, 1);
	IsSpectating[playerid] = 1;
	WhoSpectating[playerid] = id;

	SetPlayerInterior(playerid, GetPlayerInterior(id));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));

	if(IsPlayerInAnyVehicle(id)) PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));
	else PlayerSpectatePlayer(playerid, id);

	SendClientMessageF(playerid, GREY, "You are now spectating %s.", pName(id));
	return 1;
}
CMD:specoff(playerid, params[])
{
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "You are not authorised to use this command.");
	if(IsSpectating[playerid] == 0) return SendClientMessage(playerid, GREY, "You're not even spectating.");
	
	TogglePlayerSpectating(playerid, 0);
	WhoSpectating[playerid] = -1;
	return 1;
}
CMD:whospec(playerid, params[])
{
	new count = 0;
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "You are not authorised to use this command.");

	foreach(Player, i)
	{
		if(IsSpectating[i] == 1)
		{
			SendClientMessageF(playerid, WHITE, "%s is spectating %s.", pName(i), pName(WhoSpectating[i]));
			count++;
		}
	}
	if(count == 0) return SendClientMessage(playerid, GREY, "No one is spectating.");
	return 1;
}
CMD:gmx(playerid, params[])
{
	SaveData();
	format(szMessage, sizeof(szMessage), "[Announcement]: {FFFFFF}Administrator %s has initiated a server restart. Server restarting in 5 seconds.", pName(playerid));
	SendClientMessageToAll(RED, szMessage);
	SetTimerEx("GMX", 5000, false, "i", playerid);
	return 1;
}
CMD:nextinterior(playerid, params[])
{
	SendClientMessageF(playerid, WHITE, "The next interior ID is %d", GetNextInteriorID());
	return 1;
}
CMD:nextvehicle(playerid, params[])
{
	SendClientMessageF(playerid, WHITE, "The next vehicle ID is %d", GetNextVehicleID());
	return 1;
}
CMD:a(playerid, params[])
{
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "You are not authorised to use that command.");
	if(isnull(params)) return SendClientMessage(playerid, GREY, "[Usage] /a [message]");
	
	format(szMessage, sizeof(szMessage), "[Admin] %s: %s", RemoveUnderScore(playerid), params);
	AdminMsg(szMessage, 1);
	return 1;
}
CMD:stats(playerid, params[])
{
	if(isnull(params))
	{
		GetPlayerStats(playerid, playerid);
	}
	else
	{
		if(!IsPlayerAdminLevel(playerid, 1)) return ErrorMsg(playerid, AdminOnly);
		new id = -1;
		if(sscanf(params, "u", id)) return SyntaxMsg(playerid,"[Usage]: /stats [playerid or name]");
		if(id == INVALID_PLAYER_ID) return SyntaxMsg(playerid, "You entered an invalid playerid.");

		GetPlayerStats(id, playerid);
	}
	return 1;
}
CMD:giveweapon(playerid, params[])
{
	new playaID = GetPlayerID(playa);
	new weaponname[32];
	new ammo;

	if(sscanf(params, "us[32]D(-1)", playaID, weaponname, ammo)) return SendClientMessage(playerid, GREY, "[USAGE]: /giveweapon [playerid] [weapon name/id] [ammo (optional)]");
	{
		if(ammo == -1)
		{
			GivePlayerWeapon(playaID, GetWeaponModelIDFromName(weaponname), 500);
			format(szMessage, sizeof(szMessage), "[AdmMsg]:{FFFFFF} %s has given %s a %s with 500 ammo.", pName(playerid), pName(playaID), aWeaponNames[GetWeaponModelIDFromName(weaponname)]);
			AdminMsg(szMessage, 1);
		}
		else
		{
			GivePlayerWeapon(playaID, GetWeaponModelIDFromName(weaponname), ammo);
			format(szMessage, sizeof(szMessage), "[AdmMsg]:{FFFFFF} %s has given %s a %s with %d ammo.", pName(playerid), pName(playaID), aWeaponNames[GetWeaponModelIDFromName(weaponname)], ammo);
			AdminMsg(szMessage, 1);
		}
	}
	return 1;
}
CMD:veh(playerid, params[])
{
	new carname[64], Float: pPos[3], colour1, colour2;
	if(sscanf(params, "s[64]D(0)D(0)", carname, colour1, colour2)) return SysMsg(playerid, "[Usage] /veh [vehicle name or id] [colour 1 (optional)] [colour 2 (optional)]");

	new vehicle = GetVehicleModelIDFromName(carname);
	if(vehicle < 400 || vehicle > 611) return SendClientMessage(playerid, RED, "[Error] Invalid vehicle name.");

	new Float:a;
	GetPlayerFacingAngle(playerid, a); 
	GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);

	if(IsPlayerInAnyVehicle(playerid)) GetXYInFrontOfPlayer(playerid, pPos[0], pPos[1], 8);
	else GetXYInFrontOfPlayer(playerid, pPos[0], pPos[1], 5);

	CreateVehicle(vehicle, pPos[0], pPos[1], pPos[2] , a+90, colour1, colour2, -1);
	LinkVehicleToInterior(vehicle, GetPlayerInterior(playerid));
	vehiclecount++;
	SendClientMessageF(playerid, GREEN, "You have spawned a %s.", aVehicleNames[vehicle - 400]);
	return 1;
}
CMD:delv(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return ErrorMsg(playerid, "[Error] You must be in the vehicle you wish to delete.");

	DestroyVehicle(GetPlayerVehicleID(playerid));
	SendClientMessageF(playerid, WHITE, "Vehicle ID %d deleted.", GetPlayerVehicleID(playerid));
	return 1;
}
CMD:me(playerid, params[])
{
	if(!isnull(params))
	{
		format(szMessage, sizeof(szMessage), "* %s %s", pName(playerid), params);
		CloseMessage(playerid, ACTION, szMessage);
	}
	else return SendClientMessage(playerid, WHITE, "[Usage] /me [action]");
	return 1;
}
CMD:do(playerid, params[])
{
	if(!isnull(params))
	{
		format(szMessage, sizeof(szMessage), "%s ((%s))", params, RemoveUnderScore(playerid));
		CloseMessage(playerid, ACTION, szMessage);
	}
	else return SendClientMessage(playerid, WHITE, "[Usage] /do [action]");
	return 1;
}
CMD:hq(playerid, params[])
{
	SetPlayerPos(playerid, -329.5062,1779.1732,999.3145);
	return 1;
}
CMD:gotop(playerid, params[])
{
	if(IsPlayerAdminLevel(playerid, 1))
	{
		new playaID = GetPlayerID(playa);
		if(sscanf(params, "u", playaID)) return SendClientMessage(playerid, GREY, "[USAGE]: /gotop [playerid]");
		{
			if(IsPlayerInAnyVehicle(playaID))
			{
				new vehicleid = GetPlayerVehicleID(playaID), Float: pPos[3];
				GetVehiclePos(vehicleid, pPos[0], pPos[1], pPos[2]);
				SetVehiclePos(vehicleid, pPos[0], pPos[1], pPos[2]);
				GetPlayerPos(playaID, pPos[0], pPos[1], pPos[2]);
				SetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				SetPlayerInterior(playerid, GetPlayerInterior(playaID));
				LinkVehicleToInterior(vehicleid, GetPlayerInterior(playaID));
				PutPlayerInVehicle(playaID, vehicleid, 0);
				SendClientMessageF(playaID, BLUE, "Administrator %s has teleported to you.", RemoveUnderScore(playerid));
			}
			else
			{
				new Float: pPos[3];
				GetPlayerPos(playaID, pPos[0], pPos[1], pPos[2]);
				SetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				SetPlayerInterior(playerid, GetPlayerInterior(playaID));
				SendClientMessageF(playaID, BLUE, "Administrator %s has teleported to you.", RemoveUnderScore(playerid));
			}
		}
	}
	else return SendClientMessage(playerid, RED, "[ERROR]: You are not authorized to use this command.");
	return 1;
}
CMD:door(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 3.0, -328.1891, 1781.1094, 999.4085))
	{
		if(DoorStatus[0] == 0)
		{
			SetDynamicObjectRot(SWATDoor[0], 0, 0, 90);
			DoorStatus[0] = 1;
		}
		else
		{
			SetDynamicObjectRot(SWATDoor[0], 0, 0, 0);
			DoorStatus[0] = 0;
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 3.0, -327.9846, 1791.4232, 999.4085))
	{
		if(DoorStatus[1] == 0)
		{
			SetDynamicObjectRot(SWATDoor[1], 0, 0, 180);
			DoorStatus[1] = 1;
		}
		else
		{
			SetDynamicObjectRot(SWATDoor[1], 0, 0, 90);
			DoorStatus[1] = 0;
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 3.0, -323.0453, 1793.3356, 999.4085))
	{
		if(DoorStatus[3] == 0)
		{
			SetDynamicObjectRot(SWATDoor[3], 0, 0, -90);
			DoorStatus[3] = 1;
		}
		else
		{
			SetDynamicObjectRot(SWATDoor[3], 0, 0, 0);
			DoorStatus[3] = 0;
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 3.0, -331.9164, 1799.4480, 999.4085))
	{
		if(DoorStatus[4] == 0)
		{
			SetDynamicObjectRot(SWATDoor[4], 0, 0, -90);
			DoorStatus[4] = 1;
		}
		else
		{
			SetDynamicObjectRot(SWATDoor[4], 0, 0, 0);
			DoorStatus[4] = 0;
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 3.0, -327.1169, 1799.4480, 999.4085))
	{
		if(DoorStatus[5] == 0)
		{
			SetDynamicObjectRot(SWATDoor[5], 0, 0, -90);
			DoorStatus[5] = 1;
		}
		else
		{
			SetDynamicObjectRot(SWATDoor[5], 0, 0, 0);
			DoorStatus[5] = 0;
		}
	}
	if(IsPlayerInRangeOfPoint(playerid, 3.0, -322.3239, 1799.4480, 999.4085))
	{
		if(DoorStatus[6] == 0)
		{
			SetDynamicObjectRot(SWATDoor[6], 0, 0, -90);
			DoorStatus[6] = 1;
		}
		else
		{
			SetDynamicObjectRot(SWATDoor[6], 0, 0, 0);
			DoorStatus[6] = 0;
		}
	}
	return 1;
}
CMD:cell(playerid, params[])
{
	if(IsPlayerInRangeOfPoint(playerid, 3.0, -327.9943, 1787.4910, 999.5308))
	{
		if(DoorStatus[2] == 0)
		{
			MoveDynamicObject(SWATDoor[2], -327.9943, 1788.9110, 999.5308, 1);
			DoorStatus[2] = 1;
		}
		else
		{
			MoveDynamicObject(SWATDoor[2], -327.9943, 1787.4910, 999.5308, 1);
			DoorStatus[2] = 0;
		}
	}
	return 1;
}
CMD:getp(playerid, params[])
{
	if(IsPlayerAdminLevel(playerid, 1))
	{
		new playaID = GetPlayerID(playa);
		if(sscanf(params, "u", playaID)) return SendClientMessage(playerid, GREY, "[USAGE]: /getp [playerid]");
		{
			if(IsPlayerInAnyVehicle(playaID))
			{
				new vehicleid = GetPlayerVehicleID(playaID), Float: pPos[3];
				GetVehiclePos(vehicleid, pPos[0], pPos[1], pPos[2]);
				SetVehiclePos(vehicleid, pPos[0], pPos[1], pPos[2]);
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				SetPlayerPos(playaID, pPos[0], pPos[1], pPos[2]);
				LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
				SetPlayerInterior(playaID, GetPlayerInterior(playerid));
				PutPlayerInVehicle(playaID, vehicleid, 0);
				SendClientMessageF(playaID, BLUE, "Administrator %s has teleported you to them.", RemoveUnderScore(playerid));
			}
			else
			{
				new Float: pPos[3];
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				SetPlayerPos(playaID, pPos[0], pPos[1], pPos[2]);
				SetPlayerInterior(playaID, GetPlayerInterior(playerid));
				SendClientMessageF(playaID, BLUE, "Administrator %s has teleported you to them.", RemoveUnderScore(playerid));
			}
		}
	}
	else return SendClientMessage(playerid, RED, "[ERROR]: You are not authorized to use this command.");
	return 1;
}
CMD:set(playerid, params[])
{
	new id, amount[32], option[24];
	if(!IsPlayerAdminLevel(playerid, 1)) return ErrorMsg(playerid, AdminOnly);

	if(sscanf(params, "us[24]s[32]", id, option, amount))
	{
		if(IsPlayerAdminLevel(playerid, 1))
		{
			SyntaxMsg(playerid, "[Usage]: /set [playerid or name] [option] [amount]");
			SyntaxMsg(playerid, "Settings: Health, Armour, Skin");
			SyntaxMsg(playerid, "Settings: vw, interior, rank");
		}
		else if(IsPlayerAdminLevel(playerid, 2))
		{
			SyntaxMsg(playerid, "Settings: Name");
		}
		else if(IsPlayerAdminLevel(playerid, 4))
		{
			SyntaxMsg(playerid, "Settings: Admin Level");
		}
		return 1;
	}
	else
	{
		if(IsPlayerConnected(id))
		{
			if(strmatch("health", option))
			{
				if(strval(amount) <= 100 && strval(amount) >= 1)
				{
					format(szMessage, sizeof(szMessage), "Administrator %s has set your health to %d.", pName(playerid), strval(amount));
					SendClientMessage(id, BLUE, szMessage);
					format(szMessage, sizeof(szMessage), "You have set %s's health to %d.", pName(id), strval(amount));
					SendClientMessage(playerid, BLUE, szMessage);
					SetPlayerHealth(id, strval(amount));
				}
				else ErrorMsg(playerid, "[Error] Invalid amount (1-100)");
			}
			if(strmatch("armour", option))
			{
				if(strval(amount) <= 100 && strval(amount) >= 1)
				{
					format(szMessage, sizeof(szMessage), "Administrator %s has set your armour to %d.", pName(playerid), strval(amount));
					SendClientMessage(id, BLUE, szMessage);
					format(szMessage, sizeof(szMessage), "You have set %s's armour to %d.", pName(id), strval(amount));
					SendClientMessage(playerid, BLUE, szMessage);
					SetPlayerArmour(id, strval(amount));
				}
				else ErrorMsg(playerid, "[Error] Invalid amount (1-100)");
			}
			if(strmatch("skin", option))
			{
				if(IsPlayerAdminLevel(playerid, 2))
				{
					if(IsValidSkin(strval(amount)))
					{
						format(szMessage, sizeof(szMessage), "Administrator %s has set your skin ID to %d.", pName(playerid), strval(amount));
						SendClientMessage(id, BLUE, szMessage);
						format(szMessage, sizeof(szMessage), "You have set %s's skin to %d.", pName(id), strval(amount));
						SendClientMessage(playerid, BLUE, szMessage);
						pVariables[id][SkinID] = strval(amount);
						SetPlayerSkin(id, pVariables[id][SkinID]);
					}
					else return ErrorMsg(playerid, "[Error] Invalid Skin ID.");
				}
				else return ErrorMsg(playerid, "[Error] You are not a high enough admin level.");
			}
		}
		if(strmatch("name", option))
		{
			if(IsPlayerAdminLevel(playerid, 3))
			{
				if(IsNameTaken(amount)) return ErrorMsg(playerid, "[Error] That name already exists in our database.");

				format(szMessage, sizeof(szMessage), "You have set %s's name to %s.", pName(id), pName(playerid));
				format(szMessage, sizeof(szMessage), "Administrator %s has set your name to %s.", pName(playerid), amount);
				SendClientMessage(playerid, BLUE, szMessage);
				SetPlayerName(playerid, amount);

				mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "UPDATE `players` SET `Username`= '%s' WHERE `AccID`= '%d'", amount, pVariables[id][AccID]);
				mysql_tquery(ConnectionHandle, szQuery);
				SetPlayerName(id, amount);
			}
			else return ErrorMsg(playerid, "[Error] You are not a high enough admin level.");
		}
		if(strmatch("vw", option))
		{
			format(szMessage, sizeof(szMessage), "Administrator %s has set your virtual world to %d.", pName(playerid), strval(amount));
			SendClientMessage(id, BLUE, szMessage);
			SetPlayerVirtualWorld(id, strval(amount));

			format(szMessage, sizeof(szMessage), "You have set %s's virtual world to %d.", pName(id), strval(amount));
			SendClientMessage(playerid, BLUE, szMessage);
		}
		if(strmatch("interior", option))
		{
			format(szMessage, sizeof(szMessage), "Administrator %s has set your interior id to %d.", pName(playerid), strval(amount));
			SendClientMessage(id, BLUE, szMessage);
			SetPlayerInterior(id, strval(amount));

			format(szMessage, sizeof(szMessage), "You have set %s's interior id to %d.", pName(id), strval(amount));
			SendClientMessage(playerid, BLUE, szMessage);
		}
		SavePlayerData(id);
	}
	return 1;
}
CMD:makeaccount(playerid, params[])
{
	if(IsPlayerAdminLevel(playerid, 4))
	{
		new name[24];
		if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, GREY, "[Usage] /makeaccount [name]");
		
		CreateAccount(playerid, name, pName(playerid), pVariables[playerid][LatestIP]);
	}
	else return SendClientMessage(playerid, RED, "[Error] You are not authorised to use that command.");
	return 1;
}
CMD:makeadmin(playerid, params[])
{
	if(IsPlayerAdminLevel(playerid, 4))
	{
		new name[24], level, id;
		if(sscanf(params, "s[24]d", name, level)) return SendClientMessage(playerid, GREY, "[Usage] /makeadmin [playerid] [admin level (1-4)]");
		
		id = GetPlayerID(name);
		SendClientMessageF(id, BLUE, "Administrator %s has set your admin level to %d.", RemoveUnderScore(playerid), level);
		SendClientMessageF(playerid, BLUE, "You have set %s's admin level to %d.", RemoveUnderScore(id), level);
		pVariables[id][AdminLevel] = level;
	}
	return 1;
}
CMD:enter(playerid, params[])
{
	for(new i = 0; i < MAX_INTERIORS; i++)
	{
		new Float: epos1 = iVariables[i][ePos][0];
		new Float: epos2 = iVariables[i][ePos][1];
		new Float: epos3 = iVariables[i][ePos][2];
		new vw = GetPlayerVirtualWorld(playerid);
		if(PlayerToPoint(2.0, playerid, epos1, epos2, epos3) && vw == 0)
		{
			SetPlayerPos(playerid, iVariables[i][iPos][0], iVariables[i][iPos][1], iVariables[i][iPos][2]);
			SetPlayerVirtualWorld(playerid, iVariables[i][InteriorVW]);
			SetPlayerInterior(playerid, iVariables[i][InteriorID]);
		}
	}
	return 1;
}
CMD:exit(playerid, params[])
{
	for(new i = 0; i < MAX_INTERIORS; i++)
	{
		new Float: epos1 = iVariables[i][iPos][0];
		new Float: epos2 = iVariables[i][iPos][1];
		new Float: epos3 = iVariables[i][iPos][2];
		new vw = GetPlayerVirtualWorld(playerid);
		if(PlayerToPoint(2.0, playerid, epos1, epos2, epos3) && vw == iVariables[i][InteriorVW])
		{
			SetPlayerPos(playerid, iVariables[i][ePos][0], iVariables[i][ePos][1], iVariables[i][ePos][2]);
			SetPlayerVirtualWorld(playerid, iVariables[i][ExteriorVW]);
			SetPlayerInterior(playerid, iVariables[i][ExteriorID]);
		}
	}
	return 1;
}
CMD:createint(playerid, params[])
{
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "[Error] You are not authorised to use this command.");
	
	new intid, intvw, Float: sPos[3], name[128];
	if(sscanf(params, "ddfffs[128]", intid, intvw, sPos[0], sPos[1], sPos[2], name)) return SendClientMessage(playerid, GREY, "[Usage] /createint [interior id] [interior vw] [interior x] [interior y] [interior z] [name]");
	
	if(IsInteriorTaken(name)) return SendClientMessage(playerid, RED, "[Error] That name already exists in our database.");
	CreateInterior(playerid, intid, intvw, sPos[0], sPos[1], sPos[2], name);
	SaveInteriors();
	return 1;
}
CMD:o(playerid, params[])
{
	new message[256];
	if(sscanf(params, "s[256]", message)) return SendClientMessage(playerid, GREY, "[Usage] /o [message]");
	
	format(szMessage, sizeof(szMessage), "[OOC] %s: %s", RemoveUnderScore(playerid), message);
	SendClientMessageToAll(WHITE, szMessage);
	return 1;
}
CMD:createveh(playerid, params[])
{
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "[Error] You are not authorised to use this command.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, RED, "[Error] You're not even in a vehicle.");
	
	new colour1, colour2, currentveh, Float: pPos[4], modelid;
	if(sscanf(params, "dD(0)", colour1, colour1)) return SendClientMessage(playerid, GREY, "[Usage] /creatveh [colour 1] [colour 2 (optional)");
	
	currentveh = GetPlayerVehicleID(playerid);
	modelid = GetVehicleModel(currentveh);
	GetVehiclePos(currentveh, pPos[0], pPos[1], pPos[2]);
	GetVehicleZAngle(currentveh, pPos[3]);
	DestroyVehicle(currentveh);
	CreateVehicleEx(modelid, pPos[0], pPos[1], pPos[2], pPos[3], colour1, colour2);
	SaveVehicles();
	return 1;
}
CMD:freeze(playerid, params[])
{
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "[Error] You are not authorised to use this command.");
	
	new name[24], id;
	if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, GREY, "[Usage] /freeze [playerid or name]");
	
	id = GetPlayerID(name);
	SendClientMessageF(playerid, BLUE, "You have frozen %s.", pName(id));
	SendClientMessageF(id, BLUE, "Admin %s has frozen you.", pName(playerid));
	TogglePlayerControllable(id, 0);
	return 1;
}
CMD:unfreeze(playerid, params[])
{
	if(!IsPlayerAdminLevel(playerid, 1)) return SendClientMessage(playerid, RED, "[Error] You are not authorised to use this command.");

	new name[24], id;
	if(sscanf(params, "s[24]", name)) return SendClientMessage(playerid, GREY, "[Usage] /unfreeze [playerid or name]");

	id = GetPlayerID(name);
	SendClientMessageF(playerid, BLUE, "You have unfrozen %s.", pName(id));
	SendClientMessageF(id, BLUE, "Admin %s has unfrozen you.", pName(playerid));
	TogglePlayerControllable(id, 1);
	return 1;
}
CMD:admins(playerid, params[])
{
	new count = 0;
	foreach(Player, i)
	{
		if(pVariables[i][AdminLevel] >= 1 && aDuty[i] == 0)
		{
			format(szMessage, sizeof(szMessage), "%s (%s) | Status: {E60000}Busy", RemoveUnderScore(i), AdminNames[pVariables[i][AdminLevel] - 1]);
			SendClientMessage(playerid, WHITE, szMessage);
			count++;
		}
		else if(pVariables[i][AdminLevel] >= 1 && aDuty[i] == 1)
		{
			format(szMessage, sizeof(szMessage), "%s (%s) | Status: {00FF00}Administrating", RemoveUnderScore(i), AdminNames[pVariables[i][AdminLevel] - 1]);
			SendClientMessage(playerid, WHITE, szMessage);
			count++;
		}
		if(count == 0)
		{
			SendClientMessage(playerid, WHITE, "No administrators online.");
		}
	}
	return 1;
}
CMD:afix(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xFFFFFFFF, "You are not in a vehicle!");

	RepairVehicle(GetPlayerVehicleID(playerid));
	SendClientMessage(playerid, 0xFFFFFFFF, "Your vehicle has been repaired!");
	return 1;
}
CMD:tp(playerid, params[])
{
	new tpID, locations[32];

	if(IsPlayerAdminLevel(playerid, 1))
	{
		if(sscanf(params, "us[32]", tpID, locations))
		{
			SendClientMessage(playerid, 0xCECECEFF, "[USAGE]: /tp [playerid] [location]");
			SendClientMessage(playerid, 0xCECECEFF, "Teleports: Montgomery, Palomino Creek, Fort Carson, Dillimore, Blueberry, Piece of Spain, Lucky Loans, Pershing Square");
			SendClientMessage(playerid, 0xCECECEFF, "Teleports: SF Warehouse, Zombotech, SF Boat, SF Boat 1, LV Parking Garage, LV Parking Garage 1, Loyal Legion, Jefferson Motel");
		}

		else if(strcmp(locations, "Montgomery", true) == 0)
		{
			SetPlayerPos(tpID, 1284.476440, 260.044921, 19.554687);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Montgomery.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Montgomery.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Montgomery.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Palomino Creek", true) == 0)
		{
			SetPlayerPos(tpID, 2285.740966, -17.755676, 26.484375);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Palomino Creek.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Palomino Creek.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Palomino Creek.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Dillimore", true) == 0)
		{
			SetPlayerPos(tpID, 673.676208, -494.798370, 16.335937);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Dillimore.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Dillimore.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Dillimore.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Fort Carson", true) == 0)
		{
			SetPlayerPos(tpID, -122.897377, 1206.739868, 19.742187);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Fort Carson.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Fort Carson.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Fort Carson.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Piece of Spain", true) == 0)
		{
			SetPlayerPos(tpID, -314.455047, 1774.518432, 43.640625);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to the Piece of Spain.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to the Piece of Spain.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to the Piece of Spain.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Lucky Loans", true) == 0)
		{
			SetPlayerPos(tpID, 1322.402587, 352.325286, 19.554687);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Lucky Loans.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Lucky Loans.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Lucky Loans.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Pershing Square", true) ==0)
		{
			SetPlayerPos(tpID, 1541.693359, -1674.237060, 13.553047);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Pershing Square.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Pershing Square.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Pershing Square.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Blueberry", true) ==0)
		{
			SetPlayerPos(tpID, 254.254531, -62.952922, 1.578125);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Blueberry.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Blueberry.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Blueberry.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "SF Warehouse", true) ==0)
		{
			SetPlayerPos(tpID, -2148.424804, -210.551940, 35.320312);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to SF Warehouse.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to SF Warehouse.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to SF Warehouse.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Zombotech", true) ==0)
		{
			SetPlayerPos(tpID, -1915.181884, 711.824340, 46.562500);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Zombotech.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Zombotech.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Zombotech.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "SF Boat", true) ==0)
		{
			SetPlayerPos(tpID, -1427.532226, 496.689910, 3.039062);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to SF Boat.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to SF Boat.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to SF Boat.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "SF Boat 1", true) ==0)
		{
			SetPlayerPos(tpID, -1446.453002, 1502.905883, 1.736648);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to SF Boat 1.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to SF Boat 1.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to SF Boat 1.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "LV Parking Garage", true) ==0)
		{
			SetPlayerPos(tpID, 2085.416748, 2421.847167, 10.820312);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to LV Parking Garage.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to LV Parking Garage.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to LV Parking Garage.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "LV Parking Garage 1", true) ==0)
		{
			SetPlayerPos(tpID, 1891.206298, 1968.288696, 13.784769);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to LV Parking Garage 1.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to LV Parking Garage 1.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to LV Parking Garage 1.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Loyal Legion", true) ==0)
		{
			SetPlayerPos(tpID, -568.2643, -1507.2965, 800.9131);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Loyal Legion.", RemoveUnderScore(playerid));
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "You have teleported %s to Loyal Legion.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Loyal Legion.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
		else if(strcmp(locations, "Jefferson Motel", true) ==0)
		{
			SetPlayerPos(tpID, 2219.418457, -1146.182250, 25.782423);
			SetPlayerVirtualWorld(tpID, 0);
			SetPlayerInterior(tpID, 0);
			SendClientMessage(tpID, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "Admin %s has teleported you to Jefferson Motel.", RemoveUnderScore(playerid));
			format(szMessage, sizeof(szMessage), "You have teleported %s to Jefferson Motel.", RemoveUnderScore(tpID));
			SendClientMessage(playerid, BLUE, szMessage);
			format(szMessage, sizeof(szMessage), "[AdmCmd]:{FFFFFF} Admin %s has teleported %s to Jefferson Motel.", RemoveUnderScore(playerid), RemoveUnderScore(tpID));
			AdminMsg(szMessage, 1);
		}
	}
	return 1;
}
CMD:aduty(playerid, params[])
{
	if(IsPlayerAdminLevel(playerid, 1))
	{
		switch(aDuty[playerid])
		{
			case 0:
			{
				aDuty[playerid] = 1;
				SendClientMessage(playerid, GREY, "Admin duty on.");
			}
			case 1:
			{
				aDuty[playerid] = 0;
				SendClientMessage(playerid, GREY, "Admin duty off.");
			}
		}
	}
	else return SendClientMessage(playerid, RED, AdminOnly);
	return 1;
}
CMD:swat(playerid, params[])
{
	format(szMessage, sizeof(szMessage), "[SWAT Duty]: %s is now on SWAT duty.", RemoveUnderScore(playerid));
	AdminMsg(szMessage, 1);
	MakeSWAT(playerid);
	return 1;
}
CMD:criminal(playerid, params[])
{
	format(szMessage, sizeof(szMessage), "[Criminal Mode]: %s has activated criminal mode.", RemoveUnderScore(playerid));
	AdminMsg(szMessage, 1);
	MakeCriminal(playerid);
	return 1;
}
//dialog responses
Dialog:LoginDialog(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	if(strlen(inputtext) >= 3)
	{
		new wpPass[129];
		WP_Hash(wpPass, sizeof(wpPass), inputtext);
		if(strmatch(wpPass, pVariables[playerid][Password]))
		{
			mysql_format(ConnectionHandle, szQuery, sizeof(szQuery), "SELECT * FROM `accounts` WHERE `Username` = '%s'", pName(playerid));
			mysql_tquery(ConnectionHandle, szQuery, "LoadPlayerData", "i", playerid);
		}
		else if(passAtt[playerid] <= 2)
		{
			passAtt[playerid]++;
			format(szMessage, sizeof(szMessage), "\tIncorrect Password! [%d/3]\nPlease enter your password below!", passAtt[playerid]);
			Dialog_Show(playerid, LoginDialog, DIALOG_STYLE_PASSWORD, "LOGIN", szMessage, "Login", "");
		}
		else Kick(playerid);
	}
	return true;
}
Dialog:PasswordDialog(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);

	if(strlen(inputtext) >= 5)
	{
		WP_Hash(pVariables[playerid][Password], 129, inputtext);
		SendClientMessageF(playerid, WHITE, "Your password has been changed to %s.", inputtext);
		pVariables[playerid][FirstLogin] = 1;
		SavePlayerData(playerid);
	}
	else
	{
		SendClientMessage(playerid, WHITE, "Your password must be at least 5 characters!");
		Dialog_Show(playerid, PasswordDialog, DIALOG_STYLE_PASSWORD, "Change Password", "Please change your password", "Okay", "");
	}
	return true;
}