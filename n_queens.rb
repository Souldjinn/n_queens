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
              "...."]
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

# [. Q . . .]
# [. . . Q .]
# [Q . . . .]
# [. . Q . .]
# [. . . . Q]

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

def valid_board?(ary)
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

def solve_n_queens_two(n)
  board_results = []
  ## place queen on first point of row
  ## if bad placement, remove and place in next spot
  ## if good placement try the same with the next row
  ## once queen is in valid spot do the same with the next row of the board
  place_queen_on_row = lambda do |row, board|
    if board.all?{|row| row.include?("Q") }
      board_results = board_results + [board.clone]
      return
    end

    board.size.times do |i|
      split_row = board[row].split('')
      split_row[i] = "Q"
      board[row] = split_row.join('')
      if valid_board?(board)
        place_queen_on_row.call(row+1, board)
      end
      board[row] = "."*board.size
    end

  end
  base_board = []
  n.times{ base_board << "." * n }

  place_queen_on_row.call(0, base_board)
  board_results
end

=begin
  Pseudocode
  1. Given a board, find available placements
  2. Generate board for each available placement of queen
  3.
=end
def solve_n_queens(n)
  base_board = []
  n.times{base_board << "."*n}
  solutions = solve_n_queens_for_board(base_board, []) #boards with queens in valid positions, not necessarily complete
  res = solutions.keep_if do |board|
      valid_board = true
      board.each{|x| valid_board = false if (x.index("Q") == nil)}
      valid_board
  end
  #for solving n_queens of size 6 it made 2880 boards.
  # res.uniq
end

def solve_n_queens_for_board(board, valid_boards)
  valid_pos = find_valid_positions(board)

  if valid_pos.empty?
    return valid_boards << board
  end

  more_boards = []
  valid_pos.each do |pos|
    two_d = one_dim_two_dim(pos, board.size)
    # new_board = Marshal.load(Marshal.dump(board))
    new_board = board.clone
    new_board.clear
    board.each{|v| new_board << v.clone}
    st = new_board[two_d[1]]
    st[two_d[0]] = "Q"
    new_board[two_d[1]] = st
    more_boards << new_board
  end

  extra_boards = []
  more_boards.each do |bo|
    extra_boards + solve_n_queens_for_board(bo, valid_boards)
  end

  extra_boards + valid_boards
end

 # pos_ary is [x_axis, y_axis]
def two_dim_one_dim(pos_ary, size)
  size*pos_ary[1] + pos_ary[0]
end

def one_dim_two_dim(pos, size)
  y = pos/size
  x = pos%size
  return [x, y]
  #[x_axis, y_axis]
end

def find_valid_positions(board)

  queen_placements = board.map{|x| x.index("Q")} ## could check duplicates here for fast return

  board_as_string = board.join('').split('')

  invalid_spaces = []
  nqueens = board.size

  queen_placements.each_with_index do |q, idx|
    next if q == nil
    board_max = nqueens*nqueens -1
    qplace = idx*nqueens + q

    horizontal = (idx*nqueens)...(idx*nqueens+nqueens)
    horizontal = horizontal.to_a
    invalid_spaces = invalid_spaces + horizontal

    vertical = []
    nqueens.times{|i| vertical << (q + nqueens*i) }
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

  all_spaces = (0..(nqueens*nqueens - 1)).to_a
  all_spaces - invalid_spaces
end
