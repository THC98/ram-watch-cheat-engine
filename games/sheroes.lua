package.loaded.utils = nil
local utils = require 'utils'
local subclass = utils.subclass

package.loaded.dolphin = nil
local dolphin = require 'dolphin'

local MyGame = subclass(dolphin.DolphinGame)

--local angles = require "games.sheroes_angles"

MyGame.supportedGameVersions = {
  na = 'G9SE8P',
}

MyGame.layoutModuleNames = {'sheroes_layouts'}
MyGame.framerate = 60

function MyGame:init(options)
  dolphin.DolphinGame.init(self, options)

  self.startAddress = self:getGameStartAddress()
end

local sonicPrevAction = 0
local knucklesPrevAction = 0

local sonicKickCount = 0
local knucklesDiveCount = 0

local RTATimes = {
  [2] = "2:30.06", -- Seaside Hill
  [3] = "1:58.59", -- Ocean Palace
  [16] = "0:15.18", -- Egg Hawk
  [4] = "2:16.03", -- Grand Metropolis
  [5] = "4:18.79", -- Power Plant
  [17] = "0:06.39", -- Team Rose
  [6] = "0:37.53", -- Casino Park
  [7] = "1:51.04", -- Bingo Highway
  [18] = "1:20.00", -- Robot Carnival
  [8] = "1:43.79", -- Rail Canyon
  [9] = "0:56.78", -- Bullet Station
  [19] = "0:18.68", -- Egg Albatross
  [10] = "0:57.89", -- Frog Forest
  [11] = "2:38.73", -- Lost Jungle
  [20] = "0:06.83", -- Team Dark
  [12] = "1:25.88", -- Hang Castle
  [13] = "2:25.91", -- Mystic Mansion
  [21] = "1:53.76", -- Robot Storm
  [14] = "4:02.29", -- Egg Fleet
  [15] = "3:23.09", -- Final Fortress
  [22] = "0:15.78" -- Egg Emperor
}

-- Pointers addresses update

