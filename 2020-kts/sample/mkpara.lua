local txt = [[A wonderful serenity has taken possession of my entire soul,
like these sweet mornings of spring which I enjoy with my whole heart.
I am alone, and feel the charm of existence in this spot, which was created
for the bliss of souls like mine.]]

local cur_font = font.current()
local font_params = font.getfont(cur_font).parameters

-- we should insert the paragraph indentation at the beginning
local head = node.new("hlist")
head.width = 20 * 2^16
local last = head

local n
for s in string.utfvalues(txt) do
   local char = unicode.utf8.char(s)
   if unicode.utf8.match(char,"%s") then
      -- a space
      n = node.new("glue")
      n.width   = font_params.space
      n.shrink  = font_params.space_shrink
      n.stretch = font_params.space_stretch
   else
      -- a glyph
      n = node.new("glyph")
      n.font = cur_font
      n.subtype = 1
      n.char = s
      n.lang = tex.language
      n.uchyph = 1
      n.left = tex.lefthyphenmin
      n.right = tex.righthyphenmin
   end
   last.next = n
   last = n
end

-- now add the final parts:
-- penalty
n = node.new("penalty")
n.penalty = 10000
last.next = n
last = n

-- parfillskip glue
n = node.new("glue")
n.stretch = 2^16
n.stretch_order = 2
last.next = n
last = n

-- just to create the prev pointers for tex.linebreak
last = node.slide(head)

lang.hyphenate(head)
head = node.kerning(head)
head = node.ligaturing(head)

local vbox = tex.linebreak(head, {hsize=tex.sp("3in")})
node.write(vbox)
