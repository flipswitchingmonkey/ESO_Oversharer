local libScroll = LibStub:GetLibrary("LibScroll")

Oversharer = {}
Oversharer.name = "Oversharer"
Oversharer.pattern = "::OS::"
Oversharer.writeNoteSemaphore = false
Oversharer.writeNoteDelay = 0
Oversharer.writeNoteDelayAdd = 5000
Oversharer.newGuildNoteGlobal = ""
Oversharer.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1)
Oversharer.QUEST_ADDED = 1
Oversharer.QUEST_REMOVED = 2
Oversharer.QUEST_COMPLETE = 3
Oversharer.scrollList = nil
Oversharer.dataItems = {
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
}
Oversharer.columnWidthUnit = 26
Oversharer.columnUnits = { 0, 3, 4, 3}

function Oversharer.strSplit(delim,str)
  local t = {}
  for substr in string.gmatch(str, "[^".. delim.. "]*") do
      if substr ~= nil and string.len(substr) > 0 then
          table.insert(t,substr)
      end
  end
  return t
end

function Oversharer.SetupDataRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    rowControl.data = data
    rowControl.name = GetControl(rowControl, "Name")
    rowControl.time = GetControl(rowControl, "Time")
    rowControl.quest = GetControl(rowControl, "Quest")
    rowControl.message = GetControl(rowControl, "Message")

    rowControl.name:SetText(data.name)
    rowControl.time:SetText(data.time)
    rowControl.quest:SetText(data.quest)
    rowControl.message:SetText(data.message)

    rowControl.name.normalColor = Oversharer.DEFAULT_TEXT
    rowControl.time.normalColor = Oversharer.DEFAULT_TEXT
    rowControl.quest.normalColor = Oversharer.DEFAULT_TEXT
    rowControl.message.normalColor = Oversharer.DEFAULT_TEXT
    -- rowControl:SetText(data.name)

    rowControl.name:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[2], 32)
    rowControl.quest:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[3], 32)
    rowControl.message:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[4], 32)

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

function Oversharer.SortScrollListByMessage(objA, objB)
  return objA.data.message < objB.data.message
end

function Oversharer.SortScrollListByMessageRev(objA, objB)
  return objA.data.message > objB.data.message
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
    -- Oversharer.dataItems[1] = {
    --     [1] = {time=dt, quest="some quest", message="some message", name="playerName"},
    --     [2] = {time=dt, quest="some quest", message="some message", name="playerName"},
    -- }
    -- Call Update to add the data items to the scrollList
    Oversharer.scrollList:Update(Oversharer.dataItems[1])
end

function Oversharer:Initialize()
  self.hidden = false

  self.locale = GetCVar('Language.2')
  if self.locale ~= 'en' and self.locale ~= 'de' and self.locale ~= 'fr' and self.locale ~= 'jp' then
    self.locale = 'en'
  end

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
  EVENT_MANAGER:RegisterForEvent(Oversharer.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, Oversharer.GuildMemberNoteChanged)
  EVENT_MANAGER:RegisterForEvent(Oversharer.name, EVENT_QUEST_ADDED, Oversharer.OnQuestAdded)
  EVENT_MANAGER:RegisterForEvent(Oversharer.name, EVENT_QUEST_COMPLETE, Oversharer.OnQuestComplete)
  EVENT_MANAGER:RegisterForEvent(Oversharer.name, EVENT_QUEST_REMOVED, Oversharer.OnQuestRemoved)
  
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
    Oversharer.columnWidthUnit = (width - 128) / 10.0
    OversharerDialogHeadersName:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[2], 25)
    OversharerDialogHeadersQuest:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[3], 25)
    OversharerDialogHeadersMessage:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[4], 25)
    Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
  end)
  OversharerDialogTestButton:SetText("TestButton")
  OversharerDialogTestButton:SetHandler("OnClicked", Oversharer.TestButton_Clicked)
  OversharerDialogButtonCloseAddon:SetHandler("OnClicked", Oversharer.ToggleMainWindow)

  self.OnGuildSelectedCallback = function(_, _, entry)
        self:OnGuildSelected(entry)
    end

  self.guildComboBox = Oversharer:FindComboBox()
  self.guildComboBox:SetSortsItems(false)
  self.guildComboBox:SetFont("ZoFontHeader")
  self.guildComboBox:SetSpacing(4)
  
  Oversharer:RefreshGuildList()
  Oversharer:OnGuildSelected(self.guildComboEntries[self.savedVariables.selectedGuildId])
  ZO_CheckButton_SetToggleFunction(OversharerDialogSendCheck, Oversharer.SendCheckButton_OnToggle)
  ZO_CheckButton_SetToggleFunction(OversharerDialogReceiveCheck, Oversharer.ReceiveCheckButton_OnToggle)
  ZO_CheckButton_SetToggleFunction(OversharerDialogChatNotifyCheck, Oversharer.ChatNotifyCheckButton_OnToggle)

  self:RestorePosition()
  Oversharer.InitialGuildNoteRead()