function MyGame:updateAddresses()
  local pointerChar1 = self.startAddress + 0x2AD070 + readBytes(self.startAddress + 0x9D986A, 1, false) * 4
  local pointerChar2 = self.startAddress + 0x2AD090 + readBytes(self.startAddress + 0x9D986A, 1, false) * 4
  local pointerChar3 = self.startAddress + 0x2AD0B0 + readBytes(self.startAddress + 0x9D986A, 1, false) * 4
  local pointerChar4 = self.startAddress + 0x2AD0D0 + readBytes(self.startAddress + 0x9D986A, 1, false) * 4

  local sonicPointerChar1 = self.startAddress + 0x2AD070
  local sonicPointerChar2 = self.startAddress + 0x2AD090
  local sonicPointerChar3 = self.startAddress + 0x2AD0B0
  local sonicPointerChar4 = self.startAddress + 0x2AD0D0

  local tailsPointerChar1 = self.startAddress + 0x2AD074
  local tailsPointerChar2 = self.startAddress + 0x2AD094
  local tailsPointerChar3 = self.startAddress + 0x2AD0B4
  local tailsPointerChar4 = self.startAddress + 0x2AD0D4

  local knucklesPointerChar1 = self.startAddress + 0x2AD078
  local knucklesPointerChar2 = self.startAddress + 0x2AD098
  local knucklesPointerChar3 = self.startAddress + 0x2AD0B8
  local knucklesPointerChar4 = self.startAddress + 0x2AD0D8

  if pointerChar1 == 0 then
	self.pointerChar1Value = nil
  else
	self.pointerChar1Value = self.startAddress + utils.readIntBE(pointerChar1) - 0x80000000
  end
  
  if pointerChar2 == 0 then
	self.pointerChar2Value = nil
  else
	self.pointerChar2Value = self.startAddress + utils.readIntBE(pointerChar2) - 0x80000000
  end
  
  if pointerChar3 == 0 then
	self.pointerChar3Value = nil
  else
	self.pointerChar3Value = self.startAddress + utils.readIntBE(pointerChar3) - 0x80000000
  end
  
  if pointerChar4 == 0 then
	self.pointerChar4Value = nil
  else
	self.pointerChar4Value = self.startAddress + utils.readIntBE(pointerChar4) - 0x80000000
  end

  if sonicPointerChar1 == 0 then
  self.sonicPointerChar1Value = nil
  else
  self.sonicPointerChar1Value = self.startAddress + utils.readIntBE(sonicPointerChar1) - 0x80000000
  end
  
  if sonicPointerChar2 == 0 then
  self.sonicPointerChar2Value = nil
  else
  self.sonicPointerChar2Value = self.startAddress + utils.readIntBE(sonicPointerChar2) - 0x80000000
  end
  
  if sonicPointerChar3 == 0 then
  self.sonicPointerChar3Value = nil
  else
  self.sonicPointerChar3Value = self.startAddress + utils.readIntBE(sonicPointerChar3) - 0x80000000
  end
  
  if sonicPointerChar4 == 0 then
  self.sonicPointerChar4Value = nil
  else
  self.sonicPointerChar4Value = self.startAddress + utils.readIntBE(sonicPointerChar4) - 0x80000000
  end

  if tailsPointerChar1 == 0 then
  self.tailsPointerChar1Value = nil
  else
  self.tailsPointerChar1Value = self.startAddress + utils.readIntBE(tailsPointerChar1) - 0x80000000
  end
  
  if tailsPointerChar2 == 0 then
  self.tailsPointerChar2Value = nil
  else
  self.tailsPointerChar2Value = self.startAddress + utils.readIntBE(tailsPointerChar2) - 0x80000000
  end
  
  if tailsPointerChar3 == 0 then
  self.tailsPointerChar3Value = nil
  else
  self.tailsPointerChar3Value = self.startAddress + utils.readIntBE(tailsPointerChar3) - 0x80000000
  end
  
  if tailsPointerChar4 == 0 then
  self.tailsPointerChar4Value = nil
  else
  self.tailsPointerChar4Value = self.startAddress + utils.readIntBE(tailsPointerChar4) - 0x80000000
  end

  if knucklesPointerChar1 == 0 then
  self.knucklesPointerChar1Value = nil
  else
  self.knucklesPointerChar1Value = self.startAddress + utils.readIntBE(knucklesPointerChar1) - 0x80000000
  end
  
  if knucklesPointerChar2 == 0 then
  self.knucklesPointerChar2Value = nil
  else
  self.knucklesPointerChar2Value = self.startAddress + utils.readIntBE(knucklesPointerChar2) - 0x80000000
  end
  
  if knucklesPointerChar3 == 0 then
  self.knucklesPointerChar3Value = nil
  else
  self.knucklesPointerChar3Value = self.startAddress + utils.readIntBE(knucklesPointerChar3) - 0x80000000
  end
  
  if knucklesPointerChar4 == 0 then
  self.knucklesPointerChar4Value = nil
  else
  self.knucklesPointerChar4Value = self.startAddress + utils.readIntBE(knucklesPointerChar4) - 0x80000000
  end
end


local valuetypes = require "valuetypes"
local V = valuetypes.V
local GV = MyGame.blockValues
local MV = valuetypes.MV
local Block = valuetypes.Block
local Value = valuetypes.Value
local ShortType = valuetypes.ShortTypeBE
local FloatType = valuetypes.FloatTypeBE
local IntType = valuetypes.IntTypeBE
local ByteType = valuetypes.ByteType
local BinaryType = valuetypes.BinaryType

package.loaded.layouts = nil
local layoutsModule = require 'layouts'


-- Pointer based and static values updates

local StaticValue = subclass(valuetypes.MemoryValue)
function StaticValue:getAddress()
  return self.game.startAddress + self.offset
end

local PointerBasedChar1Value = subclass(valuetypes.MemoryValue)
function PointerBasedChar1Value:getAddress()
  return self.game.pointerChar1Value + self.offset
end

