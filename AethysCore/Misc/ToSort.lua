--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, AC = ...;
  -- AethysCore
  local Cache = AethysCache;
  local Unit = AC.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local Spell = AC.Spell;
  local Item = AC.Item;
  -- Lua
  local mathmax = math.max;
  local select = select;
  -- File Locals
  


--- ============================ CONTENT ============================
  -- Get the Instance Informations
  -- TODO: Cache it in Persistent Cache and update it only when it changes
  -- @returns name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize
    -- name - Name of the instance or world area (string)
    -- type - Type of the instance (string)
    -- difficulty - Difficulty setting of the instance (number)
    -- difficultyName - String representing the difficulty of the instance. E.g. "10 Player" (string)
    -- maxPlayers - Maximum number of players allowed in the instance (number)
    -- playerDifficulty - Unknown (number)
    -- isDynamicInstance - True for raid instances that can support multiple maxPlayers values (10 and 25) - eg. ToC, DS, ICC, etc (boolean)
    -- mapID - (number)
    -- instanceGroupSize - maxPlayers for fixed size raids, holds the actual raid size for the new flexible raid (between (8?)10 and 25) (number)
  function AC.GetInstanceInfo (Index)
    if Index then
      local Result = select(Index, GetInstanceInfo());
      return Result;
    end
    return GetInstanceInfo();
  end

  -- Get the Instance Difficulty Infos
  -- @returns difficulty - Difficulty setting of the instance (number)
    -- 0 - None; not in an Instance.
    -- 1 - 5-player Instance.
    -- 2 - 5-player Heroic Instance.
    -- 3 - 10-player Raid Instance.
    -- 4 - 25-player Raid Instance.
    -- 5 - 10-player Heroic Raid Instance.
    -- 6 - 25-player Heroic Raid Instance.
    -- 7 - 25-player Raid Finder Instance.
    -- 8 - Challenge Mode Instance.
    -- 9 - 40-player Raid Instance.
    -- 10 - Not used.
    -- 11 - Heroic Scenario Instance.
    -- 12 - Scenario Instance.
    -- 13 - Not used.
    -- 14 - 10-30-player Normal Raid Instance.
    -- 15 - 10-30-player Heroic Raid Instance.
    -- 16 - 20-player Mythic Raid Instance .
    -- 17 - 10-30-player Raid Finder Instance.
    -- 18 - 40-player Event raid (Used by the level 100 version of Molten Core for WoW's 10th anniversary).
    -- 19 - 5-player Event instance (Used by the level 90 version of UBRS at WoD launch).
    -- 20 - 25-player Event scenario (unknown usage).
    -- 21 - Not used.
    -- 22 - Not used.
    -- 23 - Mythic 5-player Instance.
    -- 24 - Timewalker 5-player Instance.
  function AC.GetInstanceDifficulty ()
    return AC.GetInstanceInfo(3);
  end

  -- Get the Latency (it's updated every 30s).
  -- TODO: Cache it in Persistent Cache and update it only when it changes
  function AC.Latency ()
    return select(4, GetNetStats());
  end

  -- Retrieve the Recovery Timer based on Settings.
  -- TODO: Optimize, to see how we'll implement it in the GUI.
  function AC.RecoveryTimer ()
    return AC.GUISettings.General.RecoveryMode == "GCD" and Player:GCDRemains()*1000 or AC.GUISettings.General.RecoveryTimer;
  end

  -- Compute the Recovery Offset with Lag Compensation.
  function AC.RecoveryOffset ()
    return (AC.Latency() + AC.RecoveryTimer())/1000;
  end

  -- Get the time since combat has started.
  function AC.CombatTime ()
    return AC.CombatStarted ~= 0 and AC.GetTime()-AC.CombatStarted or 0;
  end

  -- Get the time since combat has ended.
  function AC.OutOfCombatTime ()
    return AC.CombatEnded ~= 0 and AC.GetTime()-AC.CombatEnded or 0;
  end

  -- Get the Boss Mod Pull Timer.
  function AC.BMPullTime ()
    if not AC.BossModTime or AC.BossModTime == 0 or AC.BossModEndTime-AC.GetTime() < 0 then
      return 60;
    else
      return AC.BossModEndTime-AC.GetTime();
    end
  end

  --[[*
    * @mixin AC.OffsetRemains
    * @desc Apply an offset to an expiration time.
    *
    * @param {number} ExpirationTime - The expiration time to apply the offset on.
    * @param {string|number} Offset - The offset to apply, can be a string for a known method or directly the offset value in seconds.
    *
    * @returns {number}
    *]]
  function AC.OffsetRemains (ExpirationTime, Offset)
    if type( Offset ) == "number" then
      ExpirationTime = ExpirationTime - Offset;
    elseif type( Offset ) == "string" then
      local CastRemains = Player:CastRemains();

      -- Since the GCD is triggered on the client, add a brief grace period to avoid flickering predictions
      -- TODO: This should probably be event-driven with CAST_ events controlling if the client-side GCD is ignored
      -- For now, we just hardcode a period of 1/8th of a second which should work in most cases barring extreme lag
      local GCDRemains = Player:GCDRemains();
      if Player:GCD() - GCDRemains < 0.125 then
        GCDRemains = 0;
      end

      if Offset == "GCDRemains" then
        ExpirationTime = ExpirationTime - GCDRemains;
      elseif Offset == "CastRemains" then
        ExpirationTime = ExpirationTime - CastRemains;
      elseif Offset == "Auto" then
        ExpirationTime = ExpirationTime - mathmax( GCDRemains, CastRemains );
      end
    else
      error( "Invalid Offset." );
    end
    return ExpirationTime;
  end
