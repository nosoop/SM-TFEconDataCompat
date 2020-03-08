/**
 * Sourcemod 1.7 Plugin Template
 */
#pragma semicolon 1
#include <sourcemod>

#include <tf2idb>
#include <testing>

#pragma newdecls required

public void OnAllPluginsLoaded() {
	TryRunTests();
}

static void TryRunTests() {
	static bool s_bFinishedTests;
	
	// only run the first time the schema is available
	if (s_bFinishedTests) {
		return;
	}
	
	TestMedievalOrMeleeQuery();
	TestHeavyMeleeQuery();
	
	s_bFinishedTests = true;
}

void TestMedievalOrMeleeQuery() {
	SetTestContext("Medieval or Melee query");
	ArrayList items = TF2IDB_FindItemCustom("SELECT a.id FROM tf2idb_item a JOIN tf2idb_item_attributes b ON a.id=b.id WHERE has_string_attribute=0 AND (attribute=2029 OR slot='melee') GROUP BY a.id");
	AssertTrue("Tide Turner in set", items.FindValue(1099) != -1);
	
	delete items;
}

void TestHeavyMeleeQuery() {
	SetTestContext("Heavy Melee query");
	
	ArrayList items = TF2IDB_FindItemCustom("SELECT a.id FROM tf2idb_item a JOIN tf2idb_class b ON a.id=b.id WHERE b.class='heavy' AND b.slot='melee'");
	AssertTrue("Holiday Punch in set", items.FindValue(656) != -1);
	delete items;
}


// public void OnLibraryAdded(const char[] name) {
	// if (StrEqual(name, "tf2idb")) {
		// TryRunTests();
	// }
// }
