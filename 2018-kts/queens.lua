
-- n Queens by DLX

luatexbase.provides_module({
  name        = 'queens',
  date        = '2018/01/10',
  version     = 0.1,
  description = 'N-Queens by DLX',
  author      = 'Soojin Nam',
  license     = 'public domain',
})

queens = queens or {}
local queens = queens


local dlx1 = require "dlx1"

local write = tex.sprint
local tonumber = tonumber
local floor = math.floor
local byte = string.byte
local str_sub = string.sub
local format = string.format
local tconcat = table.concat


local byte0, bytea = byte("0"), byte("a")
local function encode (x)
   if x < 10 then
      return byte0+x
   end
   return bytea-10+x
end


local function chessboard (n, num)
   local num = num or 2
   local lines = {}
   local nn = n+n-2

   -- Output the column names
   local items = {}
   for j=0,n-1 do
      local t
      if j%2 == 1 then
         t = n-1-j
      else
         t = n+j
      end
      t = encode(floor(t/2))
      items[#items+1] = format("r%c c%c ", t, t)
   end
   items[#items+1] = "|"
   for j=1,nn-1 do
      local t = encode(j)
      items[#items+1] = format(" a%c b%c", t, t)
   end
   lines[#lines+1] = tconcat(items)

   -- Output the possible queen moves
   for j=0,n-1 do
      for k=0,n-1 do
         local opt = {}
         opt[#opt+1] = format("r%c c%c", encode(j), encode(k))
         t = j + k
         if t ~= 0 and t < nn then
            opt[#opt+1] = format(" a%c", encode(t))
         end
         t = n-1-j+k
         if t ~= 0 and t < nn then
            opt[#opt+1] = format(" b%c", encode(t))
         end
         lines[#lines+1] = tconcat(opt)
      end
   end

   -- dance
   local dlx, err = dlx1:new(lines)
   if not dlx then
      write("setup error:"..err.."\n")
      return
   end

   write(format("\\storechessboardstyle{%dx%d}{maxfield=%c%d}\n",
                n, n, bytea+n-1, n))

   local i = 0
   for sol in dlx:dance() do
      i = i + 1
      if i > num then break end
      if i % 2 == 1 then write("\\begin{center}") end
      write(format("\\chessboard[smallboard,style=%dx%d,setwhite={", n, n))
      local opt
      for i=1,#sol-1 do
         opt = sol[i]
         write(format("Q%c%d,",
                      bytea+tonumber(str_sub(opt[1],2)),
                      tonumber(str_sub(opt[2],2))+1))
      end
      opt = sol[#sol]
      write(format("Q%c%d",
                   bytea+tonumber(str_sub(opt[1],2)),
                   tonumber(str_sub(opt[2],2))+1))
      write("},showmover=false]\\hfil")
      if i % 2 == 0 then write("\\end{center}") end
   end
end


queens.chessboard = chessboard
