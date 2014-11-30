-- F-Zero GX



-- Imports.

-- First make sure that the imported modules get de-cached as needed, since
-- we may be re-running the script in the same run of Cheat Engine.
package.loaded.shared = nil
package.loaded.utils = nil
package.loaded.dolphin = nil

local shared = require "shared"
local utils = require "utils"
local dolphin = require "dolphin"

local readIntBE = utils.readIntBE
local readFloatBE = utils.readFloatBE
local floatToStr = utils.floatToStr
local initLabel = utils.initLabel
local debugDisp = utils.debugDisp
local StatRecorder = utils.StatRecorder

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



-- Data structure for RAM values we care about.

local values = {
  baseStats = {},
  baseStats2 = {},
  state = {},
}



-- Computing RAM values.

local baseStatsBlockOffsets = {
  accel = 0x8,
  body = 0x44,
  boostDuration = 0x34,
  boostInterval = 0x38,
  cameraReorienting = 0x4C,
  cameraRepositioning = 0x50,
  drag = 0x40,
  grip1 = 0x10,
  grip2 = 0x30,
  grip3 = 0x14,
  maxSpeed = 0xC,
  slideTurn = 0x24,
  strafe = 0x28,
  trackCollision = 0x9C,
  turning1 = 0x18,
  turning2 = 0x20,
  turning3 = 0x2C,
  turningAccel = 0x1C,
  turningDecel = 0x3C,
  weight = 0x4,
  
  tilt1a = 0x54,
  tilt2a = 0x5C,
  tilt1b = 0x60,
  tilt2b = 0x68,
  tilt3a = 0x6C,
  tilt4a = 0x74,
  tilt3b = 0x78,
  tilt4b = 0x80,
  tilt1c = 0x84,
  tilt2c = 0x8C,
  tilt1d = 0x90,
  tilt2d = 0x98,
  -- No tilt 3c here.
  tilt4c = 0xA4,
  tilt3d = 0xA8,
  tilt4d = 0xB0,
}

local stateBlockOffsets = {
  accel = 0x220,
  body = 0x30,
  boostDuration = 0x230,
  boostInterval = 0x234,
  cameraReorienting = 0x34,
  cameraRepositioning = 0x38,
  drag = 0x23C,
  grip1 = 0xC,
  grip2 = 0x24,
  grip3 = 0x28,
  maxSpeed = 0x22C,
  obstacleCollision = 0x584,
  slideTurn = 0x18,
  strafe = 0x1C,
  trackCollision = 0x588,
  turning1 = 0x10,
  turning2 = 0x14,
  turning3 = 0x20,
  turningAccel = 0x2C,
  turningDecel = 0x238,
  weight = 0x8,
  
  machineId = 0x6,
  machineName = 0x3C,
  posX = 0x7C,
  posY = 0x80,
  posZ = 0x84,
  velX = 0x94,
  velY = 0x98,
  velZ = 0x9C,
  kmh = 0x17C,
  energy = 0x184,
  
  tilt1a = 0x24C,
  tilt2a = 0x254,
  tilt1b = 0x2A8,
  tilt2b = 0x2B0,
  tilt3a = 0x304,
  tilt4a = 0x30C,
  tilt3b = 0x360,
  tilt4b = 0x368,
  tilt1c = 0x3B4,
  tilt2c = 0x3BC,
  tilt1d = 0x3E4,
  tilt2d = 0x3EC,
  tilt3c = 0x414,
  tilt4c = 0x41C,
  tilt3d = 0x444,
  tilt4d = 0x44C,
}

local tiltFormulas = {
  tilt1 = {
    a = function(v) return v end,
    b = function(v) return -v end,
    c = function(v) return v+0.2 end,
    d = function(v) return -(v+0.2) end,
  },
  
  tilt2 = {
    a = function(v) return v end,
    b = function(v) return v end,
    c = function(v) return v-0.2 end,
    d = function(v) return v-0.2 end,
  },
  
  tilt3 = {
    a = function(v) return v end,
    b = function(v) return -v end,
    c = function(v) return v+0.2 end,
    d = function(v) return -(v+0.2) end,
  },
  
  tilt4 = {
    a = function(v) return v end,
    b = function(v) return v end,
    c = function(v) return v+0.2 end,
    d = function(v) return v+0.2 end,
  },
}

