#define TF2II_PROP_VALIDITEM			(1<<0)
#define TF2II_PROP_BASEITEM				(1<<1)
#define TF2II_PROP_PAINTABLE			(1<<2)
#define TF2II_PROP_UNUSUAL				(1<<3)
#define TF2II_PROP_VINTAGE				(1<<4)
#define TF2II_PROP_STRANGE				(1<<5)
#define TF2II_PROP_HAUNTED				(1<<6)
#define TF2II_PROP_HALLOWEEN			(1<<7) // unused?
#define TF2II_PROP_PROMOITEM			(1<<8)
#define TF2II_PROP_GENUINE				(1<<9)
#define TF2II_PROP_MEDIEVAL				(1<<10)
#define TF2II_PROP_BDAY_STRICT			(1<<11)
#define TF2II_PROP_HOFM_STRICT			(1<<12)	// Halloween Or Full Moon
#define TF2II_PROP_XMAS_STRICT			(1<<13)
#define TF2II_PROP_PROPER_NAME			(1<<14)

/**
 * bool TF2II_IsItemSchemaPrecached();
 */
public int Native_ItemInfo_IsSchemaPrecached(Handle hPlugin, int nParams) {
	return true; // :thinking:
}

/**
 * int TF2II_GetItemMinLevel(int itemdef);
 */
public int Native_ItemInfo_GetItemMinLevel(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	
	int min, max;
	bool bResult = TF2Econ_GetItemLevelRange(defindex, min, max);
	
	return bResult? min : 0;
}

/**
 * int TF2II_GetItemMaxLevel(int itemdef);
 */
public int Native_ItemInfo_GetItemMaxLevel(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	
	int min, max;
	bool bResult = TF2Econ_GetItemLevelRange(defindex, min, max);
	
	return bResult? max : 0;
}

/**
 * bool TF2II_HiddenAttrib(int attrdef);
 */
public int Native_ItemInfo_IsAttributeHidden(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	return TF2Econ_IsAttributeHidden(attrdef);
}

/**
 * ETFEffectType TF2II_GetAttribEffectType(int attrdef);
 */
public int Native_ItemInfo_GetAttributeEffectType(Handle hPlugin, int nParams) {
	int attrdef = GetNativeCell(1);
	char buffer[64];
	if (!TF2Econ_GetAttributeDefinitionString(attrdef, "effect_type", buffer, sizeof(buffer))) {
		return 0;
	}
	
	// TODO translate positive / negative
	if (StrEqual(buffer, "postiive")) {
		return 1;
	} else if (StrEqual(buffer, "negative")) {
		return -1;
	}
	return 0;
}

/**
 * bool TF2II_ItemHasProperty(int itemdef, int flags);
 */
public int Native_ItemInfo_ItemHasProperty(Handle hPlugin, int nParams) {
	int itemdef = GetNativeCell(1);
	int flags = GetNativeCell(2);
	
	return (GetItemProperties(itemdef) & flags == flags);
}

/**
 * ArrayList TF2II_ListEffects(bool allEffects);
 * ArrayList TF2II_ListAttachableEffects(bool allEffects);
 **/