local PointerBasedChar2Value = subclass(valuetypes.MemoryValue)
function PointerBasedChar2Value:getAddress()
  return self.game.pointerChar2Value + self.offset
end

local PointerBasedChar3Value = subclass(valuetypes.MemoryValue)
function PointerBasedChar3Value:getAddress()
  return self.game.pointerChar3Value + self.offset
end

local PointerBasedChar4Value = subclass(valuetypes.MemoryValue)
function PointerBasedChar4Value:getAddress()
  return self.game.pointerChar4Value + self.offset
end


local PointerBasedSonicChar1Value = subclass(valuetypes.MemoryValue)
function PointerBasedSonicChar1Value:getAddress()
  return self.game.sonicPointerChar1Value + self.offset
end

local PointerBasedSonicChar2Value = subclass(valuetypes.MemoryValue)
function PointerBasedSonicChar2Value:getAddress()
  return self.game.sonicPointerChar2Value + self.offset
end

local PointerBasedSonicChar3Value = subclass(valuetypes.MemoryValue)
function PointerBasedSonicChar3Value:getAddress()
  return self.game.sonicPointerChar3Value + self.offset
end

local PointerBasedSonicChar4Value = subclass(valuetypes.MemoryValue)
function PointerBasedSonicChar4Value:getAddress()
  return self.game.sonicPointerChar4Value + self.offset
end


local PointerBasedTailsChar1Value = subclass(valuetypes.MemoryValue)
function PointerBasedTailsChar1Value:getAddress()
  return self.game.tailsPointerChar1Value + self.offset
end

local PointerBasedTailsChar2Value = subclass(valuetypes.MemoryValue)
function PointerBasedTailsChar2Value:getAddress()
  return self.game.tailsPointerChar2Value + self.offset
end

local PointerBasedTailsChar3Value = subclass(valuetypes.MemoryValue)
function PointerBasedTailsChar3Value:getAddress()
  return self.game.tailsPointerChar3Value + self.offset
end

local PointerBasedTailsChar4Value = subclass(valuetypes.MemoryValue)
function PointerBasedTailsChar4Value:getAddress()
  return self.game.tailsPointerChar4Value + self.offset
end


local PointerBasedKnucklesChar1Value = subclass(valuetypes.MemoryValue)
function PointerBasedKnucklesChar1Value:getAddress()
  return self.game.knucklesPointerChar1Value + self.offset
end

local PointerBasedKnucklesChar2Value = subclass(valuetypes.MemoryValue)
function PointerBasedKnucklesChar2Value:getAddress()
  return self.game.knucklesPointerChar2Value + self.offset
end

local PointerBasedKnucklesChar3Value = subclass(valuetypes.MemoryValue)
function PointerBasedKnucklesChar3Value:getAddress()
  return self.game.knucklesPointerChar3Value + self.offset
end

local PointerBasedKnucklesChar4Value = subclass(valuetypes.MemoryValue)
function PointerBasedKnucklesChar4Value:getAddress()
  return self.game.knucklesPointerChar4Value + self.offset
end


-- Game addresses

GV.activeChar =
  MV("Active Character", 0x9D986A, StaticValue, ByteType)
GV.stageId =
  MV("Stage ID", 0x29C33E, StaticValue, ShortType)

GV.fSpeed = MV(
  "FSpeed", 0x60, PointerBasedChar4Value, FloatType)
GV.vSpeed = MV(
  "VSpeed", 0x64, PointerBasedChar4Value, FloatType)
GV.sdSpeed = MV(
  "SideSpeed", 0x68, PointerBasedChar4Value, FloatType)
  
GV.xPos = MV(
  "XPos", 0x18, PointerBasedChar2Value, FloatType)
GV.yPos = MV(
  "YPos", 0x1C, PointerBasedChar2Value, FloatType)
GV.zPos = MV(
  "ZPos", 0x20, PointerBasedChar2Value, FloatType)
  
GV.xSpd = MV(
  "XSpd", 0x0, PointerBasedChar3Value, FloatType)
GV.ySpd = MV(
  "YSpd", 0x4, PointerBasedChar3Value, FloatType)
