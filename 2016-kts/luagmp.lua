-- gmp for luajit

local ffi = require "ffi"

local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_load = ffi.load
local ffi_typeof = ffi.typeof
local ffi_cast = ffi.cast
local ffi_gc = ffi.gc
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local assert = assert
local error = error
-- local match = string.match

ffi.cdef[[
typedef struct {
  int _mp_alloc;
  int _mp_size;	
  unsigned int *_mp_d;
} __mpz_struct;

typedef __mpz_struct *mpz_ptr;
typedef __mpz_struct mpz_t[1];
typedef const __mpz_struct *mpz_srcptr;
typedef unsigned long int   mp_bitcnt_t;

void __gmpz_init (mpz_ptr);
void __gmpz_init_set_ui (mpz_ptr, unsigned long int);
int  __gmpz_init_set_str (mpz_ptr, const char *, int);

void __gmpz_set (mpz_ptr, mpz_srcptr);
void __gmpz_set_ui (mpz_ptr, unsigned long int);

unsigned long int __gmpz_get_ui (mpz_srcptr);
char *__gmpz_get_str (char *, int, mpz_srcptr);

void __gmpz_add (mpz_ptr, mpz_srcptr, mpz_srcptr);
void __gmpz_add_ui (mpz_ptr, mpz_srcptr, unsigned long int);

void __gmpz_addmul (mpz_ptr, mpz_srcptr, mpz_srcptr);
void __gmpz_addmul_ui (mpz_ptr, mpz_srcptr, unsigned long int);

void __gmpz_sub (mpz_ptr, mpz_srcptr, mpz_srcptr);
void __gmpz_sub_ui (mpz_ptr, mpz_srcptr, unsigned long int);

void __gmpz_submul (mpz_ptr, mpz_srcptr, mpz_srcptr);
void __gmpz_submul_ui (mpz_ptr, mpz_srcptr, unsigned long int);

void __gmpz_mul (mpz_ptr, mpz_srcptr, mpz_srcptr);
void __gmpz_mul_ui (mpz_ptr, mpz_srcptr, unsigned long int);

void __gmpz_pow_ui (mpz_ptr, mpz_srcptr, unsigned long int);
void __gmpz_ui_pow_ui (mpz_ptr, unsigned long int, unsigned long int);

int __gmpz_probab_prime_p(mpz_srcptr, int);
void __gmpz_nextprime (mpz_ptr, mpz_srcptr);

void __gmpz_gcd (mpz_ptr, mpz_srcptr, mpz_srcptr);
unsigned long int __gmpz_gcd_ui (mpz_ptr, mpz_srcptr, unsigned long int);
void __gmpz_gcdext (mpz_ptr, mpz_ptr, mpz_ptr, mpz_srcptr, mpz_srcptr);

void __gmpz_lcm (mpz_ptr, mpz_srcptr, mpz_srcptr);
void __gmpz_lcm_ui (mpz_ptr, mpz_srcptr, unsigned long);

void __gmpz_fac_ui (mpz_ptr, unsigned long int);
void __gmpz_2fac_ui (mpz_ptr, unsigned long int);

void __gmpz_bin_ui (mpz_ptr, mpz_srcptr, unsigned long int);
void __gmpz_bin_uiui (mpz_ptr, unsigned long int, unsigned long int);

void __gmpz_and (mpz_ptr, mpz_srcptr, mpz_srcptr);
void __gmpz_ior (mpz_ptr, mpz_srcptr, mpz_srcptr);

void __gmpz_mul_2exp (mpz_ptr, mpz_srcptr, mp_bitcnt_t);
void __gmpz_tdiv_q_2exp (mpz_ptr, mpz_srcptr, mp_bitcnt_t);

int __gmpz_cmp (mpz_srcptr, mpz_srcptr);
int __gmpz_cmp_ui (mpz_srcptr, unsigned long int);

char *__gmpz_get_str (char *, int, mpz_srcptr);
void __gmpz_clear (mpz_ptr);
]]

local mpz_type = ffi_typeof("mpz_t")

local gmp = ffi_load("gmp")


local function _check_base(obj)
   assert(type(obj) == "number" 
          and obj >= 2 and obj <= 62 and obj%1 == 0, 
          "gmp number base must be an integer between 2 and 62")
end


local _M = {
   _VERSION = '0.01'
}


local mt = { 
   __index = _M, 
   __tostring = function (z)
      return ffi_str(gmp.__gmpz_get_str(nil, 10, z._z))
   end
}


function _M.new (v, b)
   local x = ffi_new(mpz_type)
   if not v and not b then
      gmp.__gmpz_init(x)
   elseif type(v) == "number" then
      gmp.__gmpz_init_set_ui(x, v)
   elseif type(v) == "string" then
      b = b or 10
      gmp.__gmpz_init_set_str(x, v, b)
   end
   return setmetatable({ _z = x }, mt)
