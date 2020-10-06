-- droneThing

engine.name = "ResDrone"

--[[ setup ]]--

local enc1acc
local curOsc = 1
local curPanel = 1
local panels

function init()
  curOsc = 1
  
  enc1acc = {
    value=0,
    time=0
  }
  
  resP = paramset.new()
  
  resP:add{
    type="number",
    id="freq",
    min=20,
    max=220,
    default=50,
    action=function(f)  engine.hz(f) end
  }
  
  resP:add(makeResParam("res1",4.5, function(f) engine.res1(f) end))
  resP:add(makeResParam("res2",2.3, function(f) engine.res2(f) end))
  resP:add(makeResParam("res3",1.9, function(f) engine.res3(f) end))
  resP:add(makeResParam("res4",1.5, function(f) engine.res4(f) end))
  
  resP:add(makeNoiseParam("ns1",0.05, function(f) engine.ns1(f) end))
  resP:add(makeNoiseParam("ns2",0.06, function(f) engine.ns2(f) end))
  resP:add(makeNoiseParam("ns3",0.056, function(f) engine.ns3(f) end))
  resP:add(makeNoiseParam("ns4",0.07, function(f) engine.ns4(f) end))

  resP:add(makeParam("detune",0,1, 0, function(f) engine.spread(f) end))

  resP:add(makeParam("revMix",0,1,0.33, function(f) engine.revMix(f) end))
  resP:add(makeParam("revRoom",0,0.5,0.1, function(f) engine.revRoom(f) end))
  resP:add(makeParam("revDamp",0,1,0.5, function(f) engine.revDamp(f) end))

  resP:add(makeParam("delSec",0,10,0.2, function(f) engine.delSec(f)  end))

  makePanels()

  screen.aa(1)
end

function makeParam(_name, _min, _max, _default, _action)
  return{
    type="number",
    id=_name,
    min=_min,
    max=_max,
    default=_default,
    action= _action
  }
end

function makeResParam(_name, _default, _action)
  return makeParam(_name, 1.1, 10, _default, _action)
end

function makeNoiseParam(_name, _default, _action)
  return makeParam(_name, 0.01, 0.1, _default, _action)
end

function makePanels()
  panels = {}
  panels[1] = makePanel(1,1,32,63)
  panels[2] = makePanel(33,1,63,63)
  panels[3] = makePanel(97,1,31,31)
  panels[4] = makePanel(97,32,31,31)
end

--[[ encoders ]]--
function enc(n,d)
  if n==1 then
    local now = util.time()
    if now-enc1acc.time<1 then
      enc1acc.value = enc1acc.value + d
    else
      enc1acc.value = d
    end
    enc1acc.time = now
    if math.abs(enc1acc.value)>=5 then
      if enc1acc.value>0 then
        nextPanel()
      else
        prevPanel()
      end
      enc1acc.value = 0
    end
  elseif n == 2 then
    if curPanel == 1 then
      resP:delta("freq",d)
    elseif curPanel == 2 then
      adjustCurRes(d)
    elseif curPanel== 3 then
      resP:delta("revMix",d/10)
    elseif curPanel==4 then
      resP:delta("delSec",d/10)
    end
  elseif n ==3 then
    if curPanel == 1 then
      resP:delta("detune", d/50)
    elseif curPanel == 2 then
    elseif curPanel == 3 then
      resP:delta("revRoom",d/10)
    end
  end
  redraw()
end

function adjustParam(_name, _inc)
  resP:delta(_name, _inc)
end

function adjustRes(_name, d)
  adjustParam(_name, d/10)
end

function adjustNoise(_name, d)
  adjustParam(_name, d/100)
end

function adjustCurRes(d)
  adjustRes("res"..curOsc, d)
end

function adjustCurNoise(d)
  adjustNoise("ns"..curOsc, d)
end

--[[ keys ]]--

