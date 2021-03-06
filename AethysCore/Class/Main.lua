--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, AC = ...;
  -- AethysCore
  local Cache = AethysCache;
  -- Lua
  local error = error;
  local setmetatable = setmetatable;
  local stringformat = string.format;
  -- File Locals
  


--- ============================ CONTENT ============================
--- ======= PSEUDO-CLASS =======
  local function Class ()
    local Class = {};
    Class.__index = Class;
    setmetatable( Class, { __call =
      function ( self, ... )
        local Object = {};
        setmetatable( Object, self );
        Object:New( ... );
        return Object;
      end
    } );
    return Class;
  end

--- ======= UNIT =======
do
  local Unit = Class();
  AC.Unit = Unit;
  function Unit:New ( UnitID )
    if type( UnitID ) ~= "string" then error( "Invalid UnitID." ); end
    self.UnitID = UnitID;
  end
  -- Unique Units
  Unit.Player = Unit( "Player" );
  Unit.Pet = Unit( "Pet" );
  Unit.Target = Unit( "Target" );
  Unit.Focus = Unit( "Focus" );
  Unit.MouseOver = Unit( "MouseOver" );
  Unit.Vehicle = Unit( "Vehicle" );
  -- Iterable Units
  local UnitIDs = {
    { "Arena", 5 },
    { "Boss", 4 },
    { "Nameplate", AC.MAXIMUM },
    { "Party", 5 },
    { "Raid", 40 }
  };
  for _, UnitID in pairs( UnitIDs ) do
    local UnitType = UnitID[ 1 ];
    local UnitCount = UnitID[ 2 ];
    Unit[ UnitType ] = {};
    for i = 1, UnitCount do
      Unit[ UnitType ][ i ] = Unit( stringformat( "%s%d", UnitType, i ) );
    end
  end
end

--- ======= SPELL =======
do
  local Spell = Class();
  AC.Spell = Spell;
  function Spell:New ( SpellID, SpellType )
    if type( SpellID ) ~= "number" then error( "Invalid SpellID." ); end
    if SpellType and type( SpellType ) ~= "string" then error( "Invalid Spell Type." ); end
    self.SpellID = SpellID;
    self.SpellType = SpellType or "Player"; -- For Pet, put "Pet". Default is "Player".
    self.LastCastTime = 0;
    self.LastDisplayTime = 0;
    self.LastHitTime = 0;
    self.LastAppliedOnPlayerTime = 0;
    self.LastRemovedFromPlayerTime = 0;
  end
end

--- ======= ITEM =======
local itemSlotTable = {
  -- Source: http://wowwiki.wikia.com/wiki/ItemEquipLoc
  ["INVTYPE_AMMO"] =           { 0 },
  ["INVTYPE_HEAD"] =           { 1 },
  ["INVTYPE_NECK"] =           { 2 },
  ["INVTYPE_SHOULDER"] =       { 3 },
  ["INVTYPE_BODY"] =           { 4 },
  ["INVTYPE_CHEST"] =          { 5 },
  ["INVTYPE_ROBE"] =           { 5 },
  ["INVTYPE_WAIST"] =          { 6 },
  ["INVTYPE_LEGS"] =           { 7 },
  ["INVTYPE_FEET"] =           { 8 },
  ["INVTYPE_WRIST"] =          { 9 },
  ["INVTYPE_HAND"] =           { 10 },
  ["INVTYPE_FINGER"] =         { 11, 12 },
  ["INVTYPE_TRINKET"] =        { 13, 14 },
  ["INVTYPE_CLOAK"] =          { 15 },
  ["INVTYPE_WEAPON"] =         { 16, 17 },
  ["INVTYPE_SHIELD"] =         { 17 },
  ["INVTYPE_2HWEAPON"] =       { 16 },
  ["INVTYPE_WEAPONMAINHAND"] = { 16 },
  ["INVTYPE_WEAPONOFFHAND"] =  { 17 },
  ["INVTYPE_HOLDABLE"] =       { 17 },
  ["INVTYPE_RANGED"] =         { 18 },
  ["INVTYPE_THROWN"] =         { 18 },
  ["INVTYPE_RANGEDRIGHT"] =    { 18 },
  ["INVTYPE_RELIC"] =          { 18 },
  ["INVTYPE_TABARD"] =         { 19 },
  ["INVTYPE_BAG"] =            { 20, 21, 22, 23 },
  ["INVTYPE_QUIVER"] =         { 20, 21, 22, 23 }
};

local function usableSlotID ( itemEquipLoc )
  return itemSlotTable[itemEquipLoc] or nil
end

local function defaultItemSlotID ( ItemID )
  -- http://wowwiki.wikia.com/wiki/API_GetItemInfo: 9th slot is itemEquipLoc
  return select( 9, GetItemInfo( ItemID ) ) or nil
end

do
  local Item = Class();
  AC.Item = Item;
  function Item:New ( ItemID, ItemSlotID )
    if type( ItemID ) ~= "number" then error( "Invalid ItemID." ); end
    if ItemSlotID and type( ItemSlotID ) ~= "table" then error( "Invalid ItemSlotID." ); end
    self.ItemID = ItemID;
    self.ItemSlotID = ItemSlotID or usableSlotID(defaultItemSlotID( ItemID )) or { 0 };
    self.LastCastTime = 0;
    self.LastDisplayTime = 0;
    self.LastHitTime = 0;
  end
end
