# frozen_string_literal: true

class ConnectFour
  attr_reader :grid
  attr_accessor :current_player

  def initialize
    @current_player = 1
    @grid = Array.new(6) { Array.new(7) { 0 } }
    @moves_list = Array.new(7) { [] }
  end

  def play_game
    intro_message
    loop do
      print_grid
      make_move
      break if game_over?

      switch_players
    end
    print_grid
    sleep 0.5
    puts "\nCongratulations Player #{current_player}! You win!"
  end

  def make_move
    print "\nMake a move Player #{current_player} >> "
    move = input_move
    until valid_move?(move)
      puts 'Invalid move. Please input a number between 1 and 7'
      move = input_move
    end
    save_move(move)
    update_grid(move)
  end

  def input_move
    gets.chomp.to_i
  end

  def valid_move?(move)
    move.between?(1, 7) && @moves_list[move - 1].length < 6
  end

  def save_move(move)
    @moves_list[move - 1] << current_player
  end

  def update_grid(move)
    row = 6 - @moves_list[move - 1].length # index of last item
    grid[row][move - 1] = current_player
  end

  def game_over?
    check_horizontal || check_vertical || check_diagonals
  end

  def check_horizontal(h_grid = grid, counter = 0)
    h_grid.each do |row|
      counter = count_pieces(row)
      return true if counter == 4
    end
    false
  end

  def check_vertical
    v_grid = grid.transpose
    check_horizontal(v_grid)
  end

  def check_diagonals
    ltr_fixed_rows || ltr_fixed_cols || rtl_fixed_rows || rtl_fixed_cols
  end

  def intro_message
    puts <<~HEREDOC
      WELCOME TO "CONNECT 4!"

      This is a two player game in which you will drop your pieces down a 7-column, 6-row grid with the
      objective of being the first to form a horizontal, vertical, or diagonal line of four of your own
      pieces.

      Player 1 pieces will be represented by #{"\u2688".encode('utf-8')}
      Player 2 pieces will be represented by #{"\u2689".encode('utf-8')}

      INSTRUCTIONS:
        * On your turn, select one of the columns of the grid to drop your piece.
        * Columns are numbered from 1 to 7, and the column number is indicated at the top of each column.

      [Press any key to start the game]
    HEREDOC
    return if gets.chomp
  end

  def print_grid
    system('clear')
    puts "\n\t  1   2   3   4   5   6   7\n\n"
    grid.each do |row|
      row.each_with_index do |cell, index|
        print "\t|" if index.zero?
        print " #{"\u2688".encode('utf-8')} |" if cell == 1
        print " #{"\u2689".encode('utf-8')} |" if cell == 2
        print '   |' if cell.zero?
      end
      puts "\n"
    end
  end

  def switch_players
    self.current_player = current_player == 1 ? 2 : 1
  end

  private

  def count_pieces(row)
    row.reduce(0) do |count, cell|
      if count < 4 && cell == current_player
        count + 1
      elsif count == 4
        count
      else
        0
      end
    end
  end

  def ltr_fixed_rows(diagonal = [], base_row = 0, row = 0, col = 0)
    until base_row > 2
      cell = grid[base_row][col]
      until row > 5
        diagonal.push(cell)
        row += 1
        col += 1
        cell = grid[row][col] if row <= 5
      end
      return true if count_pieces(diagonal) == 4

      base_row += 1
      row = base_row
      col = 0
      diagonal.clear
    end
    false
  end

  def ltr_fixed_cols(diagonal = [], base_col = 1, row = 0, col = 1)
    until base_col > 3
      cell = grid[row][base_col]
      until col > 6
        diagonal.push(cell)
        row += 1
        col += 1
        cell = grid[row][col] if col <= 6
      end
      return true if count_pieces(diagonal) == 4

      base_col += 1
      row = 0
      col = base_col
      diagonal.clear
    end
    false
  end

  def rtl_fixed_rows(diagonal = [], base_row = 0, row = 0, col = 6)
    until base_row > 2
      cell = grid[base_row][col]
      until row > 5
        diagonal.push(cell)
        row += 1
        col -= 1
        cell = grid[row][col] if row <= 5
      end
      return true if count_pieces(diagonal) == 4

      base_row += 1
      row = base_row
      col = 6
      diagonal.clear
    end
    false
  end

  def rtl_fixed_cols(diagonal = [], base_col = 3, row = 0, col = 3)
    until base_col > 5
      cell = grid[row][base_col]
      until col.negative?
        diagonal.push(cell)
        row += 1
        col -= 1
        cell = grid[row][col] if col >= 0
      end
      return true if count_pieces(diagonal) == 4

      base_col += 1
      row = 0
      col = base_col
      diagonal.clear
    end
    false
  end
end
