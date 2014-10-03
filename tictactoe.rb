class Player
  attr_accessor :name, :mark, :order_player
  def initialize(name, mark, order)
    @name = name
    @order_player = order #player1, player2 etc
    @mark = mark #symbol player chooses to mark his cells
  end
end

class Cell
  attr_accessor :marked_by_player
  def initialize
    @marked_by_player = nil
  end
end

class Game
  attr_reader :board
  def initialize(player1, player2)
    #@board = Array.new(3, Array.new(3, nil)) #create a 3x3 matrix initialized with nil
    @board = [Array.new(3, nil), Array.new(3, nil), Array.new(3, nil)]
#    @board.each {|r| 3.times{|t| @board[t-1].push(nil)}}
#    @board = [[nil, nil, nil], [nil, nil, nil], [nil, nil, nil]]
    @player1 = player1
    @player2 = player2
  end  

  def display_board
    puts "\n    0   1   2 "
    @board.each_with_index do |row, r_index|  
      print r_index.to_s + ": "
      row.each_with_index do |cell, i|
        cell.nil? ? print("  "): print(" " + cell.marked_by_player.mark)
        print " |" if i < 2
      end
      puts "\n   ---|---|---" unless r_index == 2
    end
    puts
  end

  def mark_position(x, y, player)
    cell = Cell.new
    cell.marked_by_player = player
    board[x][y] = cell
  end
  
  def check_rows
    @board.each do |row|
      next if row.any? {|c| c.nil?}
      value = row[0].marked_by_player.mark
      return row[0].marked_by_player.name if (row.all? {|r| r.marked_by_player.mark == value})
    end
    nil
  end

  def check_columns
    prev_cell = nil
    @board[0].length.times do |column| 
      @board.each do |row|
        prev_cell ||= row[column-1]
        if (row[column-1].nil? || (row[column-1].marked_by_player.mark != prev_cell.marked_by_player.mark))
          prev_cell = nil
          break
        end
        prev_cell = row[column-1]
      end
      return prev_cell.marked_by_player.name if !prev_cell.nil?
    end
    nil
  end

  def check_diag1
    prev_cell = nil
    @board.each_with_index do |row, index_row|
      row.each_with_index do |cell, index_column|
        if ((index_row + index_column) == (@board[0].length - 1))
          prev_cell ||= cell
          return nil if (cell.nil? || (cell.marked_by_player.mark != prev_cell.marked_by_player.mark))
          prev_cell = cell
        end
      end
    end
    return prev_cell.marked_by_player.name
  end

  def check_diag2
    prev_cell = nil
    @board.each_with_index do |row, index_row|
      row.each_with_index do |cell, index_column|
        if (index_row == index_column)
          prev_cell ||= cell
          return nil if (cell.nil? || (cell.marked_by_player.mark != prev_cell.marked_by_player.mark))
          prev_cell = cell
        end
      end
    end
    return prev_cell.marked_by_player.name
  end

  def check_win
    return (check_rows || check_columns || check_diag1 || check_diag2)
  end

end

def player_turn(player, game)
  puts "\n#{player.order_player} '#{player.name}' turn"
  puts "choose column number"
  col = gets.chomp.to_i
  puts "choose row number"
  row = gets.chomp.to_i
  game.mark_position(row, col, player)
  game.display_board
  winner = game.check_win
  if !winner.nil?
    puts("\n#{player.order_player}: " + winner + " won the game\n")
    return true
  end
  nil
end

def menu
  puts "Name of player1:"
  name_p1 = gets.chomp
  puts "Name of player2:"
  name_p2 = gets.chomp
  pl1 = Player.new(name_p1, "O", "player1")
  pl2 = Player.new(name_p2, "X", "player2")
  g = Game.new(pl1, pl2)
  turns = 9
  g.display_board
  loop do
    break if player_turn(pl1, g)
    turns -= 1
    break if turns == 0
    break if player_turn(pl2, g)
    turns -= 1
    break if turns == 0
  end
  puts "\nThe game ended in a tie\n" if turns == 0
end

menu