end

function Oversharer.OnQuestAdded(event, journalIndex, questName, objectiveName)
  local encodedString = Oversharer.EncodeDataString(questName, Oversharer.QUEST_ADDED)
  if encodedString ~= nil then Oversharer.InjectAddonDataIntoGuildNote(encodedString) end
end

function Oversharer.OnQuestComplete(event, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
  local encodedString = Oversharer.EncodeDataString(questName, Oversharer.QUEST_COMPLETE)
  if encodedString ~= nil then Oversharer.InjectAddonDataIntoGuildNote(encodedString) end
end

function Oversharer.OnQuestRemoved(event, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
  local encodedString = Oversharer.EncodeDataString(questName, Oversharer.QUEST_REMOVED)
  if encodedString ~= nil then Oversharer.InjectAddonDataIntoGuildNote(encodedString) end
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
  Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
end

function Oversharer:HeaderNameClicked()
  if Oversharer.scrollList.SortFunction == Oversharer.SortScrollListByName then
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByNameRev
  else
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByName
  end
  Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
end

function Oversharer:HeaderQuestClicked()
  if Oversharer.scrollList.SortFunction == Oversharer.SortScrollListByQuest then
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByQuestRev
  else
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByQuest
  end
  Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
end

function Oversharer:HeaderMessageClicked()
  if Oversharer.scrollList.SortFunction == Oversharer.SortScrollListByMessage then
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByMessageRev
  else
    Oversharer.scrollList.SortFunction = Oversharer.SortScrollListByMessage
  end
  Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
end

-- function Oversharer:EntryRowMouseEnter()
--   d("EntryRowMouseEnter")
--   d(self)
-- end

-- function Oversharer:EntryRowMouseExit()
--   d("EntryRowMouseExit")
--   d(self)
-- end

-- function Oversharer:EntryRowMouseUp(button, upInside)
--   d("EntryRowMouseUp")
--   d(self,button, upInside)
-- end

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
  Oversharer.columnWidthUnit = (width - 128) / 10.0
  OversharerDialogHeadersName:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[2], 25)
  OversharerDialogHeadersQuest:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[3], 25)
  OversharerDialogHeadersMessage:SetDimensions(Oversharer.columnWidthUnit * Oversharer.columnUnits[4], 25)
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
  -- d(entry.guildId, entry.guildText)
  ZO_CheckButton_SetCheckState(OversharerDialogSendCheck, Oversharer.savedVariables["guildEnabledSend"][entry.guildId])
  ZO_CheckButton_SetCheckState(OversharerDialogReceiveCheck, Oversharer.savedVariables["guildEnabledReceive"][entry.guildId])
  ZO_CheckButton_SetCheckState(OversharerDialogChatNotifyCheck, Oversharer.savedVariables["guildEnabledChatNotify"][entry.guildId])
  Oversharer.savedVariables.selectedGuildId = entry.guildId
  Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
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

function Oversharer.InitialGuildNoteRead()
  for i=1,GetNumGuilds()+1,1 do
    if DoesPlayerHaveGuildPermission(i, GUILD_PERMISSION_NOTE_READ) == true then
      if Oversharer.savedVariables["guildEnabledReceive"][i] == true then 
        for j=1,GetNumGuildMembers(i)+1,1 do
          local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(i, j)
          if note ~= nil then
            local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(note)
            if addonData ~= nil then
              -- d(addonData)
              Oversharer.AddRow(addonData,name)
            end
          end
        end
      end
    end
  end
  Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
end

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
    -- d("Oversharer Data from Note:" .. addonData)
    -- if Oversharer.savedVariables["guildEnabledChatNotify"][Oversharer.savedVariables.selectedGuildId] == true then
    --   local s = zo_strformat("Guild: <<1>> Member: <<2>> Data: <<3>>", GetGuildName(guildId), displayName, addonData)
    --   CHAT_SYSTEM:AddMessage(s)
    -- end
    Oversharer.AddRow(addonData, displayName)
  end
end

