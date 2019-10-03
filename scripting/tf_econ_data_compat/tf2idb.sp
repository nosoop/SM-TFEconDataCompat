#define TF2IDB_MAX_ATTRS 20

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

#include <profiler>

Database TF2IDB_BuildDatabase() {
	Handle prof = CreateProfiler();
	StartProfiling(prof);
	
	char error[256];
	Database db = SQLite_UseDatabase("tf2idb", error, sizeof(error));
	if (!db) {
		SetFailState("Failed to use tf2idb.sq3: %s", error);
	}
	
	// this implements the script from
	// https://github.com/FlaminSarge/tf2idb/tree/c2bc42e34c2a2e9a4e9ad0d0fe8cda564e970bb6
	
	SQL_FastQuery(db, "CREATE TABLE tf2idb_class ("
			... "'id' INTEGER NOT NULL, "
			... "'class' TEXT NOT NULL, "
			... "'slot' TEXT, "
			... "PRIMARY KEY ('id', 'class'));");
	
	SQL_FastQuery(db, "CREATE TABLE tf2idb_item_attributes ("
			... "'id' INTEGER NOT NULL, "
			... "'attribute' INTEGER NOT NULL, "
			... "'value' TEXT NOT NULL, "
			... "'static' INTEGER, "
			... "PRIMARY KEY ('id, 'attribute'));");
	
	SQL_FastQuery(db, "CREATE TABLE tf2idb_item ("
			... "'id' INTEGER PRIMARY NOT NULL, "
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
			... "'propername' INTEGER);");
	
	SQL_FastQuery(db, "CREATE TABLE 'tf2idb_particles' ("
			... "'id' INTEGER PRIMARY KEY NOT NULL , 'name' TEXT NOT NULL);");
	
	SQL_FastQuery(db, "CREATE TABLE 'tf2idb_equip_conflicts' ("
			... "'name' TEXT NOT NULL, "
			... "'region' TEXT NOT NULL, "
			... "PRIMARY KEY ('name', 'region'));");
	
	SQL_FastQuery(db, "CREATE TABLE 'tf2idb_equip_regions' ("
			... "'id' INTEGER NOT NULL, "
			... "'region' TEXT NOT NULL, "
			... "PRIMARY KEY ('id', 'region'));");
	
	SQL_FastQuery(db, "CREATE TABLE 'tf2idb_capabilities' ("
			... "'id' INTEGER NOT NULL , 'capability' TEXT NOT NULL)");
	
	SQL_FastQuery(db, "CREATE TABLE 'tf2idb_attributes' ("
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
			... "'apply_tag_to_item_definition' TEXT);");
	
	SQL_FastQuery(db, "CREATE TABLE 'tf2idb_qualities' ("
			... "'name' TEXT PRIMARY KEY NOT NULL, "
			... "'value' INTEGER NOT NULL );");
	
	SQL_FastQuery(db, "CREATE INDEX '__idx_tf2idb_item_attributes' ON 'tf2idb_item_attributes' "
			... "('attribute' ASC);");
	SQL_FastQuery(db, "CREATE INDEX '__idx_tf2idb_class' ON 'tf2idb_class'"
			... "('class' ASC)");
	SQL_FastQuery(db, "CREATE INDEX '__idx_tf2idb_item' ON 'tf2idb_item'"
			... "('slot' ASC)");
	
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
	{
		DBStatement attributeInsert = SQL_PrepareQuery(db,
				"INSERT INTO tf2idb_attributes "
				... "(id, name, attribute_class, attribute_type, description_string, "
				... "description_format, effect_type, hidden, stored_as_integer, armory_desc, "
				... "is_set_bonus, is_user_generated, can_affect_recipe_component_name, "
				... "apply_tag_to_item_definition) VALUES "
				... "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", error, sizeof(error));
		if (!attributeInsert) {
			SetFailState("Failed to prepare tf2idb_attributes query: %s", error);
		}
		
		// TODO I guess we need a TF2Econ_GetAttributeList() for this...
		for (int attrdef; attrdef < 4096; attrdef++) {
			if (!TF2Econ_IsValidAttributeDefinition(attrdef)) {
				continue;
			}
			
			char buffer[256];
			
			attributeInsert.BindInt(0, attrdef);
			
			TF2Econ_GetAttributeName(attrdef, buffer, sizeof(buffer));
			attributeInsert.BindString(1, buffer, .copy = true);
			
			TF2Econ_GetAttributeClassName(attrdef, buffer, sizeof(buffer));
			attributeInsert.BindString(2, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "attribute_type", buffer,
					sizeof(buffer));
			attributeInsert.BindString(3, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "description_string",
					buffer, sizeof(buffer));
			attributeInsert.BindString(4, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "description_format",
					buffer, sizeof(buffer));
			attributeInsert.BindString(5, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "effect_type",
					buffer, sizeof(buffer));
			attributeInsert.BindString(6, buffer, .copy = true);
			
			attributeInsert.BindInt(7, TF2Econ_IsAttributeHidden(attrdef));
			
			attributeInsert.BindInt(8, TF2Econ_IsAttributeStoredAsInteger(attrdef));
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "armory_desc",
					buffer, sizeof(buffer));
			attributeInsert.BindString(9, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "is_set_bonus",
					buffer, sizeof(buffer));
			attributeInsert.BindString(10, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "is_user_generated",
					buffer, sizeof(buffer));
			attributeInsert.BindString(11, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "can_affect_recipe_component_name",
					buffer, sizeof(buffer));
			attributeInsert.BindString(12, buffer, .copy = true);
			
			TF2Econ_GetAttributeDefinitionString(attrdef, "apply_tag_to_item_definition",
					buffer, sizeof(buffer));
			attributeInsert.BindString(13, buffer, .copy = true);
			
			SQL_Execute(attributeInsert);
		}
		
		delete attributeInsert;
	}
	
	// equipment conflicts
	{
		StringMap equipGroups = TF2Econ_GetEquipRegionGroups();
		
		// TODO iterate group names, find masks, then convert to conflicting group names
		
		delete equipGroups;
	}
	
	// items
	{
		// TODO insert static attributes into tf2idb_item_attributes
		
		// TODO insert items into tf2idb_item
		
		// TODO deal with equip regions
		
		// TODO deal with capabilities (currently no support in econdata)
	}
	
	StopProfiling(prof);
	PrintToServer("[tfeconcompat] Database created in %fs.", GetProfilerTime(prof));
	delete prof;
}
