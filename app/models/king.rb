class King < Piece
  attr_accessor :current_position, :moved, :checked

  def initialize(color, current_position)
    # Calls the superclass constructor
    super(color, current_position)
    @checked = false
    @moved = false
  end

  # Returns the unicode symbol for the piece
  def to_s
    color == :white ? "♚" : "♔"
  end

  # Moves the piece to a new position, updating the board state
  def move_to(new_position, board_state)
    return false unless valid_moves(board_state).include?(new_position)

    if can_castle?(new_position, board_state)
      do_castle(new_position, board_state)
    else
      board_state[new_position[0]][new_position[1]] = self
      board_state[current_position[0]][current_position[1]] = nil

      @current_position = new_position
      @moved = true
    end
  end

  # Returns an array of valid moves for the piece
  def valid_moves(board_state)
    valid_moves = []

    king_moves = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]]
    king_moves.each do |move|
      x = current_position[0] + move[0]
      y = current_position[1] + move[1]

      if x.between?(0, 7) && y.between?(0, 7) && (!board_state[x][y] || board_state[x][y].color != color)
        valid_moves << [x, y]
      end
    end
    valid_moves.concat(castle_moves(board_state)) if !@moved && !@checked
    valid_moves
  end

  private

  # Determines if the king can perform castling to a specified new position
  def can_castle?(new_position, board_state)
    return false if @moved || @checked

    direction = new_position[1] - current_position[1] > 0 ? 1 : -1
    path_clear = (1..2).all? do |square|
      col_square = current_position[1] + direction * square
      board_state[current_position[0]][col_square].nil?
    end

    rook_position = direction > 0 ? 7 : 0
    rook = board_state[current_position[0]][rook_position]
    rook && !rook.moved && path_clear
  end

  # Calculates the potential moves available to the king if castling is an option
  def castle_moves(board_state)
    castling_moves = []

    if can_castle?([current_position[0], current_position[1] + 2], board_state)
      castling_moves << [current_position[0], current_position[1] + 2]
    end

    if can_castle?([current_position[0], current_position[1] - 2], board_state)
      castling_moves << [current_position[0], current_position[1] - 2]
    end

    castling_moves
  end

  # Executes the castling move by updating the positions of the king and the involved rook.
  def do_castle(new_position, board_state)
    rook_column = new_position[1] == 6 ? 7 : 0
    rook_new_column = new_position[1] == 6 ? 5 : 3
    rook_row =current_position[0]

    board_state[current_position[0]][current_position[1]] = nil
    board_state[new_position[0]][new_position[1]] = self
    @current_position = new_position
    @moved = true

    rook = board_state[rook_row][rook_column]
    board_state[rook_row][rook_column] = nil
    board_state[rook_row][rook_new_column] = rook
    rook.current_position = [rook_row, rook_new_column]
    rook.moved = true
  end
end