GV.zSpd = MV(
  "ZSpd", 0x8, PointerBasedChar3Value, FloatType)

GV.xfSpd = MV(
  "XForcedSpd", 0xc, PointerBasedChar3Value, FloatType)
GV.yfSpd = MV(
  "YForcedSpd", 0x10, PointerBasedChar3Value, FloatType)
GV.zfSpd = MV(
  "ZForcedSpd", 0x14, PointerBasedChar3Value, FloatType)
  
GV.xRot = MV(
  "XRot", 0xE, PointerBasedChar2Value, ShortType)
GV.yRot = MV(
  "YRot", 0x12, PointerBasedChar2Value, ShortType)
GV.zRot = MV(
  "ZRot", 0x16, PointerBasedChar2Value, ShortType)

GV.xfRot = MV(
  "XFinalRot", 0x1A, PointerBasedChar3Value, ShortType)
GV.yfRot = MV(
  "YFinalRot", 0x1E, PointerBasedChar3Value, ShortType)
GV.zfRot = MV(
  "ZFinalRot", 0x22, PointerBasedChar3Value, ShortType)
  
GV.hover = MV(
  "HoverTimer", 0x12, PointerBasedChar4Value, ShortType)
GV.action = MV(
  "ActionNumber", 0x1, PointerBasedChar2Value, ByteType)
GV.status1 = MV(
  "StatusBitfield1", 0x6, PointerBasedChar2Value, BinaryType, {binarySize=8, binaryStartBit=7})
GV.status2 = MV(
  "StatusBitfield2", 0x7, PointerBasedChar2Value, BinaryType, {binarySize=8, binaryStartBit=7})  


GV.sonicFSpd = MV(
  "FSpeed", 0x60, PointerBasedSonicChar4Value, FloatType)
GV.sonicVSpd = MV(
  "VSpeed", 0x64, PointerBasedSonicChar4Value, FloatType)
GV.sonicYRot = MV(
  "YRot", 0x12, PointerBasedSonicChar2Value, ShortType)
GV.sonicXPos = MV(
  "XPos", 0x18, PointerBasedSonicChar2Value, FloatType)
GV.sonicYPos = MV(
  "YPos", 0x1C, PointerBasedSonicChar2Value, FloatType)
GV.sonicZPos = MV(
  "ZPos", 0x20, PointerBasedSonicChar2Value, FloatType)
GV.sonicAction = MV(
  "ActionNumber", 0x1, PointerBasedSonicChar2Value, ByteType)

GV.tailsFSpd = MV(
  "FSpeed", 0x60, PointerBasedTailsChar4Value, FloatType)
GV.tailsVSpd = MV(
  "VSpeed", 0x64, PointerBasedTailsChar4Value, FloatType)
GV.tailsYRot = MV(
  "YRot", 0x12, PointerBasedTailsChar2Value, ShortType)
GV.tailsXPos = MV(
  "XPos", 0x18, PointerBasedTailsChar2Value, FloatType)
GV.tailsYPos = MV(
  "YPos", 0x1C, PointerBasedTailsChar2Value, FloatType)
GV.tailsZPos = MV(
  "ZPos", 0x20, PointerBasedTailsChar2Value, FloatType)
GV.tailsAction = MV(
  "ActionNumber", 0x1, PointerBasedTailsChar2Value, ByteType)

GV.knucklesFSpd = MV(
  "FSpeed", 0x60, PointerBasedKnucklesChar4Value, FloatType)
GV.knucklesVSpd = MV(
  "VSpeed", 0x64, PointerBasedKnucklesChar4Value, FloatType)
GV.knucklesYRot = MV(
  "YRot", 0x12, PointerBasedKnucklesChar2Value, ShortType)
GV.knucklesXPos = MV(
  "XPos", 0x18, PointerBasedKnucklesChar2Value, FloatType)
GV.knucklesYPos = MV(
  "YPos", 0x1C, PointerBasedKnucklesChar2Value, FloatType)
