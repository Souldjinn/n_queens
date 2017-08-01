BOARD_A = [
            ["Q....",
             "..Q..",
             "....Q",
             ".Q...",
             "...Q."], ## valid
            ["Q....",
             "..Q..",
             "....Q",
             ".....",
             "....."], ## valid
            [".Q...",
             "...Q.",
             "Q....",
             "..Q..",
             "....Q"], ## valid
            [".Q...",
             "....Q",
             "Q....",
             "..Q..",
             "....Q"], ## invalid
             ["Q...",
              "..Q.",
              "....",
              "...."] ## valid
          ]

          #   [Q . . . .]
          #   [. . Q . .],
          #   [. . . . Q],
          #   [. . . . .],
          #   [. . . . .]
          # [0, 7, 14, 16, 21, 23]
# [Q . . . .]
# [. . Q . .]
# [. . . . Q]
# [. Q . . .]
# [. . . Q .]

#     cd = (column - @column).abs
#     rd = (row - @row).abs
#     return true if cd == rd
#    0 1 2 3 4
# 0 [. Q . . .]       2 -1 =1, 1-0 = 0
# 1 [. . Q . .]
# 2 [Q . . . .]
# 3 [. . Q . .]
# 4 [. . . . Q]

# [. . Q . .]
# [Q . . . .]
# [. . . Q .]
# [. Q . . .]
# [. . . . Q] unrecorded
  # [1,4,0,2,4]
# [1, 9, 10, 17, 24]
# [. Q . . .] 1 diagonals = 5, 7, 13, 19
# [. . . . Q] 9 diagonals = 3, 13, 17, 21
# [Q . . . .] 10 diagonals = 2, 6, 16, 22
# [. . Q . .] 17 diagonals = 21, 23, 11, 13, 5, 9,
# [. . . . Q] 24 diagonals = 18, 12, 6, 0

def old_valid_board?(ary)
  queen_placements = ary.map{|x| x.index("Q")} ## could check duplicates here for fast return

  board_as_string = ary.join('').split('')

  invalid_spaces = []
  nqueens = ary.size

  queen_placements.each_with_index do |q, idx|
    next if q == nil
    board_max = nqueens*nqueens -1
    qplace = idx*nqueens + q

    horizontal = (idx*nqueens)...(idx*nqueens+nqueens)
    horizontal = horizontal.to_a
    horizontal.delete(q+(idx*nqueens))
    invalid_spaces = invalid_spaces + horizontal

    vertical = []
    nqueens.times{|i| vertical << (q + nqueens*i) }
    vertical.delete(q+(idx*nqueens))
    invalid_spaces = invalid_spaces + vertical

    diagonal = []

    go_left = (1..q).to_a
    go_left.each do |i|
      top_left = qplace - (nqueens+1)*i
      bottom_left = qplace + (nqueens-1)*i
      diagonal << top_left if top_left >= 0
      diagonal << bottom_left if bottom_left <= board_max
    end

    go_right = (1..(nqueens-(q+1)))
    go_right.each do |i|
      top_right = qplace - (nqueens-1)*i
      bottom_right = qplace + (nqueens+1)*i
      diagonal << top_right if top_right >= 0
      diagonal << bottom_right if bottom_right <= board_max
    end

    invalid_spaces = invalid_spaces + diagonal
  end

  queens_numerical_placement = queen_placements.compact.each_with_index.map{|x,i| i*nqueens + x}
  invalid_spaces.each do |s|
    if queens_numerical_placement.include?(s)
      return false
    end
  end

  return true
end

def valid_board?(board)
  twod_board = board.map{ |x| x.split("") }
  twod_board.each_with_index do |row, idx|
    curr_col = row.index("Q")
    next if curr_col == nil
    twod_board.each_with_index do |other_row, other_idx|
      next if idx == other_idx
      other_col = other_row.index("Q")
      next if other_col == nil
      cd = (other_col - curr_col).abs
      rd = (other_idx - idx).abs
      return false if cd == rd
    end
  end
  true
end

def solve_n_queens(n)
  board_results = []
  ## place queen on first point of row
  ## if bad placement, remove and place in next spot
  ## if good placement try the same with the next row
  ## once queen is in valid spot do the same with the next row of the board
  place_queen_on_row = lambda do |row, board, cols_used|
    if board.all?{|row| row.include?("Q") }
      board_results = board_results + [board.clone]
      return
    end

    board.size.times do |i|
      next if cols_used.include?(i)

      split_row = board[row].split('')
      split_row[i] = "Q"
      board[row] = split_row.join('')
      if valid_board?(board)
        cols_used << i
        place_queen_on_row.call(row+1, board, cols_used)
      end
      cols_used.delete(i)
      board[row] = "."*board.size
    end

  end
  base_board = []
  n.times{ base_board << "." * n }

  place_queen_on_row.call(0, base_board, [])
  board_results
end

def solve_with_time(n)
  start = Time.now()
  solve_n_queens(n)
  stop = Time.now()
  puts (stop - start)
end
