local libScroll = LibStub:GetLibrary("LibScroll")

Oversharer = {}
Oversharer.name = "Oversharer"
Oversharer.pattern = "::OS::"
Oversharer.writeNoteSemaphore = false
Oversharer.newGuildNoteGlobal = ""
Oversharer.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1)
Oversharer.scrollList = nil
Oversharer.dataItems = {}

function Oversharer.SetupDataRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    rowControl.data = data
    rowControl.name = GetControl(rowControl, "Name")
    rowControl.time = GetControl(rowControl, "Time")
    rowControl.quest = GetControl(rowControl, "Quest")
    rowControl.action = GetControl(rowControl, "Action")

    rowControl.name:SetText(data.name)
    rowControl.time:SetText(data.time)
    rowControl.quest:SetText(data.quest)
    rowControl.action:SetText(data.action)

    rowControl.name.normalColor = Oversharer.DEFAULT_TEXT
    rowControl.time.normalColor = Oversharer.DEFAULT_TEXT
    rowControl.quest.normalColor = Oversharer.DEFAULT_TEXT
    rowControl.action.normalColor = Oversharer.DEFAULT_TEXT
    -- rowControl:SetText(data.name)
    rowControl:SetFont("ZoFontWinH4")
end

function Oversharer.SortScrollListByName(objA, objB)
  return objA.data.name < objB.data.name
end

function Oversharer.SortScrollListByNameRev(objA, objB)
  return objA.data.name > objB.data.name
end

function Oversharer.SortScrollListByTime(objA, objB)
  return objA.data.time < objB.data.time
end

function Oversharer.SortScrollListByTimeRev(objA, objB)
  return objA.data.time > objB.data.time
end

function Oversharer.SortScrollListByQuest(objA, objB)
  return objA.data.quest < objB.data.quest
end

function Oversharer.SortScrollListByQuestRev(objA, objB)
  return objA.data.quest > objB.data.quest
end

function Oversharer.SortScrollListByAction(objA, objB)
  return objA.data.action < objB.data.action
end

function Oversharer.SortScrollListByActionRev(objA, objB)
  return objA.data.action > objB.data.action
end

-- Function that creates the scrollList 
function Oversharer:CreateScrollList()
    -- local mainWindow = CreateMainWindow()
    
    -- Create the scrollData table for your scrollList
    local scrollData = {
    name    = "OversharerEvents",
    parent  = OversharerDialog,
    width   = 530,
    height  = 350,
    
    rowHeight       = 23,
    rowTemplate     = "OversharerEntryRow",
    setupCallback   = Oversharer.SetupDataRow,
    sortFunction    = Oversharer.SortScrollListByTime,
    -- selectTemplate  = "EmoteItSelectTemplate",
    -- selectCallback  = OnRowSelection,
    
    -- dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
    -- hideCallback    = OnRowHide,
    -- resetCallback   = OnRowReset,
    
    -- categories  = {1, 2},
    }
    
    -- Call the libraries CreateScrollList
    Oversharer.scrollList = libScroll:CreateScrollList(scrollData)
    -- Anchor it however you want
    Oversharer.scrollList:SetAnchor(TOPLEFT, OversharerDialogHeaders, BOTTOMLEFT, 10, 10)
    Oversharer.scrollList:SetAnchor(BOTTOMRIGHT, OversharerDialog, BOTTOMRIGHT, -10, -40)
    local dt = zo_strformat("<<1>> <<2>>", GetDateStringFromTimestamp(GetTimeStamp()), GetTimeString())
    -- create the tables for your scrollLists data items
    Oversharer.dataItems = {
        [1] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [2] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [3] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [4] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [5] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [6] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [7] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [8] = {time=dt, quest="some quest", action="some action", name="playerName"},
        [9] = {time=dt, quest="some quest", action="some action", name="playerName"},
    }
      -- Call Update to add the data items to the scrollList
    Oversharer.scrollList:Update(Oversharer.dataItems)
end

function Oversharer:Initialize()
  self.hidden = false

  -- Create the scrollList
  Oversharer:CreateScrollList()

  local defaults = {
    selectedGuildId = 1,
    left = 100,
    top = 100,
    width = 500,
    height = 500,
    guildEnabledSend = {false,false,false,false,false},
    guildEnabledReceive = {false,false,false,false,false},
    guildEnabledChatNotify = {false,false,false,false,false}
  }

  -- SET UP SAVED VARIABLES FOR OFFLINE STORAGE
  self.savedVariables = ZO_SavedVars:NewAccountWide("OversharerSavedVariables", 1, nil, defaults)

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

--------------------
-- UI RELATED STUFF
--------------------

