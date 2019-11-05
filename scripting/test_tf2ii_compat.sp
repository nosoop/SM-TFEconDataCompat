/**
 * TF2ItemsInfo compabitility tests.
 */
#pragma semicolon 1
#include <sourcemod>

#include <tf2itemsinfo>

#pragma newdecls required

#include <testing>

#define TF_ITEMDEF_SANDMAN 44
#define TF_ITEMDEF_AMBASSADOR 61
#define TF_ITEMDEF_HALLOWEEN_MASK 115
#define TF_ITEMDEF_SPINE_CHILLING_SKULL 287
#define TF_ITEMDEF_UPG_PDA_ENG_BUILD 737
#define TF_ITEMDEF_MUCOUS_MEMBRAIN 30235
#define TF_ITEMDEF_POCKET_RAIDERS 30607
#define TF_ITEMDEF_INVALID 131072

#define TF_ITEMDEF_DECODER_RING 5021
#define TF_ITEMDEF_PAINTKIT_301 16301

#define TF_ATTRDEF_DAMAGEBONUS 2

public void OnAllPluginsLoaded() {
	TryRunTests();
}

public int TF2II_OnItemSchemaUpdated() {
	TryRunTests();
}

static void TryRunTests() {
	static bool s_bSchemaPrecached;
	static bool s_bFinishedTests;
	
	// only run the first time the schema is available
	s_bSchemaPrecached = TF2II_IsItemSchemaPrecached();
	if (!s_bSchemaPrecached || s_bFinishedTests) {
		return;
	}
	
	TestItemInformation();
	TestQualities();
	TestAttributes();
	TestHolidayRestrictions();
	TestEquipRegions();
	TestToolTypes();
	
	TestEdgeCases();
	
	s_bFinishedTests = true;
}

void TestItemInformation() {
	SetTestContext("Item info");
	
	AssertTrue("Item def. 44 is valid", TF2II_IsValidItemID(TF_ITEMDEF_SANDMAN));
	AssertFalse("Item def. 32769 is valid", TF2II_IsValidItemID(TF_ITEMDEF_INVALID));
	AssertFalse("Item def. -1 is valid", TF2II_IsValidItemID(-1));
	
	char itemName[64];
	TF2II_GetItemName(TF_ITEMDEF_SANDMAN, itemName, sizeof(itemName));
	AssertTrue("Name", StrEqual(itemName, "The Sandman"));
	
	char itemClass[64];
	TF2II_GetItemClass(TF_ITEMDEF_SANDMAN, itemClass, sizeof(itemClass));
	AssertTrue("Class", StrEqual(itemClass, "tf_weapon_bat_wood"));
	
	char itemSlot[64];
	TF2II_GetItemSlotName(TF_ITEMDEF_SANDMAN, itemSlot, sizeof(itemSlot));
	AssertTrue("Slot", StrEqual(itemSlot, "melee"));
	
	AssertTrue("Sandman usable by Scout",
			TF2II_IsItemUsedByClass(TF_ITEMDEF_SANDMAN, TFClass_Scout));
	AssertFalse("Sandman usable by Spy",
			TF2II_IsItemUsedByClass(TF_ITEMDEF_SANDMAN, TFClass_Spy));
	
	// correct method to get item level
	int iMinLevel = TF2II_GetItemMinLevel(TF_ITEMDEF_SANDMAN);
	AssertTrue("Minimum level", iMinLevel == 15);
	
	int iMaxLevel = TF2II_GetItemMinLevel(TF_ITEMDEF_SANDMAN);
	AssertTrue("Maximum level", iMaxLevel == 15);
	
	char qualityStr[32];
	TF2II_GetItemQualityName(TF_ITEMDEF_SANDMAN, qualityStr, sizeof(qualityStr));
	AssertTrue("Quality string", StrEqual(qualityStr, "unique"));
}

void TestQualities() {
	SetTestContext("Qualities");
	
	AssertTrue("'unique' to value", TF2II_GetQualityByName("unique") == 6);
	AssertTrue("'strange' to value", TF2II_GetQualityByName("strange") == 11);
}

void TestAttributes() {
	SetTestContext("Attributes");
	
	AssertTrue("Name to index", TF2II_GetAttributeIDByName("damage penalty") == 1);
	
	char attributeName[128];
	TF2II_GetAttributeNameByID(TF_ATTRDEF_DAMAGEBONUS, attributeName, sizeof(attributeName));
	AssertTrue("Index to name", StrEqual(attributeName, "damage bonus"));
}

