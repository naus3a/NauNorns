engine.name = 'R'

local R = require 'r/lib/r'
local Formatters = require 'formatters'

function init()
  --spawn modules
  engine.new("SoundIn", "SoundIn")
  engine.new("FilterInL", "LPLadder")
  engine.new("FilterInR", "LPLadder")
  engine.new("EnvFilter", "MMFiltet")
  
  engine.new("Carrier", "Noise")
  engine.new("SoundOut", "SoundOut")
  
  --patch
  engine.connect("SoundIn/Left", "FilterInL*In")
  engine.connect("SoundIn/Right", "FilterInR*In")
  engine.connect("FilterInL/Out", "EnvFilter*In")
  engine.connect("FilterInR/Out", "EnvFilter*In")
  
  engine.connect("Carrier/Out", "SoundOut*Left")
  engine.connect("Carrier/Out", "SoundOut*Right")

  --set values
  engine.set("FilterInL.Frequency", 20000)
  engine.set("FilterInR.Frequency", 20000)
  engine.set("FilterInL.Resonance", 0)
  engine.set("FilterInR.Resonance", 0)
  engine.set("FilterInL.FM", 1)
  engine.set("FilterInR.FM", 1)
  
  engine.set("EnvFilter.Frequency", 5000)
  engine.set("EnvFilter.FM", 1)
end