GV.knucklesZPos = MV(
  "ZPos", 0x20, PointerBasedKnucklesChar2Value, FloatType)
GV.knucklesAction = MV(
  "ActionNumber", 0x1, PointerBasedKnucklesChar2Value, ByteType)
  
  
-- Inputs

GV.ABXYS = MV("ABXY & Start", 0x40EA50,
  StaticValue, BinaryType, {binarySize=8, binaryStartBit=7})
GV.DZ = MV("D-Pad & Z", 0x40EA51,
  StaticValue, BinaryType, {binarySize=8, binaryStartBit=7})
  
GV.stickX =
  MV("X Stick", 0x40EA52, StaticValue, ByteType)
GV.stickY =
  MV("Y Stick", 0x40EA53, StaticValue, ByteType)
GV.xCStick =
  MV("X C-Stick", 0x40EA54, StaticValue, ByteType)
GV.yCStick =
  MV("Y C-Stick", 0x40EA55, StaticValue, ByteType)
GV.lShoulder =
  MV("L Shoulder", 0x40EA56, StaticValue, ByteType)
GV.rShoulder =
  MV("R Shoulder", 0x40EA57, StaticValue, ByteType)

  
-- Time

GV.frameCounter = 
  MV("Frames Counter", 0x452C4C, StaticValue, IntType)
GV.centiseconds =
  MV("Centiseconds", 0x42C2FD, StaticValue, ByteType)
GV.seconds =
  MV("Seconds", 0x42C2FC, StaticValue, ByteType)
GV.minutes =
  MV("Minutes", 0x42C2FB, StaticValue, ByteType)
 
 
-- Screen display functions

function MyGame:displayFileTimer()
  local frameCount = self.frameCounter:get()

  local centi = math.floor((frameCount % 60) * 100 / 60)
  local sec = math.floor(frameCount / 60) % 60
  local min = math.floor(frameCount / 3600)

  return string.format("%02d:%02d.%02d", min, sec, centi)
end

function MyGame:displaySonicValues()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
    return {
      FSpd = '',
      VSpd = '',
      YRot = '',
      XPos = '',
      YPos = '',
      ZPos = '',
      Action = ''
    }
  end
  return {
    FSpd = string.format("%6.3f", self.sonicFSpd:get()),
    VSpd = string.format("%6.3f", self.sonicVSpd:get()),
    YRot = string.format("%5.1fd", self.sonicYRot:get() * 360 / 65536),
    XPos = string.format("%7.2f", self.sonicXPos:get()),
    YPos = string.format("%7.2f", self.sonicYPos:get()),
    ZPos = string.format("%7.2f", self.sonicZPos:get()),
    Action = string.format("%2d", self.sonicAction:get())
  }
end

function MyGame:displayTailsValues()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
    return {
      FSpd = '',
      VSpd = '',
      YRot = '',
      XPos = '',
      YPos = '',
      ZPos = '',
      Action = ''
    }
  end
  return {
    FSpd = string.format("%6.3f", self.tailsFSpd:get()),
    VSpd = string.format("%6.3f", self.tailsVSpd:get()),
    YRot = string.format("%5.1fd", self.tailsYRot:get() * 360 / 65536),
    XPos = string.format("%7.2f", self.tailsXPos:get()),
    YPos = string.format("%7.2f", self.tailsYPos:get()),
    ZPos = string.format("%7.2f", self.tailsZPos:get()),
    Action = string.format("%2d", self.tailsAction:get())
  }
end

function MyGame:displayKnucklesValues()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
    return {
      FSpd = '',
      VSpd = '',
      YRot = '',
      XPos = '',
      YPos = '',
      ZPos = '',
      Action = ''
    }
  end
  return {
    FSpd = string.format("%6.3f", self.knucklesFSpd:get()),
    VSpd = string.format("%6.3f", self.knucklesVSpd:get()),
    YRot = string.format("%5.1fd", self.knucklesYRot:get() * 360 / 65536),
    XPos = string.format("%7.2f", self.knucklesXPos:get()),
    YPos = string.format("%7.2f", self.knucklesYPos:get()),
    ZPos = string.format("%7.2f", self.knucklesZPos:get()),
    Action = string.format("%2d", self.knucklesAction:get())
  }
