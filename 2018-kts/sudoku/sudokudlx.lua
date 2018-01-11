
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


local function question (puzzle)
   local board = {}
   for i, v in ipairs(get_lines(puzzle)) do
      board[i] = carr(v)
   end
   sprint("\\begin{sudoku}\n")
   for i=1,9 do
      sprint("|"..tconcat(board[i], "|").."|.\n")
   end
   sprint("\\end{sudoku}\n")
end


local function answer (puzzle)
   for board in sudoku(get_lines(puzzle)) do
      sprint("\\begin{sudoku}\n")
      for i=1,9 do
         sprint("|"..tconcat(board[i], "|").."|.\n")
      end
      sprint("\\end{sudoku}\n")
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
