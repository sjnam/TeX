local alphametics = require "alphametics"

local ipairs = ipairs
local write = io.write
local concat = table.concat

local function print_puzzle (lhs, rhs)
   write(concat(lhs, " + "))
   write(" = ")
   write(concat(rhs, " + ").."\n")
end

local function puzzle (lhs, rhs)
   print_puzzle(lhs, rhs)
   local alpha = alphametics.new(lhs, rhs)
   local answers = alpha:solutions()
   if answers then
      for _, ans in ipairs(answers) do
         print_puzzle(ans[1], ans[2])
      end
   end
   alpha:clear()
   write("\n") 
end

-- samples
puzzle({ "SEND", "MORE" }, { "MONEY" })
puzzle({"COFFEE", "COFFEE", "COFFEE"},{"THEOREM"})
puzzle({ "VIOLIN", "VIOLIN", "VIOLA"}, { "TRIO", "SONATA" })
puzzle({"ZEROES","ONES"},{"BINARY"})
puzzle({"EARTH","AIR","FIRE","WATER"},{"NATURE"})
puzzle({ "SEND","A","TAD", "MORE" }, { "MONEY" })
puzzle({"FISH","N","CHIPS"},{"SUPPER"})
puzzle({ "SATURN", "URANUS", "NEPTUNE", "PLUTO" }, { "PLANETS" })
puzzle({ "INTO", "ONTO", "CANON", "INTACT", "AMMONIA", "OMISSION", "DIACRITIC",
         "STATISTICS", "ASSOCIATION", "ANTIMACASSAR", "CONTORTIONIST",
         "NONDISCRIMINATION", "CONTRADISTINCTION" },
   { "MISADMINISTRATION" })

