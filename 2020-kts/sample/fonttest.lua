local fontify = function (id)
   return function (hd)
      for n in node.traverse (hd) do
         if n.id == node.id("glyph") then n.font = id end
      end
      return hd
   end
end

local main = function ()
   local tfmdata = fonts.definers.read
   ("file:FiraSans-Bold.otf:mode=base", 42*2^16)
   local id = font.define (tfmdata)
   luatexbase.add_to_callback("pre_linebreak_filter", fontify (id),
                              "userdata.stackexchange.fontify")
end

return main ()