function key(n,z)
  if n == 2 then
    if z==1 then
      if curPanel==2 then
        prevOsc()
      end
    end
  elseif n==3 then
    if z==1 then
      if curPanel == 2 then
        nextOsc()
      end
    end
  end
  redraw()
end

function incrementIdx(_cur, _inc, _max)
  local newVal = _cur + _inc
  if newVal > _max then
    return 1
  elseif newVal < 1 then
    return _max
  else
    return newVal
  end
end

function nextIdx(_cur, _max)
  return incrementIdx(_cur, 1, _max)
end

function prevIdx(_cur, _max)
  return incrementIdx(_cur, -1, _max)
end

function nextOsc()
  curOsc = nextIdx(curOsc, 4)
end

function prevOsc()
  curOsc = prevIdx(curOsc, 4)
end

function nextPanel()
  curPanel = nextIdx(curPanel, 4)
end

function prevPanel()
  curPanel = prevIdx(curPanel, 4)
end

--[[ GUI ]]--

function redraw()
  screen.clear()
  
  drawPanel(panels[curPanel])
  
  drawPot(17, 16, 10, "hz", "freq")
  drawPot(17, 42, 10, "tune", "detune")
  
  local sliDist = 64/5
  local sliX = 33+sliDist
  screen.move(sliX+sliDist*1.5, 7)
  screen.text_center("resonators")
  for i=1,4 do
    drawSlider(sliX, 10, 50, "res"..i)
    if i==curOsc then
      screen.move(sliX-2, 55)
      screen.line(sliX-2, 55)
      screen.line(sliX+2, 55)
      screen.level(15)
      screen.line_width(1)
      screen.stroke()
    end
    sliX = sliX + sliDist
  end
  
  drawReverb(112,16, 20)
  
  drawPot(112, 48, 10, "sec", "delSec")
  
  screen.update()
end

function getParamPct(_paramName)
  local cur = resP:get(_paramName)
  local minMax = resP:get_range(_paramName)
  return (cur-minMax[1])/(minMax[2]-minMax[1])
end

function drawPot(_x, _y, _r, _label, _paramName)
  local pct = getParamPct(_paramName)
  
  local rx = _x+_r
  screen.move(rx,_y)
  screen.line_width(1)
  screen.circle(_x,_y,_r)
  screen.level(3)
  screen.stroke()
  
  screen.move(rx,_y)
  screen.line_width(2)
  screen.arc(_x,_y,_r, 0, math.pi*pct*2)
  screen.level(15)
  screen.stroke()
  
  screen.move(_x,_y)
  screen.text_center(_label)
end

function drawSlider(_x, _minY, _maxY, _paramName)
  local pct = getParamPct(_paramName)
  local lL = _maxY-_minY
  local curL = lL*pct
  local curY = _maxY-curL
  
  screen.move(_x, _minY)
  screen.line_width(1)
  screen.line(_x,_minY)
  screen.line(_x,_maxY)
  screen.level(3)
  screen.stroke()
  
  screen.move(_x, curY)
  screen.line_width(2)
  screen.line(_x,curY)
  screen.line(_x,_maxY)
  screen.level(15)
  screen.stroke()
end

function makePanel(_x, _y, _w, _h)
  return {
    x=_x,
    y=_y,
    w=_w,
    h=_h
  }
end

function drawReverb(_x, _y, _sz)
  local curBgt = math.ceil(resP:get("revMix")*10)
  local curSz = _sz*resP:get("revRoom")*2
  local s2 = curSz/2
  local x = _x - s2
  local y = _y - s2
  screen.move(x,y)
  screen.rect(x,y,curSz,curSz)
  screen.level(curBgt)
  screen.fill()
  
  screen.move(_x,_y)
  screen.level(15)
  screen.text_center("reverb")
  screen.stroke()
end

function drawPanel(_panel)
  screen.move(_panel.x, _panel.y)
  screen.level(15)
  screen.line_width(1)
  screen.rect(_panel.x, _panel.y, _panel.w, _panel.h)
  screen.stroke()
end