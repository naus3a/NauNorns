include('lib/AmpTool')

local pollAmp
local aL = 0
local aR = 0
local ampSmpFreq = 1/30

local ampTool

local re

function init()
  ampTool = AmpTool:new(nil)
  
  pollAmp = {}
  
  pollAmp[1] = poll.set("amp_in_l")
  pollAmp[2] = poll.set("amp_in_r")
  
  pollAmp[1].callback = onNewAmpL
  pollAmp[2].callback = onNewAmpR
  
  for i=1,2,1 do
    pollAmp[i].time = ampSmpFreq
    pollAmp[i]:start()
  end

  screen.aa(1)
  re = metro.init()
  re.time = 1.0 / 15
  re.event = function()
    redraw()
  end
  re:start()
  
  
end

function onNewAmpL(val)
  aL = val
end

function onNewAmpR(val)
  aR = val
  --print("in: l:"..string.format("%.2f", aL).."/r: "..string.format("%.2f", aR))
  ampTool:addNewSamples(aL, aR)
end

function redraw()
  screen.clear()
  ampTool:draw()
  screen.update()
end

function cleanup()
  for i=1,2,1 do
    pollAmp[i].time = ampSmpFreq
    pollAmp[i]:stop()
  end
  re:stop()
end