function Oversharer:initWindow()
  OversharerDialog:SetHandler("OnMoveStop", function (control)
    Oversharer.savedVariables.left = OversharerDialog:GetLeft()
    Oversharer.savedVariables.top = OversharerDialog:GetTop()
  end)
  OversharerDialog:SetHandler("OnResizeStop", function(control)
    local width, height = control:GetDimensions()
    Oversharer.savedVariables.width = width
    Oversharer.savedVariables.height = height
    Oversharer.scrollList:SetAnchor(BOTTOMRIGHT, OversharerDialog, BOTTOMRIGHT, -10, -40)
  end)
  OversharerDialogTestButton:SetText("TestButton")
  OversharerDialogTestButton:SetHandler("OnClicked", Oversharer.TestButton_Clicked)
  OversharerDialogButtonCloseAddon:SetHandler("OnClicked", Oversharer.ToggleMainWindow)

  -- local sc = WINDOW_MANAGER:GetControlByName("OversharerDialog")
  -- local guildComboBoxControl = sc:GetNamedChild("Guild")
  -- self.guildComboBox = ZO_ComboBox_ObjectFromContainer(guildComboBoxControl)
  self.OnGuildSelectedCallback = function(_, _, entry)
        self:OnGuildSelected(entry)
    end

  self.guildComboBox = Oversharer:FindComboBox()
  self.guildComboBox:SetSortsItems(false)
  self.guildComboBox:SetFont("ZoFontHeader")
  self.guildComboBox:SetSpacing(4)
  
  Oversharer:RefreshGuildList()
  -- Oversharer:SelectGuildComboBox(self.savedVariables.selectedGuildId)
  Oversharer:OnGuildSelected(self.guildComboEntries[self.savedVariables.selectedGuildId])
  ZO_CheckButton_SetToggleFunction(OversharerDialogSendCheck, Oversharer.SendCheckButton_OnToggle)
  ZO_CheckButton_SetToggleFunction(OversharerDialogReceiveCheck, Oversharer.ReceiveCheckButton_OnToggle)
  ZO_CheckButton_SetToggleFunction(OversharerDialogChatNotifyCheck, Oversharer.ChatNotifyCheckButton_OnToggle)

  -- Oversharer:AddCheckboxRows()
  self:RestorePosition()
end

function Oversharer:RefreshGuildList()
  self.guildComboEntries = {}
  self.guildComboBox:ClearItems()
  for i = 1, GetNumGuilds() do
      local guildId = GetGuildId(i)
      if(not self.filterFunction or self.filterFunction(guildId)) then
          local guildName = GetGuildName(guildId)
          local guildAlliance = GetGuildAlliance(guildId) 
          local guildText = zo_iconTextFormat(GetAllianceBannerIcon(guildAlliance), 24, 24, guildName)
          local entry = self.guildComboBox:CreateItemEntry(guildText, self.OnGuildSelectedCallback)
          entry.guildId = guildId
          entry.guildText = guildText
      self.guildComboEntries[guildId] = entry
          self.guildComboBox:AddItem(entry)
      end
  end

  if(next(self.guildComboEntries) == nil) then
      return false
  end

  return true
end

function Oversharer:FindComboBox()
  local sc = WINDOW_MANAGER:GetControlByName("OversharerDialog")
  local guildComboBoxControl = sc:GetNamedChild("Guild")
  return ZO_ComboBox_ObjectFromContainer(guildComboBoxControl)
end

function Oversharer:HeaderTimeClicked()
  if Oversharer.scrollList.SortFunction == Oversharer.SortScrollListByTime then
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByTimeRev
  else
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByTime
  end
  Oversharer.scrollList:Update(Oversharer.dataItems)
end

function Oversharer:HeaderNameClicked()
  if Oversharer.scrollList.SortFunction == Oversharer.SortScrollListByName then
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByNameRev
  else
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByName
  end
  Oversharer.scrollList:Update(Oversharer.dataItems)
end

function Oversharer:HeaderQuestClicked()
end

function Oversharer:HeaderActionClicked()
end

function Oversharer:EntryRowMouseEnter()
  d("EntryRowMouseEnter")
  d(self)
end

function Oversharer:EntryRowMouseExit()
  d("EntryRowMouseExit")
  d(self)
end

function Oversharer:EntryRowMouseUp(button, upInside)
  d("EntryRowMouseUp")
  d(self,button, upInside)
end

function Oversharer.SendCheckButton_OnToggle(checkButton, isChecked)
  Oversharer.savedVariables["guildEnabledSend"][Oversharer.savedVariables.selectedGuildId] = isChecked
end

function Oversharer.ReceiveCheckButton_OnToggle(checkButton, isChecked)
  Oversharer.savedVariables["guildEnabledReceive"][Oversharer.savedVariables.selectedGuildId] = isChecked
end

function Oversharer.ChatNotifyCheckButton_OnToggle(checkButton, isChecked)
  Oversharer.savedVariables["guildEnabledChatNotify"][Oversharer.savedVariables.selectedGuildId] = isChecked
end