public int Native_ItemInfo_ListEffects(Handle hPlugin, int nParams) {
	bool allEffects = !!GetNativeCell(1);
	if (allEffects) {
		return MoveHandleImmediate(TF2Econ_GetParticleAttributeList(), hPlugin);
	}
	
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

public int Native_TF2II_GetItemSlot(Handle hPlugin, int nParams) {
	int itemdef = GetNativeCell(1);
	TFClassType playerClass = GetNativeCell(2);
	
	char className[64];
	if (TF2Econ_GetItemClassName(itemdef, className, sizeof(className))
			&& StrEqual(className, "tf_weapon_revolver")) {
		return TFWeaponSlot_Primary;
	}
	return GetLegacyLoadoutSlot(itemdef, playerClass);
}

public int Native_TF2II_IsItemUsedByClass(Handle hPlugin, int nParams) {
	int itemdef = GetNativeCell(1);
	TFClassType playerClass = GetNativeCell(2);
	
	return TF2Econ_GetItemSlot(itemdef, playerClass) != -1;
}

/**
 * ArrayList TF2II_FindItems(const char[] desiredClass, const char[] desiredSlot, int usedClassBits, const char[] tool);
 */
public int Native_TF2II_FindItems(Handle hPlugin, int nParams) {
	char desiredClass[64];
	char desiredSlot[32];
	char tool[64];
	
	GetNativeString(1, desiredClass, sizeof(desiredClass));
	GetNativeString(2, desiredSlot, sizeof(desiredSlot));
	int usedClassBits = GetNativeCell(3);
	GetNativeString(4, tool, sizeof(tool));
	
	DataPack queryInfo = new DataPack();
	queryInfo.WriteString(desiredClass);
	queryInfo.WriteString(desiredSlot);
	queryInfo.WriteCell(usedClassBits);
	queryInfo.WriteString(tool);
	
	ArrayList results = TF2Econ_GetItemList(ItemFilter_TF2IIFindItems, queryInfo);
	
	delete queryInfo;
	
	// TODO call OnFindItems forward
	
	return MoveHandle(results, hPlugin);
}

public bool ItemFilter_TF2IIFindItems(int itemdef, DataPack queryInfo) {
	char desiredClass[64];
	char desiredSlot[32];
	char tool[64];
	
	queryInfo.Reset();
	queryInfo.ReadString(desiredClass, sizeof(desiredClass));
	queryInfo.ReadString(desiredSlot, sizeof(desiredSlot));
	int usedClassBits = queryInfo.ReadCell();
	queryInfo.ReadString(tool, sizeof(tool));
	
	if (usedClassBits && usedClassBits & GetUseClassBits(itemdef) == 0) {
		return false;
	}
	
	if (desiredClass[0]) {
		char itemClass[64];
		if (!TF2Econ_GetItemClassName(itemdef, itemClass, sizeof(itemClass))
				|| !StrEqual(itemClass, desiredClass)) {
			return false;
		}
	}
	
	if (desiredSlot[0]) {
		// TODO we need to support tf_weapon_revolver as primary
		char itemSlot[32];
		if (!TF2Econ_GetItemDefinitionString(itemdef, "item_slot", itemSlot, sizeof(itemSlot))
				|| !StrEqual(itemSlot, desiredSlot)) {
			return false;
		}
	}
	
	if (tool[0]) {
		char toolType[64];
		if (!TF2Econ_GetItemDefinitionString(itemdef, "tool/type", toolType, sizeof(toolType))
				|| !StrEqual(tool, toolType)) {
			return false;
		}
	}
	
	return true;
}

static int GetUseClassBits(int defindex) {
	int bits;
	for (TFClassType i; i < TFClassType; i++) {
		if (TF2Econ_GetItemSlot(defindex, i) != -1) {
			bits |= (1 << view_as<int>(i));
		}
	}
	return bits;
}

static int GetItemProperties(int defindex) {
	if (!TF2Econ_IsValidItemDefinition(defindex)) {
		return 0;
	}
	
	int properties = TF2II_PROP_VALIDITEM;
	if (_GetItemDefinitionInt(defindex, "baseitem")) {
		properties |= TF2II_PROP_BASEITEM;
	}
	
	if (_GetItemDefinitionInt(defindex, "capabilities/paintable")) {
		properties |= TF2II_PROP_BASEITEM;
	}
	
	char holidayBuffer[64];
	if (TF2Econ_GetItemDefinitionString(defindex, "holiday_restriction",
			holidayBuffer, sizeof(holidayBuffer))) {
		if (StrEqual(holidayBuffer, "birthday")) {
			properties |= TF2II_PROP_BDAY_STRICT;
		} else if (StrEqual(holidayBuffer, "halloween_or_fullmoon")) {
			properties |= TF2II_PROP_HOFM_STRICT;
		} else if (StrEqual(holidayBuffer, "christmas")) {
			properties |= TF2II_PROP_XMAS_STRICT;
		}
	}
	
	if (_GetItemDefinitionInt(defindex, "propername")) {
		properties |= TF2II_PROP_PROPER_NAME;
	}
	
	return properties;
}

static int _GetItemDefinitionInt(int defindex, const char[] key, int defaultValue = 0) {
	char buffer[64];
	return TF2Econ_GetItemDefinitionString(defindex, key, buffer, sizeof(buffer))?
			StringToInt(buffer) : defaultValue;
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
