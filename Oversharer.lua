Oversharer = {}
Oversharer.name = "Oversharer"
Oversharer.pattern = "::OS::"
Oversharer.writeNoteSemaphore = false
Oversharer.newGuildNoteGlobal = ""
-- Oversharer.patternNoEscape = "$$OS:"

function Oversharer:Initialize()
  self.hidden = false

  -- SET UP SAVED VARIABLES FOR OFFLINE STORAGE
  self.savedVariables = ZO_SavedVars:New("OversharerSavedVariables", 1, nil, {})

  -- REGISTER SLASH COMMANDS
  if GetDisplayName() == "@flipswitchingmonkey" then
      SLASH_COMMANDS["/rr"] = function(cmd) ReloadUI() end
  end 
  SLASH_COMMANDS["/oversharer"] = function(cmd) Oversharer.ShowUI() end

  -- REGISTER EVENTS
  EVENT_MANAGER:RegisterForEvent(Oversharer.name,EVENT_GUILD_MEMBER_NOTE_CHANGED,Oversharer.GuildMemberNoteChanged)
  
  -- INIT MAINWINDOWS CONTROLS
  Oversharer:initWindow()
end

function Oversharer:initWindow()
  OversharerDialog:SetHandler("OnMoveStop", Oversharer.OnOversharerDialog_MoveStop)
  OversharerDialogTestButton:SetText("TestButton")
  OversharerDialogTestButton:SetHandler("OnClicked", Oversharer.TestButton_Clicked)
  OversharerDialogButtonCloseAddon:SetHandler("OnClicked", Oversharer.ToggleMainWindow)

  Oversharer:AddCheckboxRows()
  self:RestorePosition()
end

function Oversharer:AddCheckboxRows()
  local sc = WINDOW_MANAGER:GetControlByName("OversharerDialog")
  local numGuilds = GetNumGuilds()
  for i=1,numGuilds+1,1 do
    local row = WINDOW_MANAGER:GetControlByName("OversharerCheckboxRow" .. i)
    if row == nil then
      row = WINDOW_MANAGER:CreateControlFromVirtual("OversharerCheckboxRow" .. i, sc, "OversharerCheckboxRowTemplate")
    end
    local rowName = row:GetNamedChild("Name")
    local rowCheck = row:GetNamedChild("Check")
    rowCheck.rowId = i-1
    d(ZO_CheckButton_IsChecked(rowCheck))
    ZO_CheckButton_SetToggleFunction(rowCheck, Oversharer.ZO_CheckButton_OnToggle)
    -- row:GetNamedChild("Item"):SetText("Something")
    if i == 1 then
      rowName:SetText("Myself")
    else
      rowName:SetText(GetGuildName(i-1))
    end
    row:SetAnchor(TOPLEFT, sc, TOPLEFT, 2, 50 + ((i - 1) * 30))
    row:SetHidden(false)
  end
end

function Oversharer.OnAddOnLoaded(event, addonName)
  if addonName == Oversharer.name then
    Oversharer:Initialize()
  end
end

function Oversharer.GuildMemberNoteChanged(event, guildId, displayName, note)
  local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
  -- s = zo_strformat("Member Note Changed - Guild: <<1>> Member: <<2>>\nNew Note:\n<<3>>", GetGuildName(guildId), displayName, note)
  -- d(s)
  local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(note)
  if addonData ~= nil then
    d("Oversharer Data from Note:" .. addonData)
  end

end

function Oversharer.ZO_CheckButton_OnToggle(checkButton, isChecked)
  if checkButton.rowId == 0 then
    Oversharer.SetOwnMemberNote(1, "Beigetreten am 27.09.2018 \n Test")
  else 
    local guildId = tonumber(checkButton.rowId)
    local displayName = GetDisplayName()
    local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    local guildMemberInfo = GetGuildMemberInfo(guildId, guildMemberId)
    d(guildMemberInfo)
    -- d(guildMemberInfo.note)
    -- d(type(guildMemberInfo.note))
    local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberId)
    d(name, note, rankIndex, playerStatus, secsSinceLogoff)
  end
  --s = zo_strformat("Member Note Changed - Guild: <<1>> Member: <<2>> Note: <<3>>", GetGuildName(guildId), displayName, note)
  --d(s)
  -- SetGuildMemberNote(*integer* _guildId_, *luaindex* _memberIndex_, *string* _note_)
