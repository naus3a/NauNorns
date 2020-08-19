-- noiseThing

include("lib/noise")

function init()
  noise1d = {}
  for i=1,128,1 do
    noise1d[i] = 0
  end
  
  curN = 0
  nCnt = 1
  nSpeed = 0.1
  
  idx1d = 1
  
  tm = metro.init()
  tm.time = 1.0/10
  tm.event = updateTimer
  
  tm:start()
  
end

function updateTimer()
  curN = Noise:noise(nCnt)
  nCnt = nCnt + nSpeed
  
  noise1d[idx1d] = curN
  idx1d = idx1d+1
  if idx1d>128 then
    idx1d = 1
  end
  
  redraw()
end

function redraw()
  screen.clear()
  drawNoise1D()
  screen.update()
end

function drawNoise1D()
  for i=1, 128,1 do
    screen.pixel(i,32+(noise1d[i]*16))
  end
  screen.level(15)
  screen.fill()
end

function enc(n,d)
  if n==2 then
    nSpeed = nSpeed + (d/100)
    if nSpeed < 0.001 then
      nSpeed = 0.001
    elseif nSpeed >1 then
      nSpeed = 1
    end
  end
end