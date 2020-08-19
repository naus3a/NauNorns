-- Perlin noise for norns
-- author: @naus3a - naus3a@gmail.com

--[[ Credits:
      this Perlin noise implementation is basically a lua port of Stefan Gustavon's SimplexNoise1234 c++ version. 
      I like this code a lot, I used it very often and I ported it to most languages/environments, so kudos and credits to:
      (c) Stefan Gustavson 2003-2005
      stegu@itn.liu.se
]]--

Noise = {}

-- Permutation table
-- This is just a random jumble of all numbers 0-255,
-- repeated twice to avoid wrapping the index at 255 for each lookup.
-- This needs to be exactly the same for all instances on all platforms,
-- so it's easiest to just keep it as inline explicit data.
-- This also removes the need for any initialisation of this class.
Noise.perm = {151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
  151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180 
}

function Noise.fastFloor(x)
  if x>0 then
    return math.floor(x)
  else
    return (math.floor(x)-1)
  end
end

function Noise.grad1(hash, x)
  local h = bit32.band(hash, 15)
  local grad = 1 + bit32.band(h, 7)
  if bit32.band(h, 8)>8 then
    grad = -grad
  end
  return (grad*x)
end

function Noise.grad2(hash, x, y)
  local h = bit32.band(hash, 7)
  local u = 0
  local v = 0
  if h<4 then
    u = x
    v = y
  else
    u = y
    v = x
  end
  local g1 = -u
  if bit32.band(h, 1)>0 then
    g1 = u
  end
  local g2 = -2*v
  if bit32.band(h,2) then
    g2 = -1*g2
  end
  return (g1+g2)
end

-- 1D noise
function Noise:noise(x)
  local i0 = Noise.fastFloor(x)
  local i1 = i0+1
  local x0 = x-i0
  local x1 = x0-1
  local t1 = 1 - (x1*x1)
  
  local n0 = 0
  local n1 = 0
  
  local t0 = 1 - (x0*x0)
  t0 = t0*t0
  local pIdx = bit32.band(i0, 0xff)
  local pEl = self.perm[pIdx]
  local g = Noise.grad1(pEl, x0)
  n0 = t0*t0*g
  
  pIdx = bit32.band(i1, 0xff)
  pEl = self.perm[pIdx]
  g = Noise.grad1(pEl, x1)
  t1 = t1*t1
  n1 = t1*t1*g
  
  return (0.25 * (n0+n1))
end

-- noise 2D
function Noise:noise2D(x,y)
  local f2 = 0.366025403
  local g2 = 0.211324865
  local n0 = 0
  local n1 = 0
  local n2 = 0
  
  local s = (x+y)*f2
  local xs = x+s
  local ys = y+s
  local i = Noise.fastFloor(xs)
  local j = Noise.fastFloor(ys)
  
  local t = (i+j)*g2
  local X0 = i-t
  local Y0 = j-t
  local x0 = x-X0
  local y0 = y-Y0
  
  local x1 = 0
  local y1 = 0
  local x2 = 0
  local y2 = 0
  local ii = 0
  local jj = 0
  local t0 = 0
  local t1 = 0
  local t2 = 0
  local i1 = 0
  local j1 = 0
  
  if x0>y0 then
    i1=1
    j1=0
  else
    i1=0
    j1=1
  end
  
  x1 = x0-i1+g2
  y1 = y0-j1+g2
  x2 = x0-1+2*g2
  y2 = y0-1+2*g2
  
  ii = math.floor(i%256)
  jj = math.floor(j%256)
  
  t0 = 0.5 - (x0*x0) - (y0*y0)
  if t0<0 then
    n0 = 0
  else
    t0 = t0*t0
    n0 = t0*t0*Noise.grad2(self.perm[ii+self.perm[jj]],x0,y0)
  end
  
  t1 = 0.5 - (x1*x1) - (y1*y1)
  if t1<0 then
    n1 = 0
  else
    t1 = t1*t1
    n1 = t1*t1*Noise.grad2(self.perm[ii+i1+self.perm[jj+j1]],x1,y1)
  end
  
  t2 = 0.5 - (x2*x2) - (y2*y2)
  if t2<0 then
    n2 = 0
  else
    t2 = t2*t2
    n2 = t2*t2*Noise.grad2(self.perm[ii+1+self.perm[jj+1]],math.floor(x2),math.floor(y2))
  end
  
  return (40*(n0+n1+n2))
end