end

function Oversharer.SetOwnMemberNote(guildId, note)
  local displayName = GetDisplayName()
  local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
  Oversharer.newGuildNoteGlobal = note
  -- Do not call this too often, as it is a rate-limited function
  -- Calling it too often per minute will kick the player
  if Oversharer.writeNoteSemaphore == false then
    Oversharer.writeNoteSemaphore = true
    zo_callLater(function() 
        SetGuildMemberNote(guildId, guildMemberId, Oversharer.newGuildNoteGlobal)
        Oversharer.writeNoteSemaphore = false
        d("Guild note updated.")
      end, 5000)
  else
    d("A guild note update is already queued.")
  end
end

function Oversharer.GetOwnMemberNote(guildId)
  local displayName = GetDisplayName()
  local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
  local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberId)
  return note
end

function Oversharer.OnOversharerDialog_MoveStop()
  Oversharer.savedVariables.left = OversharerDialog:GetLeft()
  Oversharer.savedVariables.top = OversharerDialog:GetTop()
end

function Oversharer:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  OversharerDialog:ClearAnchors()
  OversharerDialog:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Oversharer.ToggleMainWindow()
  Oversharer.hidden = not Oversharer.hidden
  OversharerDialog:SetHidden(Oversharer.hidden)
end

function Oversharer.CloseUI()
  Oversharer.hidden = true;
  SCENE_MANAGER:HideTopLevel(OversharerDialog)
end

function Oversharer.ShowUI()
  Oversharer.hidden = false;
  OversharerDialog:SetHidden(Oversharer.hidden)
end

function Oversharer.HideUI()
  Oversharer.hidden = true;
  OversharerDialog:SetHidden(Oversharer.hidden)
end

function Oversharer.ExtractAddonDataFromGuildNote(param)
  local note
  if type(param) == "number" then note = Oversharer.GetOwnMemberNote(param)
  elseif type(param) == "string" then note = param
  else return nil, param
  end
  -- d(note)
  -- local osString = string.match(note, "%$%$OS.*%$%$")
  local osFirst, _ = note:find(Oversharer.pattern)
  -- d(osFirst)
  local osLast, _ = note:reverse():find(Oversharer.pattern:reverse()) -- acutally looking for SO$$ in the original string
  -- d(osLast)
  if (osFirst ~= nil) and (osLast ~= nil) then
    osLast = #note - osLast + 2
    local osString = note:sub(osFirst, osLast):gsub(Oversharer.pattern, "")
    if osString ~= nil then
      -- note = string.gsub(note, "%$%$OS.*%$%$", "")
      note = note:sub(1, osFirst-1) .. note:sub(osLast, #note)
      -- Oversharer.SetOwnMemberNote(param, note)
      return osString, note
    end
  end
  return nil, note
end

function Oversharer.InjectAddonDataIntoGuildNote(guildId)
  -- local note = Oversharer.GetOwnMemberNote(guildId)
  local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(guildId)
  local newNote = noteWithoutData .. Oversharer.pattern .. "injected" .. Oversharer.pattern
  Oversharer.SetOwnMemberNote(guildId, newNote)
end

function Oversharer.TestButton_Clicked()
  -- d("Clicked")
  -- d("GetNumGuilds:" .. GetNumGuilds())
  -- for i=1,GetNumGuilds(),1 do
    -- d("GetGuildName " .. i .. " :" .. GetGuildName(i))
  -- end
  local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(1)
  if addonData ~= nil then
    -- if noteWithoutData ~= nil then
    --   Oversharer.SetOwnMemberNote(1, noteWithoutData)
    -- end
    d("Oversharer Data from Note:" .. addonData)
  end
  Oversharer.InjectAddonDataIntoGuildNote(1)
end

EVENT_MANAGER:RegisterForEvent(Oversharer.name,EVENT_ADD_ON_LOADED,Oversharer.OnAddOnLoaded)