-- http://www-cs-faculty.stanford.edu/~uno/fasc2b.ps.gz
-- The Art of Computer Programming Vol. 4A
-- 7.2.1.2. Generating all permutations.

local ffi = require "ffi"
local gmp = require "luagmp"

local pairs = pairs
local ipairs = ipairs
local concat = table.concat
local insert = table.insert
local gmatch = string.gmatch
local ffi_new = ffi.new
local gmp_new = gmp.new
local gmp_cmp = gmp.cmp
local gmp_add = gmp.add
local gmp_sub = gmp.sub
local gmp_pow = gmp.pow
local gmp_addmul = gmp.addmul
local gmp_submul = gmp.submul
local gmp_clear = gmp.clear


-- Algorithm T (Plain change transitions)
local function pct(n)
   local n = n or 10 -- default decimal
   if n < 2 then
      return nil, "n should be >= 2."
   end

   -- Initialize.
   local N = 1 -- n!
   local m, d, t

   for i=1,n do N = N * i end
   d = ffi_new("unsigned int")
   t = ffi_new("unsigned int[?]", N)
   
   m = 2
   d = N / 2
   t[d] = 1;

   -- Loop on m.
   while m ~= n do
      local k = 0
      m = m + 1
      d = d / m
      while k < N do
         -- Hunt down.
         k = k + d
         for j=m-1,1,-1 do
            t[k] = j
            k = k + d
         end
         -- Offset.
         t[k] = t[k] + 1
         k = k + d
         -- Hunt up.
         for j=1,m-1,1 do
            t[k] = j
            k = k + d
         end
      end
   end

   return t, N-1
end


-- converts string to char array
local function chars (str)
   local t = {}
   for c in gmatch(str,".") do
      insert(t, c)
   end
   return t
end


-- set signatures and chars
local function set_signature (self, side, sig, letters)
   local n = self.radix
   local first = self.first

   local arr, fn
   if side == "lhs" then
      fn = gmp_add
      arr = {}
      for _, str in ipairs(self.lhs) do
         insert(arr, chars(str))
      end
      self.lhs = arr
   else
      fn = gmp_sub
      arr = {}
      for _, str in ipairs(self.rhs) do
         insert(arr, chars(str))
      end
      self.rhs = arr
   end

   for _, tab in ipairs(arr) do
      first[tab[1]] = 1
      for j, c in ipairs(tab) do
         letters[c] = 1
         sig[c] = sig[c] or gmp_new("0", n)
         local exp = gmp_new("0", n)
         gmp_pow(exp, n, #tab-j)
         fn(sig[c], sig[c], exp)
         gmp_clear(exp)
      end
   end
end


-- prepare self
local function prepare (self)
   local N = self.radix
   local s = self.s
   local alpha = self.alpha
   
   local sig = {}
   local letters = {}

   set_signature(self, "lhs", sig, letters)
   set_signature(self, "rhs", sig, letters)

   for k, _ in pairs(letters) do
      insert(alpha, k)
      insert(s, sig[k])
   end
   
   if #alpha > N then
      print("too many letters")
      return
   end

   if #alpha < N then
      local dummy = #alpha + 1
      for i=dummy,N do
         alpha[i] = "*"
         s[i] = gmp_new("0", N)
      end
      self.dummy = dummy
   end

   local nfact = 1
   for j=1,N do nfact = nfact*j end
   self.nfact = nfact
end


-- Initialize.
local function init (self)
   local s = self.s
   local N = self.radix
   
   self.t = pct(N)
   self.a = {}
   for j=1,N do self.a[j] = j-1 end
   local v = gmp_new("0",N)
   for j=1,N do gmp_addmul(v, s[j], j-1) end
   self.v = v
   
   local d = {}
   for j=1,9 do
      d[j] = gmp_new("0",N)
      gmp_sub(d[j],s[j+1],s[j])
   end
   self.d = d
end


local function get_answer (hs, ahpla, a)
   local sol_hs = {}
   for _, str in ipairs(hs) do
      local t = {}
      for _, c in ipairs(str) do
         insert(t, a[ahpla[c]])
      end
      insert(sol_hs, concat(t))
   end
   return sol_hs
end


local function valid_answer (self)
   -- leading letter can't be zero 
   local a = self.a
   local N = self.radix
   local lhs = self.lhs
   local rhs = self.rhs
   local first = self.first
   local alpha = self.alpha
   local dummy = self.dummy
   
   local invalid = false
   for j=1,N do
      if a[j] == 0 and first[alpha[j]] then
         invalid = true
         break
      end
   end
   if invalid then return nil end

   -- ???
   for j=dummy,9 do
      if a[j] > a[j+1] then return nil end
   end

   -- alpha: k,v = v,k
   local ahpla = {}
   for i, c in ipairs(alpha) do
      ahpla[c] = i
   end

   return { get_answer(lhs, ahpla, a), get_answer(rhs, ahpla, a) }
end


-- alphametics module stuffs

local _M = { _VERSION = "0.1.0" }

local mt = { __index = _M }


function _M.new (lhs, rhs, radix)
   local n = radix or 10
   local tab = {
      radix = n,
      lhs = lhs,
      rhs = rhs,
      dummy = n,
      s = {},
      alpha = {},
      first = {}
   }

   prepare(tab)
   init(tab)

   return setmetatable(tab, mt) 
end


function _M.solutions (self)
   local t = self.t
   local v = self.v
   local a = self.a
   local d = self.d
   local lhs = self.lhs
   local rhs = self.rhs
   local nfact = self.nfact
   
   local answer = nil
   local k = 1
   while k ~= nfact do
      -- Test.
      if gmp_cmp(v, 0) == 0 then
         local sol = valid_answer(self)
         if sol then
            answer = answer or {}
            insert(answer, sol)
         end
      end
      -- Swap.
      j = t[k]
      local diff = a[j+1] - a[j];
      if diff > 0 then
         gmp_submul(v, d[j], diff)
      else
         gmp_addmul(v, d[j], -diff)
      end
      a[j+1], a[j] = a[j], a[j+1]
      k = k + 1
   end

   return answer
end


-- Clear.
function _M.clear (self)
   local v = self.v
   local d = self.d
   local s = self.s
   
   if v then gmp_clear(v) end

   if d then
      for j=1, #d do gmp_clear(d[j]) end
   end

   if s then
      for j=1, #s do gmp_clear(s[j]) end
   end
end


return _M

