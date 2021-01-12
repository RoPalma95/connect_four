
require_relative '../lib/connect_four'
require_relative '../lib/player'

describe ConnectFour do
  describe '#make_move' do
    subject(:game) { described_class.new }

    context 'when a player makes a valid move' do
      before do
        input = 5
        allow(game).to receive(:input_move).and_return(input)
        allow(game).to receive(:valid_move?).with(input).and_return(true) 
      end

      it 'saves the move' do
        allow(game).to receive(:update_grid)
        expect(game).to receive(:save_move)
        game.make_move
      end

      it 'updates the grid' do
        expect(game).to receive(:update_grid)
        game.make_move
      end
    end
  end

  describe '#valid_move?' do
    subject(:game) { described_class.new }
    # grid = Array.new(6) { Array.new(7) { 0 } } <- Default/initial grid
    context 'when the selected column has empty cells' do
      it 'returns true' do
        input = 5
        valid = game.valid_move?(input)
        expect(valid).to be true
      end
    end

    context "when the selected column doesn't have empty cells" do
      before do
        game.instance_variable_set(:@moves_list, Array.new(7) { Array.new(6) { 1 } }) # all cells are occupied
      end

      it 'returns false' do
        input = 5
        valid = game.valid_move?(input)
        expect(valid).to be false
      end
    end

    context 'when the selected cell is > 7' do
      it 'returns false' do
        input = 8
        valid = game.valid_move?(input)
        expect(valid).to be false
      end
    end

    context 'when the selected cell is < 1' do
      it 'returns false' do
        input = 0
        valid = game.valid_move?(input)
        expect(valid).to be false
      end
    end
  end

  describe '#save_move' do
    subject(:game) { described_class.new }

    context "player 1's move is valid" do
      it 'stores current move in @moves_list' do
        input = 5
        list = game.instance_variable_get(:@moves_list)
        expect { game.save_move(input) }.to change { list[input - 1].length }
      end
    end

    context "player 2's move is valid" do
      before do
        game.instance_variable_set(:@current_player, 2)
      end
      it 'stores current move in @moves_list' do
        input = 5
        list = game.instance_variable_get(:@moves_list)
        expect { game.save_move(input) }.to change { list[input - 1].length }
      end
    end
  end

  describe '#update_grid' do
    subject(:game) { described_class.new }

    context 'a valid move was made' do
      before do
        updated_list = [[], [], [], [], [1], [], []]
        game.instance_variable_set(:@moves_list, updated_list)
      end

      it 'pushes current player number into input cell' do
        input = 5
        grid = game.instance_variable_get(:@grid)
        game.update_grid(input)
        expect(grid[5][input - 1]).to eq(1)
      end
    end

    context 'another valid move was made' do
      before do
        updated_list = [[], [], [], [], [1, 2], [], []]
        game.instance_variable_set(:@moves_list, updated_list)
        game.instance_variable_set(:@current_player, 2)
      end

      it 'pushes current player number into input cell' do
        input = 5
        grid = game.instance_variable_get(:@grid)
        game.update_grid(input)
        expect(grid[4][input - 1]).to eq(2)
      end
    end
  end

  describe '#check_horizontal' do
    subject(:game) { described_class.new }

    context 'when a row has 4 adjacent pieces by the same player' do
      before do
        grid = [[0, 0, 0, 1, 1, 1, 0], 
                [0, 0, 0, 0, 0, 0, 0],
                [1, 1, 1, 0, 0, 1, 1],
                [0, 0, 0, 2, 2, 2, 2],
                [2, 0, 1, 2, 1, 2, 0],
                [1, 1, 0, 1, 1, 1, 1]]
        game.instance_variable_set(:@grid, grid)
      end

      it 'returns true for player 1' do
        horizontal = game.check_horizontal
        expect(horizontal).to be true
      end

      it 'returns true for player 2' do
        game.instance_variable_set(:@current_player, 2)
        horizontal = game.check_horizontal
        expect(horizontal).to be true
      end
    end
  end

  describe '#check vertical' do
    subject(:game) { described_class.new }

    context 'when a column has 4 stacked pieces by the same player' do
      before do
        grid = [[0, 0, 0, 0, 0, 2, 1], 
                [0, 1, 0, 0, 0, 2, 1],
                [0, 1, 0, 0, 1, 2, 1],
                [0, 1, 0, 1, 1, 2, 0],
                [0, 1, 0, 1, 1, 1, 0],
                [0, 2, 0, 2, 2, 1, 0]]
        game.instance_variable_set(:@grid, grid)
      end

      it 'returns true for player 1' do
        vertical = game.check_vertical
        expect(vertical).to be true
      end

      it 'returns true for player 2' do
        game.instance_variable_set(:@current_player, 2)
        vertical = game.check_vertical
        expect(vertical).to be true
      end
    end
  end

  describe '#check_diagonals' do
    subject(:game) { described_class.new }

    context 'a 4-piece left-to-right diagonal' do
      before do
        grid = [[0, 0, 0, 2, 0, 0, 0], 
                [0, 0, 0, 0, 2, 0, 0],
                [1, 0, 0, 0, 0, 2, 0],
                [0, 1, 0, 0, 0, 0, 2],
                [0, 0, 1, 0, 0, 0, 0],
                [0, 0, 0, 1, 0, 0, 0]]
        game.instance_variable_set(:@grid, grid)
      end

      it 'returns true for player 1' do
        diagonal = game.check_diagonals
        expect(diagonal).to be true
      end

      it 'returns true for player 2' do
        game.instance_variable_set(:@current_player, 2)
        diagonal = game.check_diagonals
        expect(diagonal).to be true
      end
    end

    context 'a 4-piece right-to-left diagonal' do
      before do
        grid = [[0, 0, 0, 0, 0, 0, 0], 
                [0, 0, 0, 0, 0, 0, 2],
                [0, 0, 0, 1, 0, 2, 0],
                [0, 0, 1, 0, 2, 0, 2],
                [0, 1, 0, 2, 0, 2, 0],
                [1, 0, 0, 0, 2, 0, 0]]
        game.instance_variable_set(:@grid, grid)
      end

      it 'returns true for player 1' do
        diagonal = game.check_diagonals
        expect(diagonal).to be true
      end

      it 'returns true for player 2' do
        game.instance_variable_set(:@current_player, 2)
        diagonal = game.check_diagonals
        expect(diagonal).to be true
      end
    end
  end

  describe '#game_over?' do
    subject(:game) { described_class.new }

    context 'horizontal win' do
      before do
        allow(game).to receive(:check_horizontal).and_return(true)
      end

      it 'returns true for player 1' do
        over = game.game_over?
        expect(over).to be true
      end

      it 'returns true for player 2' do
        game.instance_variable_set(:@current_player, 2)
        over = game.game_over?
        expect(over).to be true
      end
    end

    context 'vertical win' do
      before do
        allow(game).to receive(:check_horizontal).and_return(false)
        allow(game).to receive(:check_vertical).and_return(true)
      end

      it 'returns true for player 1' do
        over = game.game_over?
        expect(over).to be true
      end

      it 'returns true for player 2' do
        game.instance_variable_set(:@current_player, 2)
        over = game.game_over?
        expect(over).to be true
      end
    end

    context 'diagonal win' do
      before do
        allow(game).to receive(:check_horizontal).and_return(false)
        allow(game).to receive(:check_vertical).and_return(false)
        allow(game).to receive(:check_diagonals).and_return(true)
      end

      it 'returns true for player 1' do
        over = game.game_over?
        expect(over).to be true
      end

      it 'returns true for player 2' do
        game.instance_variable_set(:@current_player, 2)
        over = game.game_over?
        expect(over).to be true
      end
    end
  end
end