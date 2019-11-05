/**
 * bool TF2II_IsValidItemID(int defindex);
 * bool TF2IDB_IsValidItemID(int defindex);
 */
public int Native_Common_IsValidItemID(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	return TF2Econ_IsValidItemDefinition(defindex);
}

/**
 * bool TF2II_GetItemName(int defindex, char[] buffer, int maxlen);
 * bool TF2IDB_GetItemName(int defindex, char[] buffer, int maxlen);
 */
public int Native_Common_GetItemName(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	
	if (TF2Econ_GetItemName(defindex, buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2II_GetItemClass(int defindex, char[] buffer, int maxlen, TFClassType class);
 * bool TF2IDB_GetItemClass(int defindex, char[] buffer, int maxlen); // ??
 */
public int Native_Common_GetItemClassName(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	
	if (TF2Econ_GetItemClassName(defindex, buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2II_GetListedItemSlotName(int itemdef, char[] buffer, int maxlen);
 * bool TF2IDB_GetItemSlotName(int itemdef, char[] buffer, int maxlen, TFClassType classType = TFClass_Unknown);
 */
public int Native_Common_GetLegacyItemSlotName(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	// only TF2IDB specifies class
	TFClassType playerClass = nParams > 3?
			view_as<TFClassType>(GetNativeCell(4)) : TFClass_Unknown;
	
	int slot = GetLegacyLoadoutSlot(defindex, playerClass);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_TranslateLoadoutSlotIndexToName(slot, buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * TF2ItemSlot TF2II_GetListedItemSlot(int itemdef, TFClassType classType = TFClass_Unknown );
 * TF2ItemSlot TF2IDB_GetItemSlot(int itemdef, TFClassType classType = TFClass_Unknown);
 */
public int Native_Common_GetLegacyItemSlot(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	TFClassType playerClass = view_as<TFClassType>(GetNativeCell(2));
	
	int loadoutSlot = GetLegacyLoadoutSlot(defindex, playerClass);
	
	char slotName[32];
	TF2Econ_TranslateLoadoutSlotIndexToName(loadoutSlot, slotName, sizeof(slotName));
	
	return TranslateLoadoutSlotNameToWeaponSlot(slotName, playerClass);
}

/**
 * bool TF2II_IsValidAttribID(int attrdef);
 * bool TF2IDB_IsValidAttributeID(int attrdef);
 */
public int Native_Common_IsValidAttributeDefinition(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	return !!TF2Econ_GetAttributeDefinitionAddress(attrdef);
}

/**
 * bool TF2II_GetAttribName(int attrdef, char[] buffer, int maxlen);
 * bool TF2IDB_GetAttributeName(int attrdef, char[] buffer, int maxlen);
 */
public int Native_Common_GetAttributeName(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeName(attrdef, buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2II_GetAttribClass(int attrdef, char[] buffer, int maxlen);
 * bool TF2IDB_GetAttributeClass(int attrdef, char[] buffer, int maxlen);
 */
public int Native_Common_GetAttributeClassName(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeClassName(attrdef, buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2II_GetAttribDescrString(int attrdef, char[] buffer, int maxlen);
 * bool TF2IDB_GetAttributeDescString(int attrdef, char[] buffer, int maxlen);
 */
public int Native_Common_GetAttributeDescriptionString(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeDefinitionString(attrdef, "description_string", buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2II_GetAttribDescrFormat(int attrdef, char[] buffer, int maxlen);
 * bool TF2IDB_GetAttributeDescFormat(int attrdef, char[] buffer, int maxlen);
 */
public int Native_Common_GetAttributeDescriptionFormat(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetAttributeDefinitionString(attrdef, "description_format", buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * TF2ItemQuality TF2II_GetItemQuality(int itemdef);
 * TF2ItemQuality TF2IDB_GetItemQuality(int itemdef);
 */
public int Native_Common_GetItemQuality(Handle hPlugin, int nParams) {
	int itemdef = GetNativeCell(1);
	return TF2Econ_GetItemQuality(itemdef);
}

/**
 * bool TF2II_GetItemQualityName(int itemdef, char[] buffer, int maxlen);
 * bool TF2IDB_GetItemQualityName(int itemdef, char[] buffer, int maxlen);
 */
public int Native_Common_GetItemQualityName(Handle hPlugin, int nParams) {
	int itemdef = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_IsValidItemDefinition(itemdef) &&
			TF2Econ_GetQualityName(TF2Econ_GetItemQuality(itemdef), buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * bool TF2II_GetQualityName(int quality, char[] name, int maxlen);
 * bool TF2IDB_GetQualityName(int quality, char[] name, int maxlen);
 */
public int Native_Common_GetQualityName(Handle hPlugin, int nParams) {
	int quality = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	if (TF2Econ_GetQualityName(quality, buffer, maxlen)) {
		SetNativeString(2, buffer, maxlen, true);
		return true;
	}
	return false;
}

/**
 * TF2ItemQuality TF2II_GetQualityByName(const char[] qualityName);
 * TF2ItemQuality TF2IDB_GetQualityByName(const char[] qualityName);
 */
public int Native_Common_GetQualityByName(Handle hPlugin, int nParams) {
	int maxlen;
	int error = GetNativeStringLength(1, maxlen);
	if (error != SP_ERROR_NONE) {
		ThrowNativeError(error, "GetNativeStringLength returned error code %d", error);
	}
	
	char[] buffer = new char[++maxlen];
	GetNativeString(1, buffer, maxlen);
	
	return TF2Econ_TranslateQualityNameToValue(buffer, false);
}

/**
 * bool TF2II_IsConflictRegions(const char[] region1, const char[] region2);
 * bool TF2IDB_DoRegionsConflict(const char[] region1, const char[] region2);
 */
public int Native_Common_DoRegionsConflict(Handle hPlugin, int nParams) {
	char region1[64], region2[64];
	GetNativeString(1, region1, sizeof(region1));
	GetNativeString(2, region2, sizeof(region2));
	
	int mask1, mask2;
	if (!TF2Econ_GetEquipRegionMask(region1, mask1)
			|| !TF2Econ_GetEquipRegionMask(region2, mask2)) {
		return false;
	}
	return mask1 & mask2 != 0;
}


/**
 * ArrayList TF2II_GetItemEquipRegions(int itemdef);
 * ArrayList TF2IDB_GetItemEquipRegions(int itemdef);
 */
public int Native_Common_GetItemEquipRegions(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int itemRegionBits = TF2Econ_GetItemEquipRegionGroupBits(defindex);
	
	ArrayList itemRegionNames = new ArrayList(ByteCountToCells(16));
	if (!itemRegionBits) {
		return MoveHandle(itemRegionNames, hPlugin);
	}
	
	StringMap regions = TF2Econ_GetEquipRegionGroups();
	StringMapSnapshot snapshot = regions.Snapshot();
	
	// multiple groups can share the same group bit, so test each group name
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
 * Falls back to default item slot if slot is not valid for class.
 */
static int GetLegacyLoadoutSlot(int defindex, TFClassType playerClass = TFClass_Unknown) {
	int slot = TF2Econ_GetItemSlot(defindex, playerClass);
	if (slot != -1) {
		return slot;
	}
	
	char buffer[64];
	TF2Econ_GetItemDefinitionString(defindex, "item_slot", buffer, sizeof(buffer));
	return TF2Econ_TranslateLoadoutSlotNameToIndex(buffer);
}

int TranslateLoadoutSlotNameToWeaponSlot(const char[] slotName,
		TFClassType playerClass = TFClass_Unknown) {
	if (StrEqual(slotName, "primary")) {
		return 0;
	} else if (StrEqual(slotName, "secondary")) {
		return 1;
	} else if (StrEqual(slotName, "melee")) {
		return 2;
	} else if (StrEqual(slotName, "pda")) {
		return 3;
	} else if (StrEqual(slotName, "pda2")) {
		return 4;
	} else if (StrEqual(slotName, "building")) {
		return playerClass == TFClass_Spy? 1 : 5;
	} else if (StrEqual(slotName, "head")) {
		return 5;
	} else if (StrEqual(slotName, "misc")) {
		return 6;
	} else if (StrEqual(slotName, "action")) {
		return 7;
	}
	return -1;
}