local valueTypes = {
  -- Only add an entry here if it's something other than a float.
  machineName = "string",
}

local maxStringLengthToRead = 64

local function readStateValue(address, key)
  if valueTypes[key] == "string" then
    return readString(address + values.o, maxStringLengthToRead)
  else
    -- float
    return readFloatBE(address + values.o, 4)
  end
end



local compute = {
    
  o = function()
    values.o = dolphin.getGameStartAddress()
  end,
  
  refPointer = function()
    -- Pointer that we'll use for reference.
    -- Not sure what this is meant to point to exactly, but when this pointer
    -- changes value, some other relevant addresses (like the settings
    -- slider value) move by the same amount as the value change.
    local address = 0x801B78A8
    values.refPointer = readIntBE(address + values.o, 4)
  end,
  
  machineStateBlockAddress = function()
    local pointerAddress = values.refPointer + 0x22779C
    values.machineStateBlockAddress = readIntBE(pointerAddress + values.o, 4)
  end,
  
  machineBaseStatsBlockAddress = function()
    local machineIdAddress = values.machineStateBlockAddress + stateBlockOffsets.machineId
    local machineId = readIntBE(machineIdAddress + values.o, 2)
    values.machineBaseStatsBlockAddress = 0x81554000 + (0xB4*machineId)
  end,
  
  baseStats = function(key)
    local address = values.machineBaseStatsBlockAddress + baseStatsBlockOffsets[key]
    values.baseStats[key] = readFloatBE(address + values.o, 4)
  end,
  
  baseStats2 = function(key)
    -- A duplicate of the base stats block. We'll use this as a backup of the
    -- original values, when playing with the values in the primary block. 
    
    local machineIdAddress = values.machineStateBlockAddress + stateBlockOffsets.machineId
    local machineId = readIntBE(machineIdAddress + values.o, 2)
    
    local blockAddress = values.refPointer + 0x195584
    local machineStart = blockAddress + (0xB4*machineId)
    local statAddress = machineStart + baseStatsBlockOffsets[key]
    values.baseStats2[key] = readFloatBE(statAddress + values.o, 4)
  end,
  
  state = function(key)
    local address = values.machineStateBlockAddress + stateBlockOffsets[key]
    values.state[key] = readStateValue(address, key)
  end,
  
  stateOfOtherMachine = function(key, machineIndex)
    local address = (values.machineStateBlockAddress
      + (0x620 * machineIndex)
      + stateBlockOffsets[key])
      
    if values.state[machineIndex] == nil then
      values.state[machineIndex] = {}
    end
    
    values.state[machineIndex][key] = readStateValue(address, key)
  end,
  
  kmh = function()
    -- This address has your km/h speed as displayed in-game on the
    -- *next* frame.
    -- There is no known address for the displayed speed on the current frame,
    -- but we can get that by just taking the previous km/h value.
    local address = values.machineStateBlockAddress + stateBlockOffsets.kmh
    
    values.currKmh = values.nextKmh
    values.nextKmh = readFloatBE(address + values.o, 4)
  end,
  
  numOfMachinesParticipating = function()
    local address = values.refPointer + 0x1BAEE0
    values.numOfMachinesParticipating = readIntBE(address + values.o, 1)
  end,
}



-- Displaying RAM values.

