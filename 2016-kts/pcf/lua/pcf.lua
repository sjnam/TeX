local tonumber = tonumber
local concat = table.concat
local format = string.format
local sqrt, floor = math.sqrt, math.floor

local n = tonumber(arg[1])
if not n then
   print("usage: lua "..arg[0].." N")
   return
end

local ptab = {}
local a0 = floor(sqrt(n))
local m, d = a0, n-a0*a0

if d == 0 then
   print(format("\\sqrt{%d} = %d", n, a0))
   return
end

local m0, d0 = m, d
repeat
   local a = floor((a0+m)/d)
   ptab[#ptab+1] = a
   m = d*a - m
   d = (n-m*m)/d
until m==m0 and d==d0

print(format("\\sqrt{%d} = [%d;\\overline{%s}]", n, a0, concat(ptab,',')))
