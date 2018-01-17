
-- pentominoes1.lua

luatexbase.provides_module({
  name        = 'pentominoes',
  date        = '2018/01/10',
  version     = 0.1,
  description = '3x20 Pentominoes',
  author      = 'Soojin Nam',
  license     = 'public domain',
})

pentominoes = pentominoes or {}
local pentominoes = pentominoes


local dlx1 = require "dlx1"

local ipairs = ipairs
local sprint = tex.sprint
local tonumber = tonumber
local str_sub = string.sub


local function draw (side, nr, nc, num)
   local fname = nr.."x"..nc..".dlx"
   local lines = {}
   for line in io.lines(fname) do
      lines[#lines+1] = line
   end
   
   local dlx, err = dlx1:new(lines)
   if not dlx then
      sprint("setup error:", err)
      return
   end
   
   local box = {}
   for i=0,nr do box[i] = {} end

   local cnt=0
   for sol in dlx:dance() do
      cnt = cnt+1
      if cnt > num then break end
      for _, opt in ipairs(sol) do
         local c = opt[1]
         for j=2,#opt do
            local x = tonumber(str_sub(opt[j],1,1), 36)
            local y = tonumber(str_sub(opt[j],2,2), 36)
            box[x][y] = c
         end
      end


      local nr, nc = nr-1, nc-1
      sprint("\\begin{Pentominoes}["..side.."]\n")
      for j=0,nr do
         sprint("\\Row{")
         for k=0,nc-1 do
            sprint(box[j][k] or "B", ",")
         end
         sprint(box[j][nc] or "B", "}\n")
      end
      sprint("\\end{Pentominoes}\n")
   end
end


pentominoes.draw = draw