function Oversharer:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  OversharerDialog:ClearAnchors()
  OversharerDialog:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  local width = Oversharer.savedVariables.width
  local height = Oversharer.savedVariables.height
  if (width ~= nil and height ~= nil) and (width > 100 and height > 100) then
    OversharerDialog:SetDimensions(width, height)
  else 
    OversharerDialog:SetDimensions(100,100)
  end
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

function Oversharer:OnGuildSelected(entry)
  d(entry.guildId, entry.guildText)
  ZO_CheckButton_SetCheckState(OversharerDialogSendCheck, Oversharer.savedVariables["guildEnabledSend"][entry.guildId])
  ZO_CheckButton_SetCheckState(OversharerDialogReceiveCheck, Oversharer.savedVariables["guildEnabledReceive"][entry.guildId])
  ZO_CheckButton_SetCheckState(OversharerDialogChatNotifyCheck, Oversharer.savedVariables["guildEnabledChatNotify"][entry.guildId])
  Oversharer.savedVariables.selectedGuildId = entry.guildId
  self.guildComboBox:SetSelectedItemText(entry.guildText)
  if(self.selectedCallback) then
      self.selectedCallback(entry.guildId)
  end
end

function Oversharer:SelectGuildComboBox(guildId)
  if self.guildComboBox == nil then self.guildComboBox = Oversharer:FindComboBox() end
  local entry = self.guildComboEntries[guildId]
  self.guildComboBox:SetSelectedItemText(entry.guildText)
end

--[[
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
--]]

function Oversharer.OnAddOnLoaded(event, addonName)
  if addonName == Oversharer.name then
    Oversharer:Initialize()
  end
end

function Oversharer.GuildMemberNoteChanged(event, guildId, displayName, note)
  if Oversharer.savedVariables["guildEnabledReceive"][guildId] == false then 
    return 
  end
  local guildMemberId = GetGuildMemberIndexFromDisplayName(guildId, displayName)
  local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(note)
  if addonData ~= nil then
    d("Oversharer Data from Note:" .. addonData)
    if Oversharer.savedVariables["guildEnabledChatNotify"][Oversharer.savedVariables.selectedGuildId] == true then
      local s = zo_strformat("Guild: <<1>> Member: <<2>> Data: <<3>>", GetGuildName(guildId), displayName, addonData)
      CHAT_SYSTEM:AddMessage(s)
    end
  end
end

--[[
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
--]]

--
-- STUFF
--


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

function Oversharer.ExtractAddonDataFromGuildNote(param)
  local note
  if type(param) == "number" then note = Oversharer.GetOwnMemberNote(param)
  elseif type(param) == "string" then note = param
  else return nil, param
  end
  -- looking for first and last occurrence of the addon pattern
  local osFirst, _ = note:find(Oversharer.pattern)
  local osLast, _ = note:reverse():find(Oversharer.pattern:reverse())
  if (osFirst ~= nil) and (osLast ~= nil) then
    osLast = #note - osLast + 2
    -- cut out the entire addon string, then remove the patterns to get the "pure" data
    local addonData = note:sub(osFirst, osLast):gsub(Oversharer.pattern, "")
    -- if we have data, return the data string and the original note without the datastring
    if addonData ~= nil then
      local noteWithoutData = note:sub(1, osFirst-1) .. note:sub(osLast, #note)
      return addonData, noteWithoutData
    end
  end
  return nil, note
end

function Oversharer.InjectAddonDataIntoGuildNote(guildId, dataString)
  local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(guildId)
  local newNote = noteWithoutData .. Oversharer.pattern .. dataString .. Oversharer.pattern
  Oversharer.SetOwnMemberNote(guildId, newNote)
end

function Oversharer.TestButton_Clicked()
  local time = zo_strformat("<<1>> <<2>>", GetDateStringFromTimestamp(GetTimeStamp()), GetTimeString())
  local playerName = zo_strformat("<<1>> (<<2>>)", GetUnitName('player'), GetDisplayName())
  local uid = zo_strformat("<<1>><<2>><<3>>", GetDisplayName(), GetTimeStamp(), GetGameTimeMilliseconds())
  d(time, playerName, uid)

  -- local scrollData = ZO_ScrollList_GetDataList(scrollList)
  -- d(scrollData)
  
  -- table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {time=time, quest="some quest", action="some action", name=playerName}))
  table.insert(Oversharer.dataItems, {time=time, quest="some quest", action="some action", name=playerName})
  Oversharer.scrollList:Update(Oversharer.dataItems)
  -- ZO_ScrollList_Commit(Oversharer.UnitList)

  -- Oversharer.units[uid] = {time=time, quest="some quest", action="some action", name=playerName}
  -- Oversharer.UnitList:Refresh()
  
  local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(1)
  if addonData ~= nil then
    d("Oversharer Data from Note:" .. addonData)
  end
  Oversharer.InjectAddonDataIntoGuildNote(Oversharer.savedVariables.selectedGuildId, time.." test")
end

EVENT_MANAGER:RegisterForEvent(Oversharer.name,EVENT_ADD_ON_LOADED,Oversharer.OnAddOnLoaded)