local keysToLabels = {
  accel = "Accel",
  body = "Body",
  boostDuration = "Boost strength",
  boostInterval = "Boost interval",
  cameraReorienting = "Cam. reorienting",
  cameraRepositioning = "Cam. repositioning",
  drag = "Drag",
  turningAccel = "Drift accel",
  grip1 = "Grip 1",
  grip2 = "Grip 2",
  grip3 = "Grip 3",
  maxSpeed = "Max speed",
  obstacleCollision = "Obstacle collision",
  strafe = "Strafe",
  slideTurn = "Strafe turn",
  tilt1 = "Tilt 1",
  tilt2 = "Tilt 2",
  tilt3 = "Tilt 3",
  tilt4 = "Tilt 4",
  trackCollision = "Track collision",
  turning1 = "Turn rotation",
  turning2 = "Turn movement",
  turning3 = "Turn reaction",
  turningDecel = "Turn decel",
  weight = "Weight",
  
  energy = "Energy",
  currKmh = "km/h",
  nextKmh = "km/h (next)",
}

local getStr = {
  
  settingsSlider = function()
    -- Accel/max speed setting; 0 (full accel) to 100 (full max speed).
    local address = values.refPointer + 0x2453A0
    local settingsSlider = readIntBE(address + values.o, 4)
    
    return string.format("Settings: %d%%", settingsSlider)
  end,
  
  flt = function(key, precision)
    local label = keysToLabels[key]
    
    if values[key] == nil then
      return string.format("%s: nil", label)
    end
    
    return string.format("%s: %s", label, floatToStr(values[key], precision))
  end,
  
  baseStats = function(key, precision)
    if precision == nil then precision = 4 end
  
    -- A compute and getStr function rolled into one. This way our layout code
    -- only has to specify each kind of stat once, rather than in separate
    -- compute and getStr calls.
    
    local label, value = nil, nil
    
    if string.sub(key,1,4) == "tilt" then
      compute.baseStats(key.."a")
      label = keysToLabels[key].." (B)"
      value = values.baseStats[key.."a"]
    else
      compute.baseStats(key)
      label = keysToLabels[key].." (B)"
      value = values.baseStats[key]
    end
    
    return string.format(
      "%s: %s", label, floatToStr(value, precision, true)
    )
  end,
  
  state = function(key, precision)
    if precision == nil then precision = 4 end
    
    local label, value = nil, nil
    
    if string.sub(key,1,4) == "tilt" then
      compute.state(key.."a")
      label = keysToLabels[key]
      value = values.state[key.."a"]
    else
      compute.state(key)
      label = keysToLabels[key]
      value = values.state[key]
    end
    
    return string.format(
      "%s: %s", label, floatToStr(value, precision, true)
    )
  end,
  
  stateOfOtherMachine = function(key, machineIndex, precision)
    if precision == nil then precision = 4 end
  
    local index = tonumber(machineIndex)
    if index == nil then return "nil" end
    index = math.floor(index)
  
    if index+1 > values.numOfMachinesParticipating then
      return string.format("Rival machine %d is N/A", index)
    end
    
    compute.stateOfOtherMachine(key, index)
    compute.stateOfOtherMachine("machineName", index)
    local label = (keysToLabels[key] .. ", "
                   .. tostring(values.state[index]["machineName"]))
    return string.format(
      "%s: %s",
      label,
      floatToStr(values.state[index][key], precision, true)
    )
  end,
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



-- GUI layout specifications.

local label1 = nil
local statRecorder = {}

local layoutA = {
  
  init = function(window)
    -- Set the display window's size.
    window:setSize(300, 200)
  
    -- Add a blank label to the window at position (10,5). In the update
    -- function, which is called on every frame, we'll update the label text.
    label1 = initLabel(window, 10, 5, "")
    
    --shared.debugLabel = initLabel(window, 10, 160, "<debug>")
    
    statRecorder = StatRecorder:new(window, 90)
  end,
  
  update = function()
    compute.o()
    compute.refPointer()
    compute.machineStateBlockAddress()
    compute.kmh()
    label1:setCaption(
      table.concat(
        {
          getStr.settingsSlider(),
          getStr.flt("currKmh", 3),
        },
        "\n"
      )
    )
    
    if statRecorder.currentlyTakingStats then
      local s = floatToStr(values.currKmh, 6)
      statRecorder:takeStat(s)
    end
  end,
}

local layoutB = {
  
  init = function(window)
    window:setSize(400, 300)
  
    label1 = initLabel(window, 10, 5, "")
    
    --shared.debugLabel = initLabel(window, 10, 220, "")
  end,
  
  update = function()
    compute.o()
    compute.refPointer()
    compute.machineStateBlockAddress()
    compute.numOfMachinesParticipating()
    label1:setCaption(
      table.concat(
        {
          getStr.state("energy"),
          getStr.stateOfOtherMachine("energy", 1),
          getStr.stateOfOtherMachine("energy", 2),
          getStr.stateOfOtherMachine("energy", 3),
          getStr.stateOfOtherMachine("energy", 4),
          getStr.stateOfOtherMachine("energy", 5),
        },
        "\n"
      )
    )
  end,
}

local layoutC = {
  
  init = function(window)
    window:setSize(300, 130)
  
    label1 = initLabel(window, 10, 5, "")
  end,
  
  update = function()
    compute.o()
    compute.refPointer()
    compute.machineStateBlockAddress()
    compute.machineBaseStatsBlockAddress()
    label1:setCaption(
      table.concat(
        {
          getStr.baseStats("turning2"),
          getStr.state("turning2"),
        },
        "\n"
      )
    )
  end,
}
  


-- Next, another kind of layout that focuses on convenient
-- display and editing of stats.

local editableStats = {
  "accel", "body", "boostDuration", "boostInterval",
  "cameraReorienting", "cameraRepositioning", "drag",
  "grip1", "grip2", "grip3", "maxSpeed", "obstacleCollision",
  "slideTurn", "strafe", "tilt1", "tilt2", "tilt3", "tilt4", 
  "trackCollision", "turning1", "turning2", "turning3",
  "turningAccel", "turningDecel", "weight",
}
local checkBoxes = {}
local statsToDisplay = {}
local addToListButtons = {}
local editButtons = {}
local editWindowHotkeys = {}
local statEditWindow = nil
local updateButton = nil

local function statHasChanged(key)
  -- Check if the primary and backup base stats are different.
  --
  -- Limitation: Assumes that you only change stats by changing their base
  -- values, rather than their actual values.
  --
  -- Limitation: Does not account for base -> actual formulas in two ways:
  -- (1) Actual values of other stats could be changed by changing the base
  -- value of Accel. (2) Actual values could stay the same even when the base
  -- value is different.
  --
  -- Limitation: If the game is paused, then the actual value will not reflect
  -- the base value yet. So the "this is changed" display can be misleading
  -- if you forget that.
  
  if key == "obstacleCollision" then
    -- Obstacle collision doesn't have a base value. Therefore, there isn't a
    -- second base value to compare with, and we have no way of knowing if
    -- the stat has changed. (Unless we figure out how obstacle collision is
    -- derived.)
    return false
  elseif key == "trackCollision" then
    -- Since we change the actual value directly in this case, and there is no
    -- base -> actual formula, we check actual vs. base here.
    compute.state(key)
    compute.baseStats2(key)
    return values.state[key] ~= values.baseStats2[key]
  elseif string.sub(key,1,4) == "tilt" then
    -- Tilt stat.
    -- Since we change the actual value directly in this case, and there is no
    -- base -> actual formula, we check actual vs. base here.
    local key2 = key.."a"
    compute.state(key2)
    compute.baseStats2(key2)
    return values.state[key2] ~= values.baseStats2[key2]
  else
    compute.baseStats(key)
    compute.baseStats2(key)
    return values.baseStats[key] ~= values.baseStats2[key]
  end
end

local function updateDisplay()
  compute.o()
  compute.refPointer()
  compute.machineStateBlockAddress()
  compute.machineBaseStatsBlockAddress()
  
  local statLines = {}
  for statN, key in pairs(statsToDisplay) do
    local line = getStr.state(key)
    if statHasChanged(key) then line = line.."*" end
    table.insert(statLines, line)
  end
  label1:setCaption(table.concat(statLines, "\n"))
end

local function openStatEditWindow(key)

  local initialText, windowTitle, setValue, resetValue = nil, nil, nil, nil

  if key == "obstacleCollision" then
  
    -- Obstacle collision doesn't have a base value. So we'll work with the
    -- actual value instead. This works because the actual value isn't
    -- "guarded" by an instruction that writes to it every frame, unlike
    -- most of the other stats.
  
    compute.state(key)
    initialText = tostring(values.state[key])
    windowTitle = string.format("Edit: %s actual value", keysToLabels[key])
    
    setValue = function(key, v)
      local address = values.machineStateBlockAddress + stateBlockOffsets[key]
      utils.writeFloatBE(address + values.o, v, 4)
    end
    
    resetValue = function(statField, key)
      -- Since there is no base value, there is no backup base value, and so
      -- we don't know how to reset this.
      return
    end
    
  elseif key == "trackCollision" then
  
    -- This does have a base value, but editing the base value does nothing
    -- to the actual value. So we'll edit the actual value directly.
  
    compute.state(key)
    initialText = tostring(values.state[key])
    windowTitle = string.format("Edit: %s actual value", keysToLabels[key])
    
    setValue = function(key, v)
      local address = values.machineStateBlockAddress + stateBlockOffsets[key]
      utils.writeFloatBE(address + values.o, v, 4)
    end
    
    resetValue = function(statField, key)
      compute.baseStats2(key)
      local baseStat2 = values.baseStats2[key]
      statField.Text = tostring(baseStat2)
    end
    
  elseif string.sub(key,1,4) == "tilt" then
  
    -- The key starts with "tilt".
    -- Change the key: tilt1 -> tilt1a, etc.
    compute.baseStats(key.."a")
    initialText = tostring(values.state[key.."a"])
    windowTitle = string.format("Edit: %s actual values", keysToLabels[key])
    
    setValue = function(key, v)
      -- Change actual value directly; changing base doesn't change actual here
      for keySuffix, func in pairs(tiltFormulas[key]) do
        local address = (values.machineStateBlockAddress
          + stateBlockOffsets[key..keySuffix])
        utils.writeFloatBE(address + values.o, func(v), 4)
      end
    end
    
    resetValue = function(statField, key)
      compute.baseStats2(key.."a")
      local baseStat2 = values.baseStats2[key.."a"]
      statField.Text = tostring(baseStat2)
    end
    
  else
  
    compute.baseStats(key)
    initialText = tostring(values.baseStats[key])
    windowTitle = string.format("Edit: %s base value", keysToLabels[key])
    
    setValue = function(key, v)
      local address = values.machineBaseStatsBlockAddress + baseStatsBlockOffsets[key]
      utils.writeFloatBE(address + values.o, v, 4)
    end
    
    resetValue = function(statField, key)
      compute.baseStats2(key)
      local baseStat2 = values.baseStats2[key]
      statField.Text = tostring(baseStat2)
    end
    
  end
  
  local font = nil
  
  -- Create an edit window
  local window = createForm(true)
  window:setSize(400, 50)
  window:centerScreen()
  window:setCaption(windowTitle)
  font = window:getFont()
  font:setName("Calibri")
  font:setSize(10)
  
  -- Add a text box, with the baseStat value, full decimal places
  local statField = createEdit(window)
  statField:setPosition(70, 10)
  statField:setSize(200, 20)
  statField.Text = initialText
  
  -- Put an OK button in the window, which would change the base stat
  -- to the value entered, and close the window
  local okButton = createButton(window)
  okButton:setPosition(300, 10)
  okButton:setCaption("OK")
  okButton:setSize(30, 25)
  local confirmValueAndCloseWindow = function(window, statField, key)
    local newValue = tonumber(statField.Text)
    if newValue ~= nil then
      setValue(key, newValue)
      
      -- Update the display. Delay for a bit first, because it seems that the
      -- write to the memory address needs a bit of time to take effect.
      sleep(50)
      updateDisplay()
    end
    window:close()
  end
  
  local okAction = utils.curry(confirmValueAndCloseWindow, window, statField, key)
  okButton:setOnClick(okAction)
  
  -- Put a Cancel button in the window, which would close the window
  local cancelButton = createButton(window)
  cancelButton:setPosition(340, 10)
  cancelButton:setCaption("Cancel")
  cancelButton:setSize(50, 25)
  local closeWindow = function(window)
    window:close()
  end
  cancelButton:setOnClick(utils.curry(closeWindow, window))
  
  -- Add a reset button, which would reset the value to baseStat2
  local resetButton = createButton(window)
  resetButton:setPosition(5, 10)
  resetButton:setCaption("Reset")
  resetButton:setSize(50, 25)
  resetButton:setOnClick(utils.curry(resetValue, statField, key))
  
  -- Put the initial focus on the stat field.
  statField:setFocus()
end

local function addStatAddressToList(key)
  local addressList = getAddressList()
  local listEntries = {}
  
  -- We'll actually add two types of entries: actual stat and base stat.
  -- The base stat is more convenient to edit, because the actual stat usually
  -- needs disabling an instruction (which writes to the address every frame)
  -- before it can be edited. But editing the actual stat avoids having to
  -- consider the base -> actual conversion math.
  
  -- First we'll do the actual stat.
  if string.sub(key,1,4) == "tilt" then
    for keySuffix, func in pairs(tiltFormulas[key]) do
      table.insert(listEntries, {
        address = (values.machineStateBlockAddress
          + stateBlockOffsets[key..keySuffix] + values.o),
        description = keysToLabels[key] .. keySuffix,
        displayType = vtCustom,
        customTypeName = "Float Big Endian",
      })
    end
  else
    table.insert(listEntries, {
      address = values.machineStateBlockAddress + stateBlockOffsets[key] + values.o,
      description = keysToLabels[key],
      -- For the memory record type constants, look up defines.lua in
      -- your Cheat Engine folder.
      displayType = vtCustom,
      customTypeName = "Float Big Endian",
    })
  end
  
  -- Now the base stat.
  
  if string.sub(key,1,4) == "tilt" then
    -- Changing the base tilt values doesn't change the actual values, so no
    -- particular use in adding this to the list.
  elseif key == "obstacleCollision" or key == "trackCollision" then
    -- These don't have a base value. The actual value can be
    -- changed directly without disabling an instruction, anyways.
  else
    table.insert(listEntries, {
      address = (values.machineBaseStatsBlockAddress
        + baseStatsBlockOffsets[key] + values.o),
      description = keysToLabels[key] .. " (base)",
      displayType = vtCustom,
      customTypeName = "Float Big Endian",
    })
  end
  
  for _, entry in pairs(listEntries) do
    memoryRecord = addressList:createMemoryRecord()
    -- setAddress doesn't work for some reason, despite being in the Help docs?
    memoryRecord.Address = utils.intToHexStr(entry.address)
    memoryRecord:setDescription(entry.description)
    memoryRecord.Type = entry.displayType
    memoryRecord.CustomTypeName = entry.customTypeName
  end
end

local function rebuildStatsDisplay(window)
  statsToDisplay = {}
  
  -- Remove the previous buttons
  for _, button in pairs(addToListButtons) do
    button.destroy()
  end
  for _, button in pairs(editButtons) do
    button.destroy()
  end
  addToListButtons = {}
  editButtons = {}
  
  for boxN, checkBox in pairs(checkBoxes) do
    if checkBox:getState() == 1 then
      -- Box is checked; include this stat in the display.
      
      -- Include the stat display
      local statKey = editableStats[boxN]
      table.insert(statsToDisplay, statKey)
      
      -- Include an edit button
      local editButton = createButton(window)
      local posY = 28*(#statsToDisplay - 1) + 5
      editButton:setPosition(250, posY)
      editButton:setCaption("Edit")
      editButton:setSize(40, 20)
      local font = editButton:getFont()
      font:setSize(10)
      
      editButton:setOnClick(utils.curry(openStatEditWindow, statKey))
      table.insert(editButtons, editButton)
  
      -- Include an add-to-address-list button
      local listButton = createButton(window)
      local posY = 28*(#statsToDisplay - 1) + 5
      listButton:setPosition(300, posY)
      listButton:setCaption("List")
      listButton:setSize(40, 20)
      local font = listButton:getFont()
      font:setSize(10)
      
      listButton:setOnClick(utils.curry(addStatAddressToList, statKey))
      table.insert(addToListButtons, listButton)
    end
  end
end

local function addStatCheckboxes(window, initiallyCheckedStats)
  -- Make a list of checkboxes, one for each possible stat to look at.
    
  -- Making sets in Lua is kind of roundabout.
  -- http://www.lua.org/pil/11.5.html
  local isStatInitiallyChecked = {}
  for _, key in pairs(initiallyCheckedStats) do
    isStatInitiallyChecked[key] = true
  end
  
  for statN, key in pairs(editableStats) do
    local checkBox = createCheckBox(window)
    local posY = 20*(statN-1) + 5
    checkBox:setPosition(350, posY)
    checkBox:setCaption(keysToLabels[key])
    
    local font = checkBox:getFont()
    font:setSize(9)
    
    -- When a checkbox is checked, the corresponding stat is displayed.
    checkBox:setOnChange(utils.curry(rebuildStatsDisplay, window))
    
    if isStatInitiallyChecked[key] then
      checkBox:setState(1)
    end
    
    table.insert(checkBoxes, checkBox)
  end
  
  -- Ensure that the initially checked stats actually get initially checked.
  rebuildStatsDisplay(window)
end



local layoutD = {
  
  init = function(window)
    window:setSize(550, 510)
  
    label1 = initLabel(window, 10, 5, "")
    local font = label1:getFont()
    font:setSize(14)

    local initiallyCheckedStats = {"accel", "maxSpeed", "weight"}
    addStatCheckboxes(window, initiallyCheckedStats)
    
    --shared.debugLabel = initLabel(window, 10, 350, "")
  end,
  
  update = function()
    updateDisplay()
  end,
}



local layoutE = {
  
  -- Version of layoutD that updates the display with an update button,
  -- instead of automatically on every frame. This is fine because the stats
  -- don't change often (only when you change them, or change machine or
  -- settings).
  -- By not updating on every frame, this version can keep Dolphin running
  -- much more smoothly.
  
  onlyUpdateManually = true,
  
  init = function(window)
    window:setSize(550, 510)
  
    label1 = initLabel(window, 10, 5, "")
    local font = label1:getFont()
    font:setSize(14)

    local initiallyCheckedStats = {"accel", "maxSpeed", "weight"}
    addStatCheckboxes(window, initiallyCheckedStats)
    
    updateButton = createButton(window)
    updateButton:setPosition(10, 460)
    updateButton:setCaption("Update")
    local font = updateButton:getFont()
    font:setSize(12)
    
    -- Update the display via a button this time,
    -- instead of via a function that auto-runs on every frame.
    updateButton:setOnClick(updateDisplay)
    updateDisplay()
    
    --shared.debugLabel = initLabel(window, 10, 350, "")
  end,
}



-- *** CHOOSE YOUR LAYOUT HERE ***
local layout = layoutA



-- Initializing the GUI window.

local window = createForm(true)
-- Put it in the center of the screen.
window:centerScreen()
-- Set the window title.
window:setCaption("RAM Display")
-- Customize the font.
local font = window:getFont()
font:setName("Calibri")
font:setSize(16)

layout.init(window)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



-- This sets a breakpoint at a particular instruction which should be
-- called exactly once every frame. (Unless the layout doesn't require it.)

debug_removeBreakpoint(getAddress("Dolphin.exe")+dolphin.oncePerFrameAddress)
if not layout.onlyUpdateManually then
  debug_setBreakpoint(getAddress("Dolphin.exe")+dolphin.oncePerFrameAddress)
end

-- If the oncePerFrameAddress was chosen correctly, everything in the
-- following function should run exactly once every frame. 

function debugger_onBreakpoint()
  
  layout.update()

  return 1

end

