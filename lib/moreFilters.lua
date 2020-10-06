local Filters = require 'filters'

----------------------
--- @type Filters.rms
-- moving, windowed RMS/standard deviation filter

local rms = {}
rms.__index = rms
setmetatable(rms, { __index=Filters })

-- copying this is ugly; should figure out something different
-- helper to increment and wrap an index
local function wrap_inc(x, max)
   local y = x + 1
   while y > max do y = y - max end
   return y
end

----------------------
--- @type constructor
--- @param bufsize: window size, cannot change after creation

function rms.new(bufsize)
  local new = setmetatable({}, rms)
  
  new.buf = {}
  if bufsize==nil then bufsize=16 end
  new.bufsize = bufsize
  new.scale = 1/bufsize
  new:clear()
  
  new.pos = 1
  new.sum = 0
  new.value = 0
  
  print('done allocating new rms filter')
  return new
end

--- process a new input value and update rms
-- @param x: new input
-- @param m: mean value
-- @return rms
function rms:next(x, m)
  local smp = (x-m)
  smp = smp*smp
  local a = smp*self.scale
  
  --calc mean of squares; maybe should just extend means
  self.sum = self.sum + a
  self.sum = self.sum - self.buf[self.pos]
  self.buf[self.pos] = a
  self.pos = wrap_inc(self.pos, self.bufsize)
  
  self.value = math.sqrt(self.sum)
  return self.value
end

----------------------
--- return stuff

Filters.rms = rms

return Filters