/**
 * [TF2] Econ Data Compatibility Shim
 * 
 * Masquerading as TF2IDB, TF2II, or both.  At the same time.
 */
#pragma semicolon 1
#include <sourcemod>

#pragma newdecls required

#include <tf_econ_data>
#include <stocksoup/handles>

// TF2IDB stub's database creation stores a bunch of stuff on the heap
#pragma dynamic 524288

#define PLUGIN_VERSION "0.7.2"
public Plugin myinfo = {
	name = "[TF2] Econ Data Compatibility Layer for TF2II and TF2IDB",
	author = "nosoop",
	description = "Mostly drop-in compatibility layer for older "
			... "item schema-accessing libraries.",
	version = PLUGIN_VERSION,
	url = "https://github.com/nosoop/SM-TFEconDataCompat"
}

#include "tf_econ_data_compat/common.sp"
#include "tf_econ_data_compat/tf2idb.sp"
#include "tf_econ_data_compat/tf2itemsinfo.sp"

#define COMPAT_MODE_TF2II  (1 << 0)
#define COMPAT_MODE_TF2IDB (1 << 1)

int g_fCompatMode;

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int maxlen) {
	char pluginFilePath[PLATFORM_MAX_PATH];
	GetPluginFilename(INVALID_HANDLE, pluginFilePath, sizeof(pluginFilePath));
	
	// register it under only one specific library if this plugin was renamed
	// this is intended to force a specific mode for plugins that can use both
	if (StrContains(pluginFilePath, "tf2idb") != -1) {
		RegisterTF2IDB();
		PrintToServer("[tfeconcompat] Registered as TF2IDB.");
	} else if (StrContains(pluginFilePath, "tf2itemsinfo") != -1) {
		PrintToServer("[tfeconcompat] Registered as TF2II.");
		RegisterTF2ItemsInfo();
	} else {
		PrintToServer("[tfeconcompat] Registered as both TF2II and TF2IDB.");
		RegisterTF2IDB();
		RegisterTF2ItemsInfo();
	}
	return APLRes_Success;
}

public void OnAllPluginsLoaded() {
	if (g_fCompatMode & COMPAT_MODE_TF2IDB) {
		g_Database = TF2IDB_BuildDatabase();
	}
	if (g_fCompatMode & COMPAT_MODE_TF2II) {
		Call_StartForward(g_FwdItemInfoOnSchemaUpdate);
		Call_Finish();
	}
}