end


function _M.clear (self)
   if self._z then
      ffi_gc(self._z, gmp.__gmpz_clear)
   end
   self._z = nil
   self = nil
end


-- set
function _M.set (self, x)
   if type(x) == "table" then
      gmp.__gmpz_set(self._z, x._z)
   else
      gmp.__gmpz_set_ui(self._z, x)
   end
end


-- get_ui
function _M.get_ui (self)
   return tonumber(gmp.__gmpz_get_ui(self._z))
end


-- get_str
function _M.get_str (self, base)
   return ffi_str(gmp.__gmpz_get_str(nil, base or 10, self._z))
end


-- add
function _M.add (self, x, y)
   if type(y) == "table" then
      gmp.__gmpz_add(self._z, x._z, y._z)
   else   
      gmp.__gmpz_add_ui(self._z, x._z, y)
   end
end


-- mul
function _M.mul (self, x, y)
   if type(y) == "table" then
      gmp.__gmpz_mul(self._z, x._z, y._z)
   else   
      gmp.__gmpz_mul_ui(self._z, x._z, y)
   end
end

-- pow
function _M.pow (self, x, y)
   if type(x) == "table" then
      gmp.__gmpz_pow_ui(self._z, x._z, y)
   else   
      gmp.__gmpz_ui_pow_ui(self._z, x, y)
   end
end


-- addmul
function _M.addmul (self, x, y)
   if type(y) == "table" then
      gmp.__gmpz_addmul(self._z, x._z, y._z)
   else   
      gmp.__gmpz_addmul_ui(self._z, x._z, y)
   end
end


-- sub
function _M.sub (self, x, y)
   if type(y) == "table" then
      gmp.__gmpz_sub(self._z, x._z, y._z)
   else   
      gmp.__gmpz_sub_ui(self._z, x._z, y)
   end
end


-- submul
function _M.submul (self, x, y)
   if type(y) == "table" then
      gmp.__gmpz_submul(self._z, x._z, y._z)
   else   
      gmp.__gmpz_submul_ui(self._z, x._z, y)
   end
end


-- cmp
function _M.cmp (self, x)
   if type(x) == "table" then
      return tonumber(gmp.__gmpz_cmp(self._z, x._z))
   else
      return tonumber(gmp.__gmpz_cmp_ui(self._z, x))
   end
end


-- number theoretic functions
function _M.probab_prime (self, reps)
   return (gmp.__gmpz_probab_prime_p(self._z, reps or 25) ~= 0) 
      and true or false
end


function _M.nextprime (self, x)
   gmp.__gmpz_nextprime(self._z, x._z)
end


function _M.gcd (self, x, y)
   if type(y) == "table" then
      gmp.__gmpz_gcd(self._z, x._z, y._z) 
   else
      gmp.__gmpz_gcd_ui(self._z, x._z, y) 
   end
end


function _M.gcdext (self, s, t, a, b)
   gmp.__gmpz.gcdext(self._z, s._z, t._z, a._z, b._z)
end


function _M.lcm (self, x, y)
   if type(y) == "table" then
      gmp.__gmpz_lcm(self._z, x._z, y._z) 
   else
      gmp.__gmpz_lcm_ui(self._z, x._z, y) 
   end
end


function _M.fac (self, n)
   local n = ffi_cast("uint32_t", n)
   gmp.__gmpz_fac_ui(self._z, n)
end


function _M.fac2 (self, n)
   local n = ffi_cast("uint32_t", n)
   gmp.__gmpz_2fac_ui(self._z, n)
end


function _M.bin (self, n, r)
   if type(n) == "table" then
      gmp.__gmpz_bin_ui(self._z, n._z, r)
   else
      gmp.__gmpz_bin_uiui(self._z, n, r)
   end
end

-- and
function _M.land (self, x, y)
   gmp.__gmpz_and(z._z, x._z, y._z)
end

-- ior
function _M.ior (self, x, y)
   gmp.__gmpz_ior(z._z, x._z, y._z)
end

-- mul_2exp
function _M.mul_2exp (self, x, n)
   gmp.__gmpz_mul_2exp (self._z, x._z, n);
end

-- tdiv_q_2exp
function _M.tdiv_q_2exp (self, x, n)
   gmp.__gmpz_tdiv_q_2exp (self._z, x._z, n);
end

-- and
function _M.land (self, x, y)
   gmp.__gmpz_and(self._z, x._z, y._z)
end


-- ior
function _M.ior (self, x, y)
   gmp.__gmpz_ior(self._z, x._z, y._z)
end


-- mul_2exp
function _M.mul_2exp (self, x, n)
   gmp.__gmpz_mul_2exp (self._z, x._z, n);
end


-- tdiv_q_2exp
function _M.tdiv_q_2exp (self, x, n)
   gmp.__gmpz_tdiv_q_2exp (self._z, x._z, n);
end


return _M

