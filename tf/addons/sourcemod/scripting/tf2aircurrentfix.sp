#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION 		"1.0.0"

public Plugin myinfo =
{
	name = "[TF2] Air Current Fix",
	author = "Scag",
	description = "Vaaaaalve",
	version = PLUGIN_VERSION,
	url = ""
};

ConVar
	hTime
;

int
	m_Shared
;

public void OnPluginStart()
{
	if (!LookupOffset(m_Shared, "CTFPlayer", "m_Shared"))
		SetFailState("Could not look up offset for CTFPlayer::m_Shared!");

	hTime = CreateConVar("sm_aircurrent_time", "1.0", "Aircurrent time until removal.", FCVAR_NOTIFY, true, 0.0);

	AutoExecConfig(true, "tf2aircurrentfix");

	for (int i = MaxClients; i; --i)
		if (IsClientInGame(i))
			OnClientPutInServer(i);
}
/*
	TF2_OnConditionAdded doesn't fire for AirCurrent if you're already in the condition, 
	thus the time would go back to -1.0 :(
*/
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PreThink, OnThink);
}

public void OnThink(int client)
{
	if (TF2_GetConditionDuration(client, TFCond_AirCurrent) == -1.0)
		TF2_SetConditionDuration(client, TFCond_AirCurrent, hTime.FloatValue);
}

stock bool LookupOffset(int &offset, const char[] classname, const char[] propname)
{
	return (offset = FindSendPropInfo(classname, propname)) > 0;
}
// --> Pelipoika \o/
stock float TF2_GetConditionDuration(const int client, const TFCond cond)
{
	if (!TF2_IsPlayerInCondition(client, cond))
		return 0.0;

	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	return view_as< float >(LoadFromAddress(aCondDuration, NumberType_Int32));
}

stock void TF2_SetConditionDuration(const int client, const TFCond cond, const float time)
{
	if (!TF2_IsPlayerInCondition(client, cond))
		return;

	Address aCondSource   = view_as< Address >(LoadFromAddress(GetEntityAddress(client) + view_as< Address >(m_Shared + 8), NumberType_Int32));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	StoreToAddress(aCondDuration, view_as< int >(time), NumberType_Int32);
}