void RegisterTF2IDB() {
	RegPluginLibrary("tf2idb");
	CreateConVar("sm_tf2idb_version", "0.94.0-econdata-shim-" ... PLUGIN_VERSION,
			"TF2IDB version", .flags = FCVAR_NOTIFY);
	
	CreateNative("TF2IDB_IsValidItemID", Native_Common_IsValidItemID);
	CreateNative("TF2IDB_GetItemName", Native_Common_GetItemName);
	CreateNative("TF2IDB_GetItemClass", Native_Common_GetItemClassName);
	CreateNative("TF2IDB_GetItemSlotName", Native_Common_GetLegacyItemSlotName);
	CreateNative("TF2IDB_GetItemSlot", Native_Common_GetLegacyItemSlot);
	
	// TF2IDB_GetItemQualityName() has no equivalent
	CreateNative("TF2IDB_GetItemQualityName", Native_Common_GetItemQualityName);
	
	// TF2IDB_GetItemQuality() requires memory access
	CreateNative("TF2IDB_GetItemQuality", Native_Common_GetItemQuality);
	
	// TF2IDB_GetItemLevels() maps directly to TF2Econ_GetItemLevelRange()
	CreateNative("TF2IDB_GetItemLevels", Native_TF2IDB_GetItemLevels);
	
	// TF2IDB_GetItemAttributes() can be done by translating the output of TF2Econ_GetItemStaticAttributes() from a key / valur pair array into separate keys / values arrays.
	CreateNative("TF2IDB_GetItemAttributes", Native_TF2IDB_GetItemAttributes);
	
	// TF2IDB_GetItemEquipRegions() has no equivalent
	CreateNative("TF2IDB_GetItemEquipRegions", Native_Common_GetItemEquipRegions);
	
	// TF2IDB_DoRegionsConflict() has no equivalent
	CreateNative("TF2IDB_DoRegionsConflict", Native_Common_DoRegionsConflict);
	
	// TF2IDB_ListParticles() is basically TF2Econ_GetParticleAttributeList() with some filters
	CreateNative("TF2IDB_ListParticles", Native_TF2IDB_ListParticles);
	
	// TF2IDB_ItemHasAttribute() can be done by calling TF2Econ_GetItemStaticAttributes() and checking for the attribute ID in the first block
	CreateNative("TF2IDB_ItemHasAttribute", Native_TF2IDB_ItemHasAttribute);
	
	// TF2IDB_UsedByClasses() can be done by iterating over TFClassType and checking the result of TF2Econ_GetItemSlot()
	CreateNative("TF2IDB_UsedByClasses", Native_TF2IDB_UsedByClasses);
	
	// TF2IDB_IsValidAttributeID() maps directly to TF2Econ_IsValidAttributeDefinition()
	CreateNative("TF2IDB_IsValidAttributeID", Native_Common_IsValidAttributeDefinition);
	
	// TF2IDB_GetAttributeName() maps directly to TF2Econ_GetAttributeName()
	CreateNative("TF2IDB_GetAttributeName", Native_Common_GetAttributeName);
	
	// TF2IDB_GetAttributeClass() maps directly to TF2Econ_GetAttributeClassName()
	CreateNative("TF2IDB_GetAttributeClass", Native_Common_GetAttributeClassName);
	
	// TF2IDB_GetAttributeType() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "attribute_type", ...)
	CreateNative("TF2IDB_GetAttributeType", Native_TF2IDB_GetAttributeType);
	
	// TF2IDB_GetAttributeDescString() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "description_string", ...)
	CreateNative("TF2IDB_GetAttributeDescString", Native_Common_GetAttributeDescriptionString);
	
	// TF2IDB_GetAttributeDescFormat() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "description_format", ...)
	CreateNative("TF2IDB_GetAttributeDescFormat", Native_Common_GetAttributeDescriptionFormat);
	
	// TF2IDB_GetAttributeEffectType() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "effect_type", ...)
	CreateNative("TF2IDB_GetAttributeEffectType", Native_TF2IDB_GetAttributeEffectType);
	
	// TF2IDB_GetAttributeArmoryDesc() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "armory_desc", ...)
	CreateNative("TF2IDB_GetAttributeArmoryDesc", Native_TF2IDB_GetAttributeArmoryDesc);
	
	// TF2IDB_GetAttributeItemTag() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "apply_tag_to_item_definition", ...)
	CreateNative("TF2IDB_GetAttributeItemTag", Native_TF2IDB_GetAttributeItemTag);
	
	// TF2IDB_GetAttributeProperties() can be done by parsing out the appropriate data.
	CreateNative("TF2IDB_GetAttributeProperties", Native_TF2IDB_GetAttributeProperties);
	
	// TF2IDB_GetQualityName() maps directly to TF2Econ_GetQualityName()
	CreateNative("TF2IDB_GetQualityName", Native_Common_GetQualityName);
	
	// TF2IDB_GetQualityByName() maps directly to TF2Econ_TranslateQualityNameToValue()
	CreateNative("TF2IDB_GetQualityByName", Native_Common_GetQualityByName);
	
	/**
	 * TODO: Instantiate an in-memory or file-backed database when we need to use actual SQLite
	 * queries the first time.
	 */
	CreateNative("TF2IDB_FindItemCustom", Native_TF2IDB_FindItemCustom);
	CreateNative("TF2IDB_CustomQuery", Native_TF2IDB_CustomQuery);
	
	g_fCompatMode |= COMPAT_MODE_TF2IDB;
}

