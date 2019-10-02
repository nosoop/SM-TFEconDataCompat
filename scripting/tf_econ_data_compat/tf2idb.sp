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
 * ArrayList TF2IDB_GetItemEquipRegions(int defindex);
 */
public int Native_TF2IDB_GetItemEquipRegions(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int itemRegionBits = TF2Econ_GetItemEquipRegionGroupBits(defindex);
	
	ArrayList itemRegionNames = new ArrayList(ByteCountToCells(16));
	if (!itemRegionBits) {
		return MoveHandle(itemRegionNames, hPlugin);
	}
	
	StringMap regions = TF2Econ_GetEquipRegionGroups();
	StringMapSnapshot snapshot = regions.Snapshot();
	for (int i; i < snapshot.Length; i++) {
		char buffer[16];
		snapshot.GetKey(i, buffer, sizeof(buffer));
		
		int bit;
		if (regions.GetValue(buffer, bit) && (itemRegionBits >> bit) & 1) {
			itemRegionNames.PushString(buffer);
		}
	}
	delete snapshot;
	delete regions;
	
	return MoveHandle(itemRegionNames, hPlugin);
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