function Oversharer.AddRow(dataString, playerName)
  -- if dataString == nil then return end
  -- local data = Oversharer.strSplit("##", dataString)
  -- if data == nil or #data < 3 then return end
  -- d("AddRow", data)
  -- local questId = tonumber(data[2])
  -- if questId == nil then return end
  -- local questName = Oversharer_GetQuestNameByIdAndLang(questId, Oversharer.locale)
  -- if questName == nil then questName = data[2] end
  -- local action = tonumber(data[3])
  -- if action == nil then return end
  -- local msg = ""
  -- if action==Oversharer.QUEST_ADDED then msg = "Started Quest."
  -- elseif action==Oversharer.QUEST_REMOVED then msg = "Abbandoned Quest."
  -- elseif action==Oversharer.QUEST_COMPLETE then msg = "Completed Quest."
  -- end
  local data = Oversharer.DecodeDataString(dataString, playerName)
  if data == nil then return end
  -- table.insert(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId], {time=data[1], quest=questName, message=msg, name=playerName})
  table.insert(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId], data)
  Oversharer.scrollList:Update(Oversharer.dataItems[Oversharer.savedVariables.selectedGuildId])
  if Oversharer.savedVariables["guildEnabledChatNotify"][Oversharer.savedVariables.selectedGuildId] == true then
    local s = zo_strformat("Oversharer: <<1>> - <<2>> - <<3>> - <<4>>", data.time, data.name, data.quest, data.message)
    CHAT_SYSTEM:AddMessage(s)
  end
end

function Oversharer.EncodeDataString(questName, action)
  local time = Oversharer.GetTimeString()
  local questId, questData = Oversharer_GetQuestDataByName(questName)
  if questData == nil then
    d("No Quest Data found - maybe not a daily quest or no translation?")
    return nil
  end
  return zo_strformat("<<1>>##<<2>>##<<3>>", time, questId, action)
end

function Oversharer.DecodeDataString(dataString, playerName)
  if dataString == nil then return end
  local data = Oversharer.strSplit("##", dataString)
  if data == nil or #data < 3 then return end
  -- d("AddRow", data)
  local questId = tonumber(data[2])
  local action = tonumber(data[3])
  if questId == nil then return end
  if action == nil then return end
  local questName = Oversharer_GetQuestNameByIdAndLang(questId, Oversharer.locale)
  if questName == nil then questName = data[2] end
  local msg = ""
  if action==Oversharer.QUEST_ADDED then msg = "Started Quest."
  elseif action==Oversharer.QUEST_REMOVED then msg = "Abandoned Quest."
  elseif action==Oversharer.QUEST_COMPLETE then msg = "Completed Quest."
  end
  return {time=data[1], quest=questName, message=msg, name=playerName}
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
  -- Oversharer.newGuildNoteGlobal = note
  -- Do not call this too often, as it is a rate-limited function
  -- Calling it too often per minute will kick the player
  -- if Oversharer.writeNoteSemaphore == false then
  -- Oversharer.writeNoteSemaphore = true
  if Oversharer.writeNoteDelay == 0 then
    SetGuildMemberNote(guildId, guildMemberId, note)
    Oversharer.writeNoteDelay = Oversharer.writeNoteDelay + Oversharer.writeNoteDelayAdd
    -- d("+Oversharer.writeNoteDelayAdd", Oversharer.writeNoteDelay)
    zo_callLater(function() 
        Oversharer.writeNoteDelay = Oversharer.writeNoteDelay - Oversharer.writeNoteDelayAdd
        -- d("-Oversharer.writeNoteDelayAdd", Oversharer.writeNoteDelay)
      end, Oversharer.writeNoteDelay)
  else
    Oversharer.writeNoteDelay = Oversharer.writeNoteDelay + Oversharer.writeNoteDelayAdd
    -- d("+Oversharer.writeNoteDelayAdd", Oversharer.writeNoteDelay)
    zo_callLater(function() 
        SetGuildMemberNote(guildId, guildMemberId, note)
        Oversharer.writeNoteDelay = Oversharer.writeNoteDelay - Oversharer.writeNoteDelayAdd
      end, Oversharer.writeNoteDelay)
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

function Oversharer.InjectAddonDataIntoGuildNote(dataString)
  for i=1,GetNumGuilds()+1,1 do
    if DoesPlayerHaveGuildPermission(i, GUILD_PERMISSION_NOTE_EDIT) == true then
      if Oversharer.savedVariables["guildEnabledSend"][i] == true then
        local addonData, noteWithoutData = Oversharer.ExtractAddonDataFromGuildNote(i)
        local newNote = noteWithoutData .. Oversharer.pattern .. dataString .. Oversharer.pattern
        Oversharer.SetOwnMemberNote(i, newNote)
      end
    end
  end
end

function Oversharer.GetTimeString()
  return zo_strformat("<<1>> <<2>>", GetDateStringFromTimestamp(GetTimeStamp()), GetTimeString())
end

function Oversharer.TestButton_Clicked()
  local time = Oversharer.GetTimeString()
  local playerName = zo_strformat("<<1>> (<<2>>)", GetUnitName('player'), GetDisplayName())
  -- d(time, playerName, uid)
  local s = zo_strformat("<<1>>##<<2>>##<<3>>",time,"5743",Oversharer.QUEST_ADDED)
  --Oversharer.AddRow(s,GetDisplayName())
  Oversharer.InjectAddonDataIntoGuildNote(s)
end

EVENT_MANAGER:RegisterForEvent(Oversharer.name,EVENT_ADD_ON_LOADED,Oversharer.OnAddOnLoaded)