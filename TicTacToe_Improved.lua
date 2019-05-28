INTERACTIVE = false
PRINT_DEB = true

--math.randomseed(os.clock())
math.randomseed(os.time())
math.random()

local C_samples = 10000
if PRINT_DEB then C_samples = 1 end -- on printing, sets samples to 1

local DIM = 3 -- 3x3, 4x4 etc..

local EMPTY = 1 
local X = 2
local O = 3
local R = 4 -- skip: skip players turn a no mark is placed
local G = 5 -- delete: randomly deletes one of the players marks
local B = 6 -- swap: players swap all position on field
local SIGN={"-","X","O", "R", "G", "B"} -- used for printing

local C_score = {0,0,0}

--save locations of player moves to randomly erase move when eraser is hit
local Xs = {}
local Os = {}


-- controls placement of special squares
local n = math.random(2)
local isR = false
local isG = false
local isB = false
 

function createNewGame()
    
    local game = {}
    
    game.board = {} -- board is an array of rows (rows are an array of cols)
    game.moves = {} --  moves is an array of row,col i.e. {2,1},{3,3}
    
    for iRow=1,DIM do
        game.board[iRow] = {}
        for iCol=1,DIM do
          n = math.random(2)
          --randomly place special square
          if n == 1 and isR == false then 
            game.board[iRow][iCol] = R
            table.insert(game.moves,{iRow=iRow,iCol=iCol})
            isR = true
          elseif n == 1 and isG == false then
            game.board[iRow][iCol] = G
            table.insert(game.moves,{iRow=iRow,iCol=iCol})
            isG = true
          elseif n == 1 and isB == false then
            game.board[iRow][iCol] = B
            table.insert(game.moves,{iRow=iRow,iCol=iCol})
            isB = true
          else
            game.board[iRow][iCol] = EMPTY
            table.insert(game.moves,{iRow=iRow,iCol=iCol})
          end
        end
    end
        
    game.turn = math.random(X,O)
    
    game.winner = nil
    
    game.iMove = 0
    
    return game
end

function runGame()
    
    local game = createNewGame()
    
    dprint("\n"..SIGN[game.turn].." is starting - Good luck!\n")
    
    while not(game.winner) and #game.moves>0 do
        waitForEnter()
        playTurn(game)
        printBoard(game) 
        changeTurn(game)
    end
    
    printWinner(game) 
    
    return game.winner
    
end


function evaluate(game)
    
    local winner = false
    
    for iRow =1,DIM do
        winner = true
        for iCol=1,DIM do
            if game.board[iRow][iCol] ~= game.turn then
                winner = false
                break
            end
        end
        if winner then return game.turn end
    end
    
    for iCol =1,DIM do
        winner = true
        for iRow =1,DIM do
            if game.board[iRow][iCol] ~= game.turn then
                winner = false
                break
            end
        end
        if winner then return game.turn end
    end
         
    winner = true
    for i=1,DIM do
        if game.board[i][i] ~= game.turn then
            winner = false
            break
        end
    end
    
    if winner then return game.turn end
    
    winner = true
    for i=1,DIM do
        if game.board[i][DIM-i+1] ~= game.turn then
            winner = false
            break
        end
    end
    
    if winner then return game.turn end
    
    return nil
end


function playTurn(game)
    
    game.iMove = game.iMove + 1
    
    local nextMove = table.remove(game.moves,math.random(#game.moves))
    
    -- *** SKIP ***
    if game.board[nextMove.iRow][nextMove.iCol] == R then
      table.insert(game.moves, {iRow = nextMove.iRow, iCol = nextMove.iCol}) --put move back
      game.board[nextMove.iRow][nextMove.iCol] = EMPTY
      
    -- *** ERASER ***
    elseif game.board[nextMove.iRow][nextMove.iCol] == G then
    
      --save player moves
      if game.turn == X then
        table.insert(Xs, {iRow = nextMove.iRow, iCol = nextMove.iCol})
      else 
        table.insert(Os, {iRow = nextMove.iRow, iCol = nextMove.iCol})
      end
      
      --set move on board
      game.board[nextMove.iRow][nextMove.iCol] = game.turn
    
      -- remove random move of current player
      if game.turn == X then
        r = math.random(table.getn(Xs)) -- get random index of Xs
        game.board[Xs[r].iRow][Xs[r].iCol] = EMPTY
        table.insert(game.moves, {iRow = Xs[r].iRow, iCol = Xs[r].iCol}) -- put move back to possible
        table.remove(Xs, r) --remove random entry
      else
        r = math.random(table.getn(Os)) -- get random index of Os
        game.board[Os[r].iRow][Os[r].iCol] = EMPTY
        table.insert(game.moves, {iRow = Os[r].iRow, iCol = Os[r].iCol}) -- put move back to possible
        table.remove(Os, r) --remove random entry
      end
      
    -- *** SWAP ***
    elseif game.board[nextMove.iRow][nextMove.iCol] == B then 
    
      game.board[nextMove.iRow][nextMove.iCol] = game.turn -- set move
      
      -- save player moves
      if game.turn == X then
        table.insert(Xs, {iRow = nextMove.iRow, iCol = nextMove.iCol})
      else 
        table.insert(Os, {iRow = nextMove.iRow, iCol = nextMove.iCol})
      end
      
      -- update game board
      for iRow = 1, DIM do
        for iCol = 1, DIM do
          if game.board[iRow][iCol] == X then
            game.board[iRow][iCol] = O
          elseif game.board[iRow][iCol] == O then
            game.board[iRow][iCol] = X
          end
        end
      end
      
      -- update moves
      tempXs = Xs -- temp for swap moves
      tempOs = Os
      Xs = {} -- clear
      Os ={}
      Xs = tempOs -- replace
      Os = tempXs
    
    else
      game.board[nextMove.iRow][nextMove.iCol] = game.turn
      
      -- save player moves
      if game.turn == X then
        table.insert(Xs, {iRow = nextMove.iRow, iCol = nextMove.iCol})
      else 
        table.insert(Os, {iRow = nextMove.iRow, iCol = nextMove.iCol})
      end
    end
    
    game.winner = evaluate(game)
    
end


function changeTurn(game)
    if game.turn == X then 
        game.turn = O 
    else 
        game.turn = X 
    end
end

function printBoard(game)
    
    if not(PRINT_DEB) then return end
    
    dprint("____________________")
    
    for iRow = 1,DIM do
        local strRow = "  "
        for iCol = 1, DIM do
            strRow = strRow..SIGN[game.board[iRow][iCol]].."\t"
        end
        dprint("\n"..strRow)
    end
        
end

function printWinner(game)
    
    if not(PRINT_DEB) then return end
    
    dprint("____________________")
    if game.winner then
        dprint("\nWinner is "..SIGN[game.winner].."\n")
    else
        dprint("Tie :) \n")
    end
        
end

function dprint(str)
    if PRINT_DEB then print(str) end
end

function trunc(x)
    return string.format("%.3f",x)
end

function percent(x)
    return string.format("%.3f",x*100).."%"
end

function waitForEnter()
    if PRINT_DEB == false then return end
    if INTERACTIVE == false then return end
    local a = io.read("*line")
end

function printRate(winner)
    print(SIGN[winner].." rate is: "..percent(C_score[winner]/C_samples))
end


for iSample = 1,C_samples  do
    local winner = runGame() or EMPTY -- the result of the runGame will be 2 for X, 3 for O and nil for EMPTY so we turn to 1
    C_score[winner] = C_score[winner] + 1
end

for i=EMPTY,O do
    printRate(i)
end


