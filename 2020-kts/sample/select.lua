function range (rangestr)
   local from, m, to = string.match(rangestr, "(%d*)(%-?)(%d*)")
   if m == "" then
      return 1, tonumber(from)
   else
      if to == "" then
         return tonumber(from), 10000
      end
   end
   return tonumber(from), tonumber(to)
end

local from, to = range("1000")
getlines = function (head)
   local idx = 0
   local curr = head
   while curr do
      if curr.id == 0 then
         idx = idx + 1
         if idx == from then
            head = curr
         elseif idx == to then
            curr.next = nil
            break
         end
      end
      curr = curr.next
   end
   return head
end

luatexbase.add_to_callback("post_linebreak_filter", getlines, "getlines")
