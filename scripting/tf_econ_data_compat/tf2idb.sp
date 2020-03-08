#define TF2IDB_MAX_ATTRS 20

enum DatabaseState {
	Database_IsCurrent,
	Database_Unavailable,
	Database_Stale
};

Database g_Database;

/**
 * bool TF2IDB_GetItemLevels(int defindex, int& min, int& max);
 */
public int Native_TF2IDB_GetItemLevels(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	
	int min, max;
	bool bResult = TF2Econ_GetItemLevelRange(defindex, min, max);
	
	SetNativeCellRef(2, min);
	SetNativeCellRef(3, max);
	return bResult;
}

/**
 * int TF2IDB_UsedByClasses(int defindex);
 */
public int Native_TF2IDB_UsedByClasses(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	
	int result;
	for (TFClassType i; i < TFClassType; i++) {
		if (TF2Econ_GetItemSlot(defindex, i) != -1) {
			result |= (1 << view_as<int>(i));
		}
	}
	return result;
}

/**
 * bool TF2IDB_GetAttributeEffectType(int defindex, char[] buffer, int maxlen);
 */
public int Native_TF2IDB_GetAttributeEffectType(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeDefinitionString(attrdef, "effect_type", buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * int TF2IDB_GetItemAttributes(int defindex, int aid[TF2IDB_MAX_ATTRS], float values[TF2IDB_MAX_ATTRS]);
 */
public int Native_TF2IDB_GetItemAttributes(Handle hPlugin, int nParams) {
	int attribids[TF2IDB_MAX_ATTRS];
	float attribvalues[TF2IDB_MAX_ATTRS];
	
	int defindex = GetNativeCell(1);
	ArrayList staticAttributes = TF2Econ_GetItemStaticAttributes(defindex);
	int a;
	for (int i; i < staticAttributes.Length && i < TF2IDB_MAX_ATTRS; i++) {
		attribids[i] = staticAttributes.Get(i, .block = 0);
		attribvalues[i] = staticAttributes.Get(i, .block = 1);
		a++;
	}
	delete staticAttributes;
	
	SetNativeArray(2, attribids, TF2IDB_MAX_ATTRS);
	SetNativeArray(3, attribvalues, TF2IDB_MAX_ATTRS);
	
	return a;
}

/**
 * ArrayList TF2IDB_ListParticles();
 */
public int Native_TF2IDB_ListParticles(Handle hPlugin, int nParams) {
	ArrayList cosmeticParticles =
			TF2Econ_GetParticleAttributeList(ParticleSet_CosmeticUnusualEffects);
	
	// ignore map stamps and pipe smoke -- all other ones that were filtered in TF2IDB are in
	// other effect sets
	int index = -1;
	if ((index = cosmeticParticles.FindValue(20)) != -1) {
		cosmeticParticles.Erase(index);
	}
	if ((index = cosmeticParticles.FindValue(28)) != -1) {
		cosmeticParticles.Erase(index);
	}
	
	return MoveHandle(cosmeticParticles, hPlugin);
}

/**
 * bool TF2IDB_ItemHasAttribute(int defindex, int attrdef);
 */
public int Native_TF2IDB_ItemHasAttribute(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int attrdef = GetNativeCell(2);
	
	ArrayList staticAttributes = TF2Econ_GetItemStaticAttributes(defindex);
	bool result = staticAttributes.FindValue(attrdef) != -1;
	delete staticAttributes;
	
	return result;
}

/**
 * bool TF2IDB_GetAttributeType(int attrdef, char[] buffer, int maxlen);
 */
public int Native_TF2IDB_GetAttributeType(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeDefinitionString(attrdef, "attribute_type", buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2IDB_GetAttributeArmoryDesc(int attrdef, char[] buffer, int maxlen);
 */
public int Native_TF2IDB_GetAttributeArmoryDesc(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeDefinitionString(attrdef, "armory_desc", buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2IDB_GetAttributeItemTag(int attrdef, char[] buffer, int maxlen);
 */
public int Native_TF2IDB_GetAttributeItemTag(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeDefinitionString(attrdef, "apply_tag_to_item_definition",
			buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2IDB_GetAttributeProperties(int attrdef, int& hidden, int& stored_as_integer,
 *         int& is_set_bonus, int& is_user_generated, int& can_affect_recipe_component_name);
 */
public int Native_TF2IDB_GetAttributeProperties(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	
	if (!TF2Econ_IsValidAttributeDefinition(attrdef)) {
		return false;
	}
	
	SetNativeCellRef(2, TF2Econ_IsAttributeHidden(attrdef));
	SetNativeCellRef(3, TF2Econ_IsAttributeStoredAsInteger(attrdef));
	
	char buffer[32];
	TF2Econ_GetAttributeDefinitionString(attrdef, "is_set_bonus", buffer, sizeof(buffer), "0");
	SetNativeCellRef(4, StringToInt(buffer));
	
	TF2Econ_GetAttributeDefinitionString(attrdef, "is_user_generated",
			buffer, sizeof(buffer), "0");
	SetNativeCellRef(5, StringToInt(buffer));
	
	TF2Econ_GetAttributeDefinitionString(attrdef, "can_affect_market_name",
			buffer, sizeof(buffer), "0");
	SetNativeCellRef(6, StringToInt(buffer));
	
	return true;
}

/**
 * ArrayList<int>? TF2IDB_FindItemCustom(const char[] query);
 */
public int Native_TF2IDB_FindItemCustom(Handle hPlugin, int nParams) {
	int length;
	GetNativeStringLength(1, length);
	
	char[] query = new char[++length];
	GetNativeString(1, query, length);
	
	DBResultSet results = SQL_Query(g_Database, query);
	if (!results) {
		return view_as<int>(INVALID_HANDLE);
	}
	ArrayList resultList = new ArrayList();
	while (results.FetchRow()) {
		resultList.Push(results.FetchInt(0));
	}
	delete results;
	return MoveHandle(resultList, hPlugin);
}

/**
 * DBStatement? TF2IDB_CustomQuery(const char[] query, ArrayList args, int maxlength);
 */
public int Native_TF2IDB_CustomQuery(Handle hPlugin, int nParams) {
	int length;
	GetNativeStringLength(1, length);
	
	char[] query = new char[++length];
	GetNativeString(1, query, length);
	
	char error[256];
	DBStatement dbQuery = SQL_PrepareQuery(g_Database, query, error, sizeof(error));
	
	ArrayList args = view_as<ArrayList>(GetNativeCell(2));
	char arglen = GetNativeCell(3); // we could deduce this from blocksize
	
	char[] argbuf = new char[arglen];
	for (int i; i < args.Length; i++) {
		args.GetString(i, argbuf, arglen);
		dbQuery.BindString(i, argbuf, true);
	}
	
	if (SQL_Execute(dbQuery)) {
		return view_as<int>(dbQuery);
	}
	delete dbQuery;
	return view_as<int>(INVALID_HANDLE);
}

#include <profiler>

/**
 * Returns a Database handle to the TF2IDB database, creating it if necessary.
 * This provides support for TF2IDB's TF2IDB_FindItemCustom and TF2IDB_CustomQuery natives.
 */
Database TF2IDB_BuildDatabase() {
	// compare database filetime; delete database if either plugin or items_game is newer
	DatabaseState state = GetDatabaseStatus();
	
	if (state == Database_Stale) {
		SQLite_DropDatabase("tf2idb");
	}
	
	char error[256];
	Database db = SQLite_UseDatabase("tf2idb", error, sizeof(error));
	if (!db) {
		SetFailState("Failed to use tf2idb.sq3: %s", error);
	}
	
	switch (state) {
		case Database_Unavailable: {
			PrintToServer("[tfeconcompat] Database does not exist.  Creating...");
		}
		case Database_Stale: {
			PrintToServer("[tfeconcompat] Database is outdated.  Rebuilding...");
		}
		default: {
			return db;
		}
	}
	
	Handle prof = CreateProfiler();
	StartProfiling(prof);
	
	// this implements the script from
	// https://github.com/FlaminSarge/tf2idb/tree/c2bc42e34c2a2e9a4e9ad0d0fe8cda564e970bb6
	
	if (!SQL_FastQuery(db, "CREATE TABLE tf2idb_class ("
			... "'id' INTEGER NOT NULL, "
			... "'class' TEXT NOT NULL, "
			... "'slot' TEXT, "
			... "PRIMARY KEY ('id', 'class'));")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_class: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE tf2idb_item_attributes ("
			... "'id' INTEGER NOT NULL, "
			... "'attribute' INTEGER NOT NULL, "
			... "'value' TEXT NOT NULL, "
			... "'static' INTEGER, "
			... "PRIMARY KEY ('id', 'attribute'));")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_item_attributes: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE tf2idb_item ("
			... "'id' INTEGER PRIMARY KEY NOT NULL, "
			... "'name' TEXT NOT NULL, "
			... "'item_name' TEXT, "
			... "'class' TEXT NOT NULL, "
			... "'slot' TEXT, "
			... "'quality' TEXT NOT NULL, "
			... "'tool_type' TEXT, "
			... "'min_ilevel' INTEGER, "
			... "'max_ilevel' INTEGER, "
			... "'baseitem' INTEGER, "
			... "'holiday_restriction' TEXT, "
			... "'has_string_attribute' INTEGER, "
			... "'propername' INTEGER);")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_item: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE 'tf2idb_particles' ("
			... "'id' INTEGER PRIMARY KEY NOT NULL , 'name' TEXT NOT NULL);")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_particles: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE 'tf2idb_equip_conflicts' ("
			... "'name' TEXT NOT NULL, "
			... "'region' TEXT NOT NULL, "
			... "PRIMARY KEY ('name', 'region'));")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_equip_conflicts: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE 'tf2idb_equip_regions' ("
			... "'id' INTEGER NOT NULL, "
			... "'region' TEXT NOT NULL, "
			... "PRIMARY KEY ('id', 'region'));")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_equip_regions: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE 'tf2idb_capabilities' ("
			... "'id' INTEGER NOT NULL , 'capability' TEXT NOT NULL)")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_capabilities: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE 'tf2idb_attributes' ("
			... "'id' INTEGER PRIMARY KEY NOT NULL, "
			... "'name' TEXT NOT NULL, "
			... "'attribute_class' TEXT, "
			... "'attribute_type' TEXT, "
			... "'description_string' TEXT, "
			... "'description_format' TEXT, "
			... "'effect_type' TEXT, "
			... "'hidden' INTEGER, "
			... "'stored_as_integer' INTEGER, "
			... "'armory_desc' TEXT, "
			... "'is_set_bonus' INTEGER, "
			... "'is_user_generated' INTEGER, "
			... "'can_affect_recipe_component_name' INTEGER, "
			... "'apply_tag_to_item_definition' TEXT);")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_attributes: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE TABLE 'tf2idb_qualities' ("
			... "'name' TEXT PRIMARY KEY NOT NULL, "
			... "'value' INTEGER NOT NULL );")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create table tf2idb_qualities: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE INDEX '__idx_tf2idb_item_attributes' "
			... "ON 'tf2idb_item_attributes' ('attribute' ASC);")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create index for tf2idb_item_attributes: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE INDEX '__idx_tf2idb_class' ON 'tf2idb_class'"
			... "('class' ASC)")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create index for tf2idb_class: %s", error);
	}
	
	if (!SQL_FastQuery(db, "CREATE INDEX '__idx_tf2idb_item' ON 'tf2idb_item'"
			... "('slot' ASC)")) {
		SQL_GetError(db, error, sizeof(error));
		SetFailState("Failed to create index for tf2idb_item: %s", error);
	}
	
	// quality handling
	{
		DBStatement qualityInsert = SQL_PrepareQuery(db,
				"INSERT INTO tf2idb_qualities (name, value) VALUES (?,?);",
				error, sizeof(error));
		if (!qualityInsert) {
			SetFailState("Failed to prepare tf2idb_qualities query: %s", error);
		}
		
		ArrayList qualityList = TF2Econ_GetQualityList();
		for (int i; i < qualityList.Length; i++) {
			char qualityName[64];
			int value = qualityList.Get(i);
			TF2Econ_GetQualityName(value, qualityName, sizeof(qualityName));
			
			qualityInsert.BindString(0, qualityName, .copy = false);
			qualityInsert.BindInt(1, value);
			
			SQL_Execute(qualityInsert);
		}
		delete qualityList;
		delete qualityInsert;
	}
	
	// particle handling
	{
		DBStatement particleInsert = SQL_PrepareQuery(db,
				"INSERT INTO tf2idb_particles (id,name) VALUES (?,?);",
				error, sizeof(error));
		if (!particleInsert) {
			SetFailState("Failed to prepare tf2idb_particles query: %s", error);
		}
		
		ArrayList allParticles = TF2Econ_GetParticleAttributeList();
		
		for (int i; i < allParticles.Length; i++) {
			int particleid = allParticles.Get(i);
			
			char system[64];
			TF2Econ_GetParticleAttributeSystemName(particleid, system, sizeof(system));
			
			particleInsert.BindInt(0, particleid);
			particleInsert.BindString(1, system, .copy = false);
			
			SQL_Execute(particleInsert);
		}
		
		delete allParticles;
		delete particleInsert;
	}
	
	// attribute handling
	StringMap stringTypedAttributes = new StringMap();
	{
		// TODO I guess we need a TF2Econ_GetAttributeList() for this...
		Transaction attrTxn = new Transaction();
		for (int attrdef; attrdef < 4096; attrdef++) {
			if (!TF2Econ_IsValidAttributeDefinition(attrdef)) {
				continue;
			}
			
			char name[128];
			TF2Econ_GetAttributeName(attrdef, name, sizeof(name));
			
			char attrClass[64];
			TF2Econ_GetAttributeClassName(attrdef, attrClass, sizeof(attrClass));
			
			char attrType[16];
			TF2Econ_GetAttributeDefinitionString(attrdef, "attribute_type", attrType,
					sizeof(attrType));
			
			char attrDesc[128];
			TF2Econ_GetAttributeDefinitionString(attrdef, "description_string",
					attrDesc, sizeof(attrDesc));
			
			char attrFmt[128];
			TF2Econ_GetAttributeDefinitionString(attrdef, "description_format",
					attrFmt, sizeof(attrFmt));
			
			char effectType[16];
			TF2Econ_GetAttributeDefinitionString(attrdef, "effect_type",
					effectType, sizeof(effectType));
			
			char attrArmoryDesc[32];
			TF2Econ_GetAttributeDefinitionString(attrdef, "armory_desc",
					attrArmoryDesc, sizeof(attrArmoryDesc));
			
			char appliedTag[64];
			TF2Econ_GetAttributeDefinitionString(attrdef, "apply_tag_to_item_definition",
					appliedTag, sizeof(appliedTag));
			
			if (StrEqual(attrType, "string")) {
				stringTypedAttributes.SetValue(name, true);
			}
			
			char query[2048];
			db.Format(query, sizeof(query), "INSERT INTO tf2idb_attributes "
					... "(id, name, attribute_class, attribute_type, description_string, "
					... "description_format, effect_type, hidden, stored_as_integer, "
					... "armory_desc, is_set_bonus, is_user_generated, "
					... "can_affect_recipe_component_name, apply_tag_to_item_definition) "
					... "VALUES (%d, '%s', '%s', '%s', '%s', '%s', '%s', %b, %b, '%s', "
					... "%b, %b, %b, '%s');",
					attrdef, name, attrClass, attrType, attrDesc,
					attrFmt, effectType, TF2Econ_IsAttributeHidden(attrdef),
					TF2Econ_IsAttributeStoredAsInteger(attrdef),
					attrArmoryDesc, !!_GetItemDefinitionInt(attrdef, "is_set_bonus"),
					!!_GetItemDefinitionInt(attrdef, "is_user_generated"),
					!!_GetItemDefinitionInt(attrdef, "can_affect_recipe_component_name"),
					appliedTag);
			attrTxn.AddQuery(query);
		}
		db.Execute(attrTxn, .onError = OnTransactionError);
	}
	
	// equipment conflicts
	{
		char query[512];
		Transaction regionTxn = new Transaction();
		
		// iterate group names, find masks, then convert to conflicting group names
		StringMap equipGroups = TF2Econ_GetEquipRegionGroups();
		StringMapSnapshot equipGroupNames = equipGroups.Snapshot();
		for (int i; i < equipGroupNames.Length; i++) {
			char groupName[64];
			equipGroupNames.GetKey(i, groupName, sizeof(groupName));
			
			int group, fConflicts;
			equipGroups.GetValue(groupName, group);
			
			TF2Econ_GetEquipRegionMask(groupName, fConflicts);
			
			// no known conflicts with anything other than itself (other groups might, though)
			if (fConflicts & ~(1 << group) == 0) {
				continue;
			}
			
			// determine the groups for the other conflicting bits
			for (int j; j < equipGroupNames.Length; j++) {
				char conflictGroupName[64];
				equipGroupNames.GetKey(j, conflictGroupName, sizeof(conflictGroupName));
				
				int conflictGroup;
				equipGroups.GetValue(conflictGroupName, conflictGroup);
				
				if (fConflicts & (1 << conflictGroup) == 0 || group == conflictGroup) {
					continue;
				}
				
				db.Format(query, sizeof(query), "INSERT INTO tf2idb_equip_conflicts "
						... "(name, region) VALUES ('%s', '%s');",
						groupName, conflictGroupName);
				
				regionTxn.AddQuery(query);
			}
		}
		
		delete equipGroupNames;
		delete equipGroups;
		
		db.Execute(regionTxn, .onError = OnTransactionError);
	}
	
	// items
	{
		ArrayList items = TF2Econ_GetItemList();
		StringMap equipRegions = TF2Econ_GetEquipRegionGroups();
		StringMapSnapshot equipRegionNameSnapshot = equipRegions.Snapshot();
		
		Transaction itemTxn = new Transaction();
		for (int i; i < items.Length; i++) {
			bool bContainsStringAttr;
			
			int itemdef = items.Get(i);
			ArrayList itemStaticAttributes = TF2Econ_GetItemStaticAttributes(itemdef);
			
			char query[512];
			
			// add attribute queries to txn
			for (int a; a < itemStaticAttributes.Length; a++) {
				int attrdef = itemStaticAttributes.Get(a, 0);
				
				char attrName[128];
				TF2Econ_GetAttributeName(attrdef, attrName, sizeof(attrName));
				
				any discard;
				bContainsStringAttr |= stringTypedAttributes.GetValue(attrName, discard);
				
				char attrLookupKey[256];
				Format(attrLookupKey, sizeof(attrLookupKey), "attributes/%s/value", attrName);
				
				bool bInStatic = true;
				
				char attrValueStr[64];
				TF2Econ_GetItemDefinitionString(itemdef, attrLookupKey, attrValueStr,
						sizeof(attrValueStr));
				
				if (!strlen(attrValueStr)) {
					bInStatic = false;
					Format(attrLookupKey, sizeof(attrLookupKey), "static_attrs/%s", attrName);
					TF2Econ_GetItemDefinitionString(itemdef, attrLookupKey, attrValueStr,
						sizeof(attrValueStr));
				}
				
				db.Format(query, sizeof(query), "INSERT INTO tf2idb_item_attributes "
						... "(id, attribute, value, static) VALUES "
						... "(%d, %d, '%s', %d);", itemdef, attrdef, attrValueStr, bInStatic);
				
				itemTxn.AddQuery(query);
			}
			
			// add items to tf2idb_item table
			{
				char name[128];
				TF2Econ_GetItemName(itemdef, name, sizeof(name));
				
				char localName[128];
				TF2Econ_GetLocalizedItemName(itemdef, localName, sizeof(localName));
				
				char className[64];
				TF2Econ_GetItemClassName(itemdef, className, sizeof(className));
				
				char slotStr[64];
				TF2Econ_GetItemDefinitionString(itemdef, "item_slot", slotStr, sizeof(slotStr));
				
				char qualityStr[64];
				TF2Econ_GetItemDefinitionString(itemdef, "item_quality",
						qualityStr, sizeof(qualityStr));
				
				char toolStr[64];
				TF2Econ_GetItemDefinitionString(itemdef, "tool/type", toolStr, sizeof(toolStr));
				
				int nMinLevel, nMaxLevel;
				TF2Econ_GetItemLevelRange(itemdef, nMinLevel, nMaxLevel);
				
				bool bBaseItem = !!_GetItemDefinitionInt(itemdef, "baseitem");
				
				char holidayRestriction[64];
				TF2Econ_GetItemDefinitionString(itemdef, "holiday_restriction",
						holidayRestriction, sizeof(holidayRestriction));
				
				bool bProperName = !!_GetItemDefinitionInt(itemdef, "propername");
				
				db.Format(query, sizeof(query), "INSERT INTO tf2idb_item "
						... "(id, name, item_name, class, slot, quality, tool_type, "
						... "min_ilevel, max_ilevel, baseitem, holiday_restriction, "
						... "has_string_attribute, propername) VALUES "
						... "(%d, '%s', '%s', '%s', '%s', '%s', '%s', "
						... "%d, %d, %b, '%s', %b, %b);",
						itemdef, name, localName, className, slotStr, qualityStr, toolStr,
						nMinLevel, nMaxLevel, bBaseItem, holidayRestriction,
						bContainsStringAttr, bProperName);
				itemTxn.AddQuery(query);
			}
			
			// deal with used_by_classes
			{
				static char s_ClassNames[][] = {
					"undefined", "scout", "sniper", "soldier", "demoman",
					"medic", "heavy", "pyro", "spy", "engineer"
				};
				
				char slotBuffer[32];
				for (TFClassType ct = TFClass_Scout; ct <= TFClass_Engineer; ct++) {
					int slot = TF2Econ_GetItemSlot(itemdef, ct);
					if (slot == -1) {
						continue;
					}
					
					TF2Econ_TranslateLoadoutSlotIndexToName(slot, slotBuffer,
							sizeof(slotBuffer));
					
					db.Format(query, sizeof(query), "INSERT INTO tf2idb_class "
							... "(id, class, slot) VALUES (%d, '%s', '%s');",
							itemdef, s_ClassNames[ct], slotBuffer);
					itemTxn.AddQuery(query);
				}
			}
			
			// add equip region refs
			{
				int itemRegionBits = TF2Econ_GetItemEquipRegionGroupBits(itemdef);
				for (int e; e < equipRegionNameSnapshot.Length; e++) {
					char buffer[16];
					equipRegionNameSnapshot.GetKey(e, buffer, sizeof(buffer));
					
					int bit;
					if (equipRegions.GetValue(buffer, bit) && (itemRegionBits >> bit) & 1) {
						db.Format(query, sizeof(query), "INSERT INTO tf2idb_equip_regions "
								... "(id, region) VALUES (%d, '%s');",
								itemdef, buffer);
						itemTxn.AddQuery(query);
					}
				}
			}
			
			// TODO deal with capabilities (currently no support in econdata)
		}
		db.Execute(itemTxn, .onError = OnTransactionError);
		
		delete equipRegionNameSnapshot;
		delete equipRegions;
		delete items;
	}
	delete stringTypedAttributes;
	
	StopProfiling(prof);
	PrintToServer("[tfeconcompat] Database created in %fs.", GetProfilerTime(prof));
	delete prof;
	
	return db;
}

public void OnTransactionError(Database db, any data, int numQueries, const char[] error,
		int failIndex, any[] queryData) {
	SetFailState("Transaction failure: %s", error);
}

static int _GetItemDefinitionInt(int defindex, const char[] key, int defaultValue = 0) {
	char buffer[64];
	return TF2Econ_GetItemDefinitionString(defindex, key, buffer, sizeof(buffer))?
			StringToInt(buffer) : defaultValue;
}

/**
 * Determines if the sqlite database is already up-to-date or needs to be (re)created.
 */
static DatabaseState GetDatabaseStatus() {
	char filePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, filePath, sizeof(filePath), "data/sqlite/tf2idb.sq3");
	if (!FileExists(filePath)) {
		return Database_Unavailable;
	}
	
	int databaseTime = GetFileTime(filePath, FileTime_LastChange);
	
	char pluginPath[PLATFORM_MAX_PATH];
	GetPluginFilename(INVALID_HANDLE, pluginPath, sizeof(pluginPath));
	BuildPath(Path_SM, filePath, sizeof(filePath), "plugins/%s", pluginPath);
	
	if (GetFileTime(filePath, FileTime_LastChange) > databaseTime) {
		return Database_Stale;
	}
	
	Format(filePath, sizeof(filePath), "scripts/items/items_game.txt");
	if (GetFileTime(filePath, FileTime_LastChange) > databaseTime) {
		return Database_Stale;
	}
	return Database_IsCurrent;
}

static void SQLite_DropDatabase(const char[] database) {
	char filePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, filePath, sizeof(filePath), "data/sqlite/%s.sq3", database);
	if (FileExists(filePath)) {
		DeleteFile(filePath);
	}
}