void RegisterTF2ItemsInfo() {
	RegPluginLibrary("tf2itemsinfo");
	CreateConVar("sm_tf2ii_version", "1.9.1-econdata-shim-" ... PLUGIN_VERSION,
			"TF2 Items Info Plugin Version", .flags = FCVAR_NOTIFY);
	
	CreateNative("TF2II_IsItemSchemaPrecached", Native_ItemInfo_IsSchemaPrecached);
	
	CreateNative("TF2II_IsValidItemID", Native_Common_IsValidItemID);
	CreateNative("TF2II_GetItemName", Native_Common_GetItemName);
	CreateNative("TF2II_GetItemClass", Native_TF2II_GetItemClassName);
	
	//TF2II_ItemHasProperty() can be done with calls to TF2Econ_GetItemDefinitionString()
	CreateNative("TF2II_ItemHasProperty", Native_ItemInfo_ItemHasProperty);
	
	//TF2II_GetItemSlot() maps partially to TF2Econ_GetItemSlot() except it maps tf_weapon_revolver to primary
	CreateNative("TF2II_GetItemSlot", Native_TF2II_GetItemSlot);
	CreateNative("TF2II_GetItemSlotName", Native_TF2II_GetItemSlotName);
	
	//TF2II_GetListedItemSlot() maps directly to item_slot with translation to index
	CreateNative("TF2II_GetListedItemSlot", Native_Common_GetLegacyItemSlot);
	
	//TF2II_GetListedItemSlotName() maps directly to TF2Econ_GetItemDefinitionString(defindex, "item_slot", ...)
	CreateNative("TF2II_GetListedItemSlotName", Native_Common_GetLegacyItemSlotName);
	
	//TF2II_IsItemUsedByClass() can be done by checking if TF2Econ_GetItemSlot() returns -1 for the given player class.
	CreateNative("TF2II_IsItemUsedByClass", Native_TF2II_IsItemUsedByClass);
	
	//TF2II_GetItemMinLevel() and TF2II_GetItemMaxLevel() can be done by passing in integer variables by-ref to TF2Econ_GetItemLevelRange()
	CreateNative("TF2II_GetItemMinLevel", Native_ItemInfo_GetItemMinLevel);
	CreateNative("TF2II_GetItemMaxLevel", Native_ItemInfo_GetItemMaxLevel);
	
	//TF2II_GetItemQuality() requires memory access
	CreateNative("TF2II_GetItemQuality", Native_Common_GetItemQuality);
	
	//TF2II_GetItemQualityName() has no equivalent
	CreateNative("TF2II_GetItemQualityName", Native_Common_GetItemQualityName);
	
	//TF2II_GetItemNumAttributes() can be done by getting the length of the ArrayList returned from TF2Econ_GetItemStaticAttributes().
	CreateNative("TF2II_GetItemNumAttributes", Native_TF2II_GetItemNumAttributes);
	
	//TF2II_GetItemAttributeName() can be done by getting the attribute ID from the ArrayList returned from TF2Econ_GetItemStaticAttributes(), calling TF2Econ_GetAttributeName() to get the name.
	CreateNative("TF2II_GetItemAttributeName", Native_NotImplemented);
	
	//TF2II_GetItemAttributeID() can be done by getting the attribute ID from the ArrayList returned from TF2Econ_GetItemStaticAttributes().
	CreateNative("TF2II_GetItemAttributeID", Native_TF2II_GetItemAttributeID);
	
	//TF2II_GetItemAttributeValue() can be done by getting the attribute value from TF2Econ_GetItemStaticAttributes(). This returns a raw 32-bit value; if the attribute is a string / vector you'll probably be better off calling TF2Econ_GetItemDefinitionString(defindex, "static_attrs/${attr}", ...) with the attribute name.
	CreateNative("TF2II_GetItemAttributeValue", Native_TF2II_GetItemAttributeValue);
	
	//TF2II_GetItemAttributes() cab be done with TF2Econ_GetItemStaticAttributes(). I have no idea how their ArrayList is laid out, though.
	CreateNative("TF2II_GetItemAttributes", Native_NotImplemented);
	
	//TF2II_GetToolType() can be done with TF2Econ_GetItemDefinitionString(defindex, "tool/type", ...)
	CreateNative("TF2II_GetToolType", Native_TF2II_GetToolType);
	
	//TF2II_ItemHolidayRestriction() can be done with TF2Econ_GetItemDefinitionString(defindex, "holiday_restriction", ...) and checking the string for your holiday
	CreateNative("TF2II_ItemHolidayRestriction", Native_TF2II_ItemHolidayRestriction);
	
	//TF2II_GetItemEquipRegions() has no equivalent
	CreateNative("TF2II_GetItemEquipRegions", Native_Common_GetItemEquipRegions);
	
	//TF2II_IsValidAttribID() maps directly to TF2Econ_IsValidAttributeDefinition()
	CreateNative("TF2II_IsValidAttribID", Native_Common_IsValidAttributeDefinition);
	
	//TF2II_GetAttribName() maps directly to TF2Econ_GetAttributeName()
	CreateNative("TF2II_GetAttribName", Native_Common_GetAttributeName);
	
	//TF2II_GetAttribClass() maps directly to TF2Econ_GetAttributeClassName()
	CreateNative("TF2II_GetAttribClass", Native_Common_GetAttributeClassName);
	
	//TF2II_GetAttribDispName() is deprecated — the game doesn't use attribute_name at all.
	CreateNative("TF2II_GetAttribDispName", Native_NotImplemented);
	
	//TF2II_GetAttribMinValue() is deprecated — the game doesn't use min_value at all.
	CreateNative("TF2II_GetAttribMinValue", Native_NotImplemented);
	
	//TF2II_GetAttribMaxValue() is deprecated — the game doesn't use max_value at all.
	CreateNative("TF2II_GetAttribMaxValue", Native_NotImplemented);
	
	//TF2II_GetAttribGroup() is deprecated. I have no idea what it originally was.
	CreateNative("TF2II_GetAttribGroup", Native_NotImplemented);
	
	//TF2II_GetAttribDescrString() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "description_string", ...)
	CreateNative("TF2II_GetAttribDescrString", Native_Common_GetAttributeDescriptionString);
	
	//TF2II_GetAttribDescrFormat() can be done with TF2Econ_GetAttributeDefinitionString(defindex, "description_format", ...)
	CreateNative("TF2II_GetAttribDescrFormat", Native_Common_GetAttributeDescriptionFormat);
	
	//TF2II_HiddenAttrib() maps directly to TF2Econ_IsAttributeHidden()
	CreateNative("TF2II_HiddenAttrib", Native_ItemInfo_IsAttributeHidden);
	
	//TF2II_GetAttribEffectType() can be done by calling TF2Econ_GetAttributeDefinitionString(defindex, "effect_type", ...) and mapping the results to the appropriate numbers.
	CreateNative("TF2II_GetAttribEffectType", Native_ItemInfo_GetAttributeEffectType);
	
	//TF2II_AttribStoredAsInteger() maps directly to TF2Econ_IsAttributeStoredAsInteger()
	CreateNative("TF2II_AttribStoredAsInteger", Native_NotImplemented);
	
	//TF2II_GetItemKeyValues() has no equivalent, but if you know the key(s) you're looking for you can use TF2Econ_GetItemDefinitionString()
	CreateNative("TF2II_GetItemKeyValues", Native_NotImplemented);
	
	//TF2II_GetItemKey() can be done by running StringToInt on the output of TF2Econ_GetItemDefinitionString()
	CreateNative("TF2II_GetItemKey", Native_NotImplemented);
	
	//TF2II_GetItemKeyFloat() can be done by running StringToFloat on the output of TF2Econ_GetItemDefinitionString()
	CreateNative("TF2II_GetItemKeyFloat", Native_NotImplemented);
	
	//TF2II_GetItemKeyString() maps directly to TF2Econ_GetItemDefinitionString() (with an optional default value as an additional argument)
	CreateNative("TF2II_GetItemKeyString", Native_NotImplemented);
	
	//TF2II_GetAttribKeyValues() has no equivalent, but if you know the key(s) you're looking for you can use TF2Econ_GetAttributeDefinitionString()
	CreateNative("TF2II_GetAttribKeyValues", Native_NotImplemented);
	
	//TF2II_GetAttribKey() can be done by running StringToInt on the output of TF2Econ_GetAttributeDefinitionString()
	CreateNative("TF2II_GetAttribKey", Native_NotImplemented);
	
	//TF2II_GetAttribKeyFloat() can be done by running StringToFloat on the output of TF2Econ_GetAttributeDefinitionString()
	CreateNative("TF2II_GetAttribKeyFloat", Native_NotImplemented);
	
	//TF2II_GetAttribKeyString() maps directly to TF2Econ_GetAttributeDefinitionString() (with an optional default value as an additional argument)
	CreateNative("TF2II_GetAttribKeyString", Native_NotImplemented);
	
	//TF2II_IsConflictRegions() has no equivalent
	CreateNative("TF2II_IsConflictRegions", Native_Common_DoRegionsConflict);
	
	//TF2II_GetQualityByName() maps directly to TF2Econ_TranslateQualityNameToValue()
	CreateNative("TF2II_GetQualityByName", Native_Common_GetQualityByName);
	
	//TF2II_GetQualityName() maps directly to TF2Econ_GetQualityName()
	CreateNative("TF2II_GetQualityName", Native_Common_GetQualityName);
	
	//TF2II_GetAttributeIDByName() maps directly to TF2Econ_TranslateAttributeNameToDefinitionIndex()
	CreateNative("TF2II_GetAttributeIDByName", Native_TF2II_GetAttributeIDByName);
	
	//TF2II_GetAttributeNameByID() maps directly to TF2Econ_GetAttributeName()
	CreateNative("TF2II_GetAttributeNameByID", Native_TF2II_GetAttributeNameByID);
	
	//TF2II_FindItems() can be done with TF2Econ_GetItemList() and a user-defined function to filter the results
	CreateNative("TF2II_FindItems", Native_TF2II_FindItems);
	
	//TF2II_ListEffects() and TF2II_ListAttachableEffects() has no equivalent
	CreateNative("TF2II_ListEffects", Native_ItemInfo_ListEffects);
	CreateNative("TF2II_ListAttachableEffects", Native_ItemInfo_ListEffects);
	
	g_FwdItemInfoOnSchemaUpdate = CreateGlobalForward("TF2II_OnItemSchemaUpdated", ET_Ignore);
	
	g_FwdOnFindItems = CreateGlobalForward("TF2II_OnFindItems", ET_Ignore, Param_String,
			Param_String, Param_Cell, Param_String, Param_CellByRef);
	
	// should we even implement OnSearchCommand? seems like it's only relevant to clients
	
	g_fCompatMode |= COMPAT_MODE_TF2II;
}

public int Native_NotImplemented(Handle hPlugin, int nParams) {
	ThrowNativeError(-127, "Native not implemented in compatibility shim");
	return 0;
}
