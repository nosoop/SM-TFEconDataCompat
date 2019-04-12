/**
 * [TF2] Econ Data Compatibility Shim
 * 
 * Masquerading as TF2IDB, TF2II, or both.  At the same time.
 */
#pragma semicolon 1
#include <sourcemod>

#pragma newdecls required

#include <tf_econ_data>

#define PLUGIN_VERSION "0.0.0"
public Plugin myinfo = {
	name = "[TF2] Econ Data Compatibility Layer for TF2II and TF2IDB",
	author = "nosoop",
	description = "Mostly drop-in compatibility layer for older "
			... "item schema-accessing libraries.",
	version = PLUGIN_VERSION,
	url = "localhost"
}

public void OnPluginStart() {
	char pluginFilePath[PLATFORM_MAX_PATH];
	GetPluginFilename(INVALID_HANDLE, pluginFilePath, sizeof(pluginFilePath));
	
	// register it under only one specific library if this plugin was renamed
	// this is intended to force a specific mode for plugins that can use both
	if (StrContains(pluginFilePath, "tf2idb") != -1) {
		RegisterTF2IDB();
	} else if (StrContains(pluginFilePath, "tf2itemsinfo") != -1) {
		RegisterTF2ItemsInfo();
	} else {
		RegisterTF2IDB();
		RegisterTF2ItemsInfo();
	}
}

void RegisterTF2IDB() {
	RegPluginLibrary("tf2idb");
	CreateConVar("sm_tf2idb_version", "0.94.0-econdata-shim-" ... PLUGIN_VERSION,
			"TF2IDB version");
}

void RegisterTF2ItemsInfo() {
	RegPluginLibrary("tf2itemsinfo");
	CreateConVar("sm_tf2ii_version", "1.9.1-econdata-shim-" ... PLUGIN_VERSION,
			"TF2 Items Info Plugin Version");
}