end

function MyGame:displayRTATime()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
    return ''
  end
  local stgId = self.stageId:get()
  return RTATimes[stgId]
  --return string.format("%4d", stgId)
end

function MyGame:displayKickCounter()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
    return ''
  end
  local action = self.sonicAction:get()
  if action ~= sonicPrevAction and action == 84 then
    sonicKickCount = sonicKickCount + 1
  end
  sonicPrevAction = action
  return string.format("%4d", sonicKickCount)
end

function MyGame:diveCounter()
  local action = self.knucklesAction:get()
  if action ~= knucklesPrevAction and action == 67 then
    knucklesDiveCount = knucklesDiveCount + 1
  end
  knucklesPrevAction = action
  return knucklesDiveCount
end

function MyGame:displaySpeed()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local stspd = self.stSpeed:get()
  local sdspd = self.sdSpeed:get()
  local fspd = self.fSpeed:get()
  local vspd = self.vSpeed:get()
  local xspd = self.xSpd:get()
  local yspd = self.ySpd:get()
  local zspd = self.zSpd:get()
  
  return string.format("Speed\n  Fwd: %9.4f\tX: %9.4f\n  Vtc: %9.4f\tY: %9.4f\n  Std: %9.4f\tZ: %9.4f\n  Sdw: %9.4f\n", fspd, xspd, vspd, yspd, stspd, zspd, sdspd)
end

function MyGame:displaySpeedSmall()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local sdspd = self.sdSpeed:get()
  local fspd = self.fSpeed:get()
  local vspd = self.vSpeed:get()
  local xspd = self.xSpd:get()
  local yspd = self.ySpd:get()
  local zspd = self.zSpd:get()
  
  return string.format("Speed\n  Fw:%8.3f   X: %8.3f\n  Vt:%8.3f   Y: %8.3f\n  Sd:%8.3f   Z: %8.3f\n", fspd, xspd, vspd, yspd, sdspd, zspd)
end

function MyGame:displayRotation()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local xrot = self.xRot:get()
  local yrot = self.yRot:get()
  local zrot = self.zRot:get()
  local xrotdeg = xrot * 360 / 65536
  local yrotdeg = yrot * 360 / 65536
  local zrotdeg = zrot * 360 / 65536
  
  local xfrot = self.xfRot:get()
  local yfrot = self.yfRot:get()
  local zfrot = self.zfRot:get()
  local xfrotdeg = xfrot * 360 / 65536
  local yfrotdeg = yfrot * 360 / 65536
  local zfrotdeg = zfrot * 360 / 65536
  
  return string.format("Rotation\n     Current          Final\n  X: %05d  %6.2f°   %05d  %6.2f°\n  Y: %05d  %6.2f°   %05d  %6.2f°\n  Z: %05d  %6.2f°   %05d  %6.2f°\n", xrot, xrotdeg, xfrot, xfrotdeg, yrot, yrotdeg, yfrot, yfrotdeg, zrot, zrotdeg, zfrot, zfrotdeg)
end

function MyGame:displayRotationSmall()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local xrot = self.xRot:get()
  local yrot = self.yRot:get()
  local zrot = self.zRot:get()
  local xrotdeg = xrot * 360 / 65536
  local yrotdeg = yrot * 360 / 65536
  local zrotdeg = zrot * 360 / 65536
  
  local xfrot = self.xfRot:get()
  local yfrot = self.yfRot:get()
  local zfrot = self.zfRot:get()
  local xfrotdeg = xfrot * 360 / 65536
  local yfrotdeg = yfrot * 360 / 65536
  local zfrotdeg = zfrot * 360 / 65536
  
  return string.format("Rotation\n      Current    Final\n  X:  %6.2f°    %6.2f°\n  Y:  %6.2f°    %6.2f°\n  Z:  %6.2f°    %6.2f°\n", xrotdeg, xfrotdeg, yrotdeg, yfrotdeg, zrotdeg, zfrotdeg)
