local alphametics = require "alphametics"
local ipairs = ipairs
local insert = table.insert
local concat = table.concat
local print = tex.sprint


local LEFT, RIGHT = 1, 2


local function split (str, pat)
   local t = {}
   local fpat = "(.-)"..pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      insert(t, cap)
   end
   return t
end


local function print_puzzle (vh, lhs, rhs, tt)
   local tt = tt or ""
   local loprd, roprd = {}, {}
   for _, v in ipairs(lhs) do
      insert(loprd, tt.."{"..v.."}" )
   end
   for _, v in ipairs(rhs) do
      insert(roprd, tt.."{"..v.."}" )
   end

   if vh == "v" then
      print("\\begin{array}{c@{\\,}r}")
      for i=1,#loprd do
         if i == #loprd then print("+") end
         print("&"..loprd[i].."\\\\")
      end
      print("\\cmidrule(lr){1-2}")
      for i=1,#roprd do
         print("&"..roprd[i].."\\\\")
      end
      print("\\end{array}\\quad") 
   else
      print(concat(loprd,"+").."&="..concat(roprd,"+").."\\\\")
   end
end


function puzzle (vh, line)
   local line = line
   if not line then return end
   line = line:gsub("^%s*(.-)%s*$", "%1") -- trim a line
   
   local eqn = split(line, "%s*=%s*")
   local lhs = split(eqn[LEFT], "%s*+%s*") -- left hand side array
   local rhs = split(eqn[RIGHT], "%s*+%s*") -- right hand side array

   if vh == "v" then print("$$") else print("\\begin{align*}") end   
   print_puzzle(vh, lhs, rhs, "\\texttt") -- typewriter font for question
   local alpha = alphametics.new(lhs, rhs)
   local answers = alpha:solutions()
   if answers then
      for _, ans in ipairs(answers) do
         print_puzzle(vh, ans[1], ans[2])
      end
   end
   if vh == "v" then print("$$") else print("\\end{align*}") end   
   alpha:clear()
end

