--- ============== HEADER ==============
  -- Addon
  local addonName, AC = ...;
  -- AethysCore
  local Cache = AethysCore_Cache;
  local Unit = AC.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local Spell = AC.Spell;
  local Item = AC.Item;
  -- Lua
  
  -- File Locals
  


--- ============== CONTENT ==============
  -- Check if a given item is currently equipped in the given slot.
  --- Inventory slots
    -- INVSLOT_HEAD       = 1;
    -- INVSLOT_NECK       = 2;
    -- INVSLOT_SHOULDAC   = 3;
    -- INVSLOT_BODY       = 4;
    -- INVSLOT_CHEST      = 5;
    -- INVSLOT_WAIST      = 6;
    -- INVSLOT_LEGS       = 7;
    -- INVSLOT_FEET       = 8;
    -- INVSLOT_WRIST      = 9;
    -- INVSLOT_HAND       = 10;
    -- INVSLOT_FINGAC1    = 11;
    -- INVSLOT_FINGAC2    = 12;
    -- INVSLOT_TRINKET1   = 13;
    -- INVSLOT_TRINKET2   = 14;
    -- INVSLOT_BACK       = 15;
    -- INVSLOT_MAINHAND   = 16;
    -- INVSLOT_OFFHAND    = 17;
    -- INVSLOT_RANGED     = 18;
    -- INVSLOT_TABARD     = 19;
  function Item:IsEquipped (Slot)
    if not Cache.ItemInfo[self.ItemID] then Cache.ItemInfo[self.ItemID] = {}; end
    if Cache.ItemInfo[self.ItemID].IsEquipped == nil then
      Cache.ItemInfo[self.ItemID].IsEquipped = AC.Equipment[Slot] == self.ItemID and true or false;
    end
    return Cache.ItemInfo[self.ItemID].IsEquipped;  
  end

  -- Get the item Last Cast Time.
  function Item:LastCastTime ()
    return self.LastCastTime;
  end