end

function MyGame:displayPosition()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end

  local xpos = self.xPos:get()
  local ypos = self.yPos:get()
  local zpos = self.zPos:get()
  
  local xpush = self.xPush:get()
  local ypush = self.yPush:get()
  local zpush = self.zPush:get()
  
  return string.format("Position              External Push\n  X: %10.4f         X: %9.4f\n  Y: %10.4f         Y: %9.4f\n  Z: %10.4f         Z: %9.4f\n", xpos, xpush, ypos, ypush, zpos, zpush)
end

function MyGame:displayPositionSmall()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end

  local xpos = self.xPos:get()
  local ypos = self.yPos:get()
  local zpos = self.zPos:get()
    
  return string.format("Position\n  X: %8.2f\n  Y: %8.2f\n  Z: %8.2f\n", xpos, ypos, zpos)
end

function MyGame:displayTime()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format(" Waiting for stage selection ")
  end
  
  local frames = self.frameCounter:get()
  local centi = self.centiseconds:get()
  local sec = self.seconds:get()
  local minu = self.minutes:get()
  
  local chr = self.activeChar:get()
  local chr_array = {"Sonic", "Tails", "Knux"}
  
  return string.format(" %02d:%02d::%02d | %5d | %s\n", minu, sec, centi, frames, chr_array[chr+1])
end  

function MyGame:displayMisc()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local hvr = self.hover:get()
  local actn = self.action:get()
  return string.format("Misc\n  Hover:  %3d         Action: %3d\n", hvr, actn)
end

function MyGame:displayMiscSmall()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local hvr = self.hover:get()
  local actn = self.action:get()
  return string.format("Misc\n  Hover: %3d   Action: %3d\n", hvr, actn)
end

function MyGame:displayStatus()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local stts1 = self.status1:get()
  local stts2 = self.status2:get()
  local status_arr = {"Ball Form", "Light Dash", "B Enabled", "Holding Object", "Setting Variables", "Automated Section", "Disable Control", "Invincible", "On Ground", "On Ground (Object)", "Hurt", "Object Interact", "Object Ceiling", "On Object", "Unknown", "Unknown"}
  
  local s = ""
  for i = 0,7 do
    if stts1[i+1] == 1 then
	  if s == "" then
	    s = s .. status_arr[8-i]
	  else
	    s = s .. ", " .. status_arr[8-i]
	  end
	end
  end
  
  for i = 0,7 do
    if stts2[i+1] == 1 then
	  if s == "" then
	    s = s .. status_arr[16-i]
	  else
	    s = s .. ", " .. status_arr[16-i]
	  end
	end
  end
  
  return string.format("Status: %s\n", s)
end

function MyGame:displayPhysics()
  if utils.readIntBE(self.startAddress + 0x2AD090) == 0 then
	return string.format("")
  end
  
  local vspd = self.vSpeed:get()
  local xrot = self.xRot:get()
  local zrot = self.zRot:get()
  
  local keepgravity = self.kpGrSpd:get()
  local vdecel = self.vDecel:get()
  local grav = self.gravity:get()
  
  local tv = grav / vdecel
  local gravangle = math.acos(math.cos(math.rad(xrot * 360 / 65536)) * math.cos(math.rad(zrot * 360 / 65536)))
  local angledtv = tv * math.cos(gravangle)
  
  local reqfspd_attv = 0.0
  if math.abs(angledtv) < math.abs(keepgravity) then
    reqfspd_attv = math.sqrt( keepgravity * keepgravity - angledtv * angledtv )
  end
  
  local reqfspd_curr = 0.0
  if math.abs(vspd) < math.abs(keepgravity) then
    reqfspd_curr = math.sqrt( keepgravity * keepgravity - vspd * vspd )
  end
  
  return string.format("Physics\n  GravityAngle = %3.2f°\n  GlobalTermVel = %3.4f\n  AngledTermVel = %3.4f\n  ReqFspdGravity = %3.4f\n  ReqFspdTermVel = %3.4f\n", math.deg(gravangle), tv, angledtv, reqfspd_curr, reqfspd_attv)
