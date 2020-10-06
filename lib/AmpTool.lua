--local Filters = require 'filters'
local NauFilters = include 'lib/moreFilters'

AmpTool = {
  amp = 0,
  ampL = 0,
  ampR = 0,
  meanFilter = nil,
  rmsFilter = nil,
  mean = 0,
  winSz = 20
}


function AmpTool:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.amp = amp or 0
  self.ampL = amp or 0
  self.ampR = amp or 0
  self.winSz = winSz or 20
  self.mean = 0
  self.meanFilter = NauFilters.mean.new(self.winSz)
  self.rmsFilter = NauFilters.rms.new(winSz)
  return o
end

function AmpTool:addNewSamples(l, r)
  self.ampL = l
  self.ampR = r
  self.amp = (self.ampL+self.ampR)/2.0
  self.mean = self.meanFilter:next(self.amp)
  self.rms = self.rmsFilter:next(self.amp, self.mean)
end

function amp2screenY(a)
  local mul = 10
  return (1.0-(a*mul))*64
end

function AmpTool:draw()
  local mul = 10
  local yL = amp2screenY(self.ampL)
  local yR = amp2screenY(self.ampR)
  local yA = amp2screenY(self.amp)
  local yM = amp2screenY(self.mean)
  local yRms = amp2screenY(self.rms)
  local hL = 64 - yL
  local hR = 64 - yR
  
  -- input l/r bars
  screen.level(3)
  screen.move(0, yL)
  screen.rect(0, yL,5,hL)
  screen.move(0, yR)
  screen.rect(5, yR,5,hR)
  screen.fill()
  screen.level(15)
  screen.move(0, 0)
  screen.rect(0,0,5,64)
  screen.move(5,0)
  screen.rect(5,0,5,64)
  screen.stroke()
  
  -- mean input level
  screen.level(3)
  screen.move(10, yM)
  screen.line(25, yM)
  screen.stroke()
  
  screen.level(3)
  screen.move(10, yRms)
  screen.line(30, yRms)
  screen.stroke()
  
  -- instant input level
  screen.level(15)
  screen.move(10, yA)
  screen.line(20, yA)
  screen.stroke()
  --print("in: l:"..string.format("%.2f", self.ampL).."/r: "..string.format("%.2f", self.ampR))
  --print("m: "..string.format("%.2f", self.rms))
end

