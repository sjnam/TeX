
--[[
   dlx1.lua

   Algorithm 7.2.2.1D (Exact cover via dancing links)

   This code is based on the Algorithm D described in
   http://www-cs-faculty.stanford.edu/~knuth/fasc5c.ps.gz
--]]


local type = type
local print = print
local ipairs = ipairs
local huge = math.huge
local fread = io.read
local write = io.write
local str_rep = string.rep
local str_match = string.match
local tremove = table.remove
local co_wrap = coroutine.wrap
local co_yield = coroutine.yield
local setmetatable = setmetatable


local _M = {
   _VERSION = "0.2.3",
   debug = false,
}


local mt = { __index = _M }


local function split (line, pat)
   local pat = pat or "%s"
   local elems = {}
   line:gsub("([^"..pat.."]+)", function(c) elems[#elems+1] = c end)
   return elems
end


local function node (dlx, o)
   local o = o or {}
   setmetatable(o, dlx)
   dlx.__index = dlx
   return o
end


local function read_items (dlx, line)
   -- Read the first line.
   local nodes = dlx.nodes
   nodes[0] = node(dlx, { id = 0, })
   local N, N1 = 0, 0
   local elems = split(line)
   for _, v in ipairs(elems) do
      if v == "|" then
         N1 = N
      else
         N = N + 1
         nodes[N] = node(dlx, { id = N, name = v, llink = N-1, })
         nodes[N-1].rlink = N
      end
   end

   -- Finish the horizontal list.
   if N1 == 0 then N1 = N end
   nodes[N+1] = node(dlx, { id = N+1, llink = N, rlink = N1+1, })
   nodes[N].rlink = N+1
   nodes[N1+1].llink = N+1
   nodes[0].llink = N1
   nodes[N1].rlink = 0

   dlx.N, dlx.N1 = N, N1
end


local function read_options (dlx, line)
   -- Read an option.
   local option = split(line)
   local nodes, names = dlx.nodes, dlx.names
   local k = #option
   for j=1,k do
      local p = names[option[j]]
      p.len = p.len + 1
      local q = p.ulink
      local nd = {
         id = dlx.p+j,
         ulink = q,
         dlink = p.id,
         top = p.id,
         name = p.name,
      }
      nodes[q].dlink = nd.id
      p.ulink = nd.id
      nodes[#nodes+1] = node(dlx, nd)
   end

   -- Finish an option.
   dlx.M = dlx.M + 1
   nodes[dlx.p].dlink = dlx.p + k
   dlx.p = dlx.p + k + 1
   nodes[dlx.p] = node(dlx, { id = dlx.p, top = -dlx.M, ulink = dlx.p-k, })
end


local function read_line (lines)
   if lines then
      return tremove(lines, 1)
   end
   return fread()
end


local function setup (dlx, lines)
   local line = read_line(lines)
   while not line or str_match(line, "^%s*|") do
      line = read_line(lines)
   end
   read_items(dlx, line)

   --Prepare for options.
   for j=1,dlx.N do
      local nd = dlx.nodes[j]
      nd.len = 0
      nd.ulink = j
      nd.dlink = j
      dlx.names[nd.name] = nd
   end

   dlx.M, dlx.p = 0, dlx.N+1
   local n1 = dlx.nodes[dlx.p]
   n1.id = dlx.p
   n1.top = 0

   while true do
      line = read_line(lines)
      if not line then break end
      if not str_match(line, "^%s*|") then
         read_options(dlx, line)
      end
   end
   dlx.Z = #dlx.nodes

   if dlx.debug then dlx:memory_contents() end

   return dlx
end


function _M:new (lines)
   if lines and type(lines) == "string" then
      lines = split(lines, "\n")
   end
   local dlx = {
      names = {},
      nodes = {},
   }
   return setup(setmetatable(dlx, mt), lines)
end


local function top (p)
   return p.nodes[p.top]
end


local function llink (i)
   return i.nodes[i.llink]
end


local function rlink (i)
   return i.nodes[i.rlink]
end


local function ulink (p)
   return p.nodes[p.ulink]
end


local function dlink (p)
   return p.nodes[p.dlink]
end


local function prev (p)
   return p.nodes[p.id-1]
end


local function next (p)
   return p.nodes[p.id+1]
end


local function mrv_heuristic (items)
   local i
   local root = items[0]
   local theta = huge
   local p = rlink(root)
   while p ~= root do
      local lambda = p.len
      if lambda < theta then
         theta = lambda
         i = p
      end
      if theta == 0 then break end
      p = rlink(p)
   end
   return i
end


local function hide (p)
   local q = next(p)
   while q ~= p do
      local x, u, d = top(q), ulink(q), dlink(q)
      if q.top <= 0 then
         q = u
      else
         u.dlink, d.ulink = d.id, u.id
         x.len = x.len - 1
         q = next(q)
      end
   end
end


local function cover (i)
   local p = dlink(i)
   while p ~= i do
      hide(p)
      p = dlink(p)
   end
   local l, r = llink(i), rlink(i)
   l.rlink, r.llink = r.id, l.id
end


local function unhide (p)
   local q = prev(p)
   while q ~= p do
      local x, u, d = top(q), ulink(q), dlink(q)
      if q.top <= 0 then
         q = d
      else
         u.dlink, d.ulink = q.id, q.id
         x.len = x.len + 1
         q = prev(q)
      end
   end
end


local function uncover (i)
   llink(i).rlink, rlink(i).llink = i.id, i.id
   local p = ulink(i)
   while p ~= i do
      unhide(p)
      p = ulink(p)
   end
end


local function print_option (p)
   if p.id <= p.N or p.id > p.Z or p.top <= 0 then
      return nil, "x is out of range"
   end
   -- find start item in the option
   local q = next(p)
   while q ~= p do
      if q.top <= 0 then
         q = ulink(q)
         break
      end
      q = next(q)
   end

   local option = {}
   repeat
      option[#option+1] = q.name
      q = next(q)
   until q.top <= 0

   return option
end


-- print contents of memory
function _M:memory_contents ()
   local nodes = self.nodes
   print('i',  'NAME', 'LLINK', 'RLINK')
   local n = 0
   while true do
      local v = nodes[n]
      if not v.llink then break end
      print(v.id, v.name, v.llink, v.rlink)
      n = n + 1
   end
   print('x', 'LEN', 'ULINK', 'DLINK')
   for j=0,n-1 do
      local v = nodes[j]
      print(v.id, v.len or v.top, v.ulink, v.dlink)
   end
   print('x', 'TOP', 'ULINK', 'DLINK')
   for j=n,#nodes do
      local v = nodes[j]
      print(v.id, v.len or v.top, v.ulink, v.dlink)
   end
   print()
end


local function dance (dlx)
   local i, p
   local l = 0
   local x = {}
   local root = dlx.nodes[0]

   -- D2. [Enter level l.]
   ::D2::
   if root.rlink == 0 then
      if dlx.debug then dlx:memory_contents() end
      local sol = {}
      for k=0,l-1 do
         local opt, err = print_option(x[k])
         if not opt then
            print(err)
         else
            sol[#sol+1] = opt
         end
      end
      co_yield(sol)
      goto D8 
   end

   -- D3. [Choose i.], Exercise 9
   i = mrv_heuristic(dlx.nodes)
   if not i then return nil end

   -- D4. [Cover i.]
   cover(i)
   x[l] = dlink(i)
   
   -- D5. [Try x[l].]
   ::D5::
   if x[l] == i then
      goto D7
   else
      p = next(x[l])
      while p ~= x[l] do
         if p.top <= 0 then
            p = ulink(p)
         else
            cover(top(p))
            p = next(p)
         end
      end
      l = l + 1
      goto D2
   end
   
   -- D6. [Try again.]
   ::D6::
   p = prev(x[l])
   while p ~= x[l] do
      if p.top <= 0 then
         p = dlink(p)
      else
         uncover(top(p))
         p = prev(p)
      end
   end
   i = top(x[l])
   x[l] = dlink(x[l])
   goto D5
   
   -- D7. [Backtrack]
   ::D7::
   uncover(i)
   
   -- D8. [Leave level l.]
   ::D8::
   if l == 0 then
      return
   end
   l = l - 1
   goto D6
end


function _M:dance ()
   return co_wrap(function () dance(self) end)
end


return _M