end

function MyGame:displayCameraPosition()
  local xpos = self.camXPos:get()
  local ypos = self.camYPos:get()
  local zpos = self.camZPos:get()
  
  return string.format("Camera Position\n  X: %10.4f\n  Y: %10.4f\n  Z: %10.4f\n", xpos, ypos, zpos)
end

function MyGame:displayCameraRotation()
  local xrot = self.camXRot:get()
  local yrot = self.camYRot:get()
  local zrot = self.camZRot:get()
  local xrotdeg = xrot * 360 / 65536
  local yrotdeg = yrot * 360 / 65536
  local zrotdeg = zrot * 360 / 65536
  
  return string.format("Camera Rotation\n     Current\n  X: %05d  %6.2f°\n  Y: %05d  %6.2f°\n  Z: %05d  %6.2f°\n", xrot, xrotdeg, yrot, yrotdeg, zrot, zrotdeg)
end

function MyGame:displayAngleOptimization()
  local yrot_setpoint = self.yRot:get()
  local camyrot = self.camYRot:get()
  local angleOffset = (yrot_setpoint + camyrot - 49152) % 65536
  
  local i = 1
  
  while angleOffset > angles[i].angle
  do
	i = i + 1
  end
  
  return string.format("Angle Optimization\n  Desired Y Rotation: %05d\n  Optimal Stick Inputs:  X: %3d  Y: %3d\n", yrot_setpoint, angles[i].X, angles[i].Y)
end

function MyGame:displayAnalogPosition()
  local xstick = self.stickX:get()
  local ystick = self.stickY:get()
  return string.format(" %3d,%d", xstick, ystick)
end  
  
  
-- Input viewer functions
  
function MyGame:getButton(button)
  -- Return 1 if button is pressed, 0 otherwise.
  local value = nil
  if button == "A" then value = self.ABXYS:get()[8]
  elseif button == "B" then value = self.ABXYS:get()[7]
  elseif button == "X" then value = self.ABXYS:get()[6]
  elseif button == "Y" then value = self.ABXYS:get()[5]
  elseif button == "S" then value = self.ABXYS:get()[4]
  elseif button == "Z" then value = self.DZ:get()[4]
  elseif button == "↑" then value = self.DZ:get()[5]
  elseif button == "↓" then value = self.DZ:get()[6]
  elseif button == "←" then value = self.DZ:get()[8]
  elseif button == "→" then value = self.DZ:get()[7]
  elseif button == "L" then value = self.DZ:get()[2]
  elseif button == "R" then value = self.DZ:get()[3]
  else error("Button code not recognized: " .. tostring(button))
  end

  return value
end

function MyGame:buttonDisplay(button)
  -- Return the button character ("A", "B" etc.) if the button is pressed,
  -- or a space character " " otherwise.
  local value = self:getButton(button)
  if value == 1 then
    return button
  else
    return " "
  end
end

function MyGame:displayAllButtons()
  local s = ""
  for _, button in pairs{"A", "B", "X", "Y", "S", "Z", "L", "R", "↓", "←", "→", "↑"} do
    s = s..self:buttonDisplay(button)
  end
  return s
end
  
  
MyGame.ControllerStickImage = subclass(layoutsModule.StickInputImage)
function MyGame.ControllerStickImage:init(window, game, options)
  options = options or {}
  options.max = options.max or 255
  options.min = options.min or 0
  options.square = options.square or false
  
  layoutsModule.StickInputImage.init(
    self, window,
    game.stickX, game.stickY, options)
end

MyGame.ControllerLRImage = subclass(layoutsModule.AnalogTriggerInputImage)
function MyGame.ControllerLRImage:init(window, game, options)
  options = options or {}
  options.max = options.max or 255

  layoutsModule.AnalogTriggerInputImage.init(
    self, window, game.lShoulder, game.rShoulder, options)
end

return MyGame