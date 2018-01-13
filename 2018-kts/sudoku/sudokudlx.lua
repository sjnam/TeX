
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


local sudoku = require "sudoku"


local ipairs = ipairs
local sprint = tex.sprint
local str_gsub = string.gsub
local tconcat = table.concat


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


local function get_lines (str)
   local n = 9
   local lines = {}
   for i=0,n-1 do
      lines[#lines+1] = str:sub(i*n+1, (i+1)*n)
   end
   return lines
end


local function draw (board)
   sprint([[
\begin{tikzpicture}[scale=.6]
\begin{scope}
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
   sprint("\\end{scope}\n\\end{tikzpicture}\\qquad")
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
