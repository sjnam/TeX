
-- Sudoku solver by DLX

luatexbase.provides_module({
  name        = 'sudokudlx',
  date        = '2018/01/10',
  version     = 0.1,
  description = 'Sudoku solver by DLX',
  author      = 'Soojin Nam',
  license     = 'public domain',
})

sudokudlx = sudokudlx or {}
local sudokudlx = sudokudlx


local dlx1 = require "dlx1"


local type = type
local print = print
local ipairs = ipairs
local fread = io.read
local fopen = io.open
local write = io.write
local floor = math.floor
local tonumber = tonumber
local str_sub = string.sub
local str_gsub = string.gsub
local sformat = string.format
local str_match = string.match
local tinsert = table.insert
local tconcat = table.concat
local tremove = table.remove
local setmetatable = setmetatable
local co_wrap = coroutine.wrap
local co_yield = coroutine.yield
local sprint = tex.sprint


local function carr (s)
   str_gsub(s, "^%s*(.-)%s*$", "%1") -- trim
   local t = {}
   str_gsub(s, ".",
            function (c)
               if c == "." then
                  c = " "
               end
               t[#t+1] = c
            end
   )
   return t
end


local function mat (n)
   local t = {}
   for i=1,n do t[i] = {} end
   return t
end


local function split (line)
   local elems = {}
   line:gsub("([^%s]+)", function(c) elems[#elems+1] = c end)
   return elems
end


local function getline (lines)
   if lines then
      return tremove(lines, 1)
   end
   return fread()
end


-- read a sudoku puzzle
local function prepareInput (input_lines)
   if input_lines and type(input_lines) == "string" then
      input_lines = split(input_lines)
   end

   local k = 0
   local board = {}
   local row, col, box, brd = mat(9), mat(9), mat(9), mat(9)
   while true do
      local line = getline(input_lines)
      if not line then break end
      k = k + 1
      board[k] = carr(line)
      for j, d in ipairs(board[k]) do
         if d ~= ' ' then
            d = tonumber(d)
            row[k][d], col[j][d] = 1, 1
            local x = floor((k-1)/3)*3 + floor((j-1)/3) + 1
            box[x][d], brd[k][j] = 1, 1
         end
      end
   end

   local header = {}
   for k=1,9 do
      for j=1,9 do
         if not brd[k][j] then
            tinsert(header, sformat("p%d%d", k-1,j-1))
         end
      end
   end
   for k=1,9 do
      for d=1,9 do
         if not row[k][d] then tinsert(header, sformat("r%d%d", k-1,d)) end
         if not col[k][d] then tinsert(header, sformat("c%d%d", k-1,d)) end
         if not box[k][d] then tinsert(header, sformat("b%d%d", k-1,d)) end
      end
   end

   local lines = {}
   tinsert(lines, tconcat(header, " "))

   for j=1,9 do
      for k=1,9 do
         if not brd[k][j] then
            local x = floor((k-1)/3)*3 + floor((j-1)/3) + 1
            for d=1,9 do
               if not row[k][d] and not col[j][d] and not box[x][d] then
                  tinsert(lines, sformat("p%d%d r%d%d c%d%d b%d%d",
                                         k-1,j-1,k-1,d,j-1,d,x-1,d))
               end
            end
         end
      end
   end

   return board, lines
end


local function xsudoku (puzzle)
   -- prepare input
   local board, lines = prepareInput(puzzle)

   -- dlx setup
   local dlx, err = dlx1:new(lines)
   if not dlx then
      return nil, "setup error: "..err 
   end
   -- Let's dance!
   for sol in dlx:dance() do 
      local brd = {}
      for j=1,9 do
         brd[j] = board[j]
      end
      for _, opt in ipairs(sol) do
         local pos = tonumber(str_match(opt[1], "p(%d+)"))
         brd[floor(pos/10)+1 ][pos%10+1] = "\\color{blue}"..str_sub(opt[2], 3)
      end
      co_yield(brd)
   end
end


local function sudoku (puzzle)
   return co_wrap(function () xsudoku(puzzle) end)
end


local function draw (board)
   sprint([[
\begin{tikzpicture}[scale=.7]
\begin{scope}[font=\ttfamily\bfseries\Large]
\draw (0, 0) grid (9, 9);
\draw[very thick, scale=3] (0, 0) grid (3, 3);
\setcounter{row}{1}
]])
   for i=1,9 do
      sprint("\\setrow")
      for j=1,9 do
         sprint("{"..board[i][j].."}")
      end
      sprint("\n")
   end
   sprint("\\end{scope}\n\\end{tikzpicture}")
end


local function get_lines (str)
   local n = 9
   local lines = {}
   for i=0,n-1 do
      lines[#lines+1] = str:sub(i*n+1, (i+1)*n)
   end
   return lines
end


local function question (puzzle)
   local board = {}
   for i, v in ipairs(get_lines(puzzle)) do
      board[i] = carr(v)
   end
   draw(board)
end


local function answer (puzzle)
   for board in sudoku(get_lines(puzzle)) do
      draw(board)
      sprint("\\quad")
   end
end


local function solve (isanswer, puzzle)
   if isanswer then
      answer(puzzle)
   else
      question(puzzle)
   end
end


sudokudlx.solve = solve