void TestHolidayRestrictions() {
	SetTestContext("Holidays");

	// TF2II needs to be recompiled since TFHoliday enum was converted to pubvars at some point
	AssertFalse("Mask = Birthday",
			TF2II_ItemHolidayRestriction(TF_ITEMDEF_HALLOWEEN_MASK, TFHoliday_Birthday));
	AssertFalse("Mask = Christmas",
			TF2II_ItemHolidayRestriction(TF_ITEMDEF_HALLOWEEN_MASK, TFHoliday_Christmas));
	AssertTrue("Mask = Halloween",
			TF2II_ItemHolidayRestriction(TF_ITEMDEF_HALLOWEEN_MASK, TFHoliday_Halloween));
	AssertTrue("Mask = FullMoon",
			TF2II_ItemHolidayRestriction(TF_ITEMDEF_HALLOWEEN_MASK, TFHoliday_FullMoon));
	AssertTrue("Mask = HalloweenOrFullMoon",
			TF2II_ItemHolidayRestriction(TF_ITEMDEF_HALLOWEEN_MASK,
			TFHoliday_HalloweenOrFullMoon));
}

void TestEquipRegions() {
	SetTestContext("Equip regions");
	
	char equipRegion[16];
	ArrayList equipRegions = view_as<ArrayList>(
			TF2II_GetItemEquipRegions(TF_ITEMDEF_SPINE_CHILLING_SKULL));
	
	equipRegions.GetString(0, equipRegion, sizeof(equipRegion));
	AssertTrue("'Spine Chilling Skull' region = 'hat'", StrEqual("hat", equipRegion));
	
	delete equipRegions;
	
	// bug: valve used "equip_region" instead of "equip_regions" for the section name
	// as a result the game treats the item as having zero equip regions
	// tf2ii outputs one 'hat' region (does not include 'pyro_head_replacement')
	equipRegions = view_as<ArrayList>(TF2II_GetItemEquipRegions(TF_ITEMDEF_MUCOUS_MEMBRAIN));
	// AssertTrue("'The Mucous Membrain' has zero regions", equipRegions.Length == 0);
	
	delete equipRegions;
	
	// note that shared equip regions will contain all matching groups
	// tf2ii doesn't check for shared regions
	equipRegions = view_as<ArrayList>(TF2II_GetItemEquipRegions(TF_ITEMDEF_POCKET_RAIDERS));
	AssertTrue("'Pocket Raiders' region has 'sniper_pocket'",
			equipRegions.FindString("sniper_pocket") != -1);
	AssertTrue("'Pocket Raiders' region has 'engineer_pocket'",
			equipRegions.FindString("engineer_pocket") != -1);
	AssertTrue("'Pocket Raiders' region has 'grenades'",
			equipRegions.FindString("grenades") != -1);
	
	delete equipRegions;
	
	AssertFalse("'arms' region conflict with 'face'", TF2II_IsConflictRegions("arms", "face")); 
	AssertTrue("'whole_head' region conflict with 'face'",
			TF2II_IsConflictRegions("whole_head", "face")); 
	
}

void TestToolTypes() {
	char toolType[64];
	
	TF2II_GetToolType(TF_ITEMDEF_PAINTKIT_301, toolType, sizeof(toolType));
	AssertTrue("'Paintkit 301' tooltype is 'paintkit'", StrEqual(toolType, "paintkit"));
	
	TF2II_GetToolType(TF_ITEMDEF_DECODER_RING, toolType, sizeof(toolType));
	AssertTrue("'Decoder Ring' tooltype is 'decoder_ring'", StrEqual(toolType, "decoder_ring"));
}

void TestEdgeCases() {
	SetTestContext("Edge case");
	
	char itemSlot[64];
	TF2II_GetItemSlotName(TF_ITEMDEF_AMBASSADOR, itemSlot, sizeof(itemSlot));
	AssertTrue("Ambassador slot == 'primary'", StrEqual(itemSlot, "primary"));
	
	TF2II_GetListedItemSlotName(TF_ITEMDEF_AMBASSADOR, itemSlot, sizeof(itemSlot));
	AssertTrue("Ambassador listed slot == 'secondary'", StrEqual(itemSlot, "secondary"));
	
	TF2II_GetItemSlotName(TF_ITEMDEF_UPG_PDA_ENG_BUILD, itemSlot, sizeof(itemSlot));
	AssertTrue("Engineer PDA == 'pda'", StrEqual(itemSlot, "pda"));
}
