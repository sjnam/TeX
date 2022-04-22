function getidx (range)
   local from, to = string.match(range, "(%d*)(%-?%d*)")
   if to == "" then
      return 1, tonumber(from)
   else
      to = tonumber(to)
      if not to then
         return tonumber(from), 10000
      end
      if to < 0 then
         return tonumber(from), -to
      end
   end
   return tonumber(from), tonumber(to)
end

print(getidx("3-5"))
print(getidx("3"))
print(getidx("3-"))
