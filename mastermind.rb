class ComputerPlayer
 # attr_accessor :choice_values
  def initialize
    @choice_values = (1..8).to_a
    @good_choice = nil #store a guess with 0 to 3 right elements
    @good_choice_index = 0
    @good_guess = nil
    @index_current = 0
    @index_next = 1
  end

  def all_elem_dif_positions(new_guess, prev_guess)
    if !(prev_guess.nil? || new_guess.nil?)
      prev_guess.each_with_index do |e, i|
        return false if e == new_guess[i]
      end
    end
    true
  end

  def guess
    return @choice_values.sample(4)
  end

  def next_guess(results, prev_guess)
   
    right_color_pos = results[0]
    right_color = results[1]
    if ((right_color_pos + right_color == 0) && @good_choice_index == 0) #guess with no matches
      prev_guess.each {|k| @choice_values.delete(k)}
      return guess
    elsif ((right_color_pos + right_color == 0) && @good_choice_index.between?(1,3))
      #run this code when good_choice has been set and we are looking for its elements that don't belong to the secret key and eliminate them from choice_values
      @choice_values.delete(prev_guess[0])
      value = @good_choice[@good_choice_index]
      @good_choice_index += 1
      return [value, value, value, value]
    elsif (right_color_pos + right_color == 4)
      if (@choice_values.length > 4)
        aux = @choice_values.clone
        aux.each {|val| @choice_values.delete(val) if !prev_guess.include?(val)}
      end
      if (right_color_pos < 2)
        new_guess = guess
        while !all_elem_dif_positions(new_guess, prev_guess) do
          new_guess = guess
        end
        return new_guess  
      elsif ((@index_next < 4) && (@index_current < 4))
        @good_guess ||= prev_guess
        new_guess = @good_guess.clone
        new_guess[@index_current], new_guess[@index_next] = @good_guess[@index_next], @good_guess[@index_current]
        @index_next += 1
        if (@index_next > 3)
          @index_current += 1
          @index_next = @index_current + 1;
        end
        return new_guess
      else
        return guess
      end
    elsif (right_color_pos + right_color < 4)
      if (@good_choice_index < 4)
        @good_choice ||= prev_guess.clone
        value = @good_choice[@good_choice_index]
        @good_choice_index += 1
        return [value, value, value, value]
      else
        @good_choice_index = 0
        @good_choice = nil
      end
      return guess
    end
  end
end

class Game
  attr_reader :combination
  def initialize(comb=nil)
    comb ? @combination = comb : @combination = (1..9).to_a.sample(4)
  end  

  #check how many colors and positions we have guessed right.
  #works for combinations with repeated elements
  def check_comb(guess)
    right_color_and_pos = 0
    guess_minus_rights = guess.clone #could be guess.dup
    comb_minus_rights = @combination.clone
    @combination.each_with_index do |color, index|
      if ((color - guess[index]) == 0)
        guess_minus_rights[index] = 0
        comb_minus_rights[index] = 0
        right_color_and_pos += 1
      end
    end
    right_color = 0
    comb_minus_rights.each_with_index do |color, index|
      if (color != 0)
        i = guess_minus_rights.index(color)
        if !i.nil?
          guess_minus_rights[i] = 0
          right_color += 1
        end
      end
    end
    puts "right_color_and_pos " + right_color_and_pos.to_s
    puts "right_color " + right_color.to_s
    return [right_color_and_pos, right_color]
  end

end

def menu
  
  turns = 40
  puts "Choose game mode:"
  puts "1 - Computer chooses secret key - human guesses key"
  puts "2 - Human chooses secret key - computer guesses key"
  choice = gets.chomp
  if choice == "1"
    g = Game.new
    loop do  
      puts "\nEnter a guess:"
      guess = gets.chomp.split('')
      guess.map! {|v| v.to_i}
      results = g.check_comb(guess)
      break if results[0] == 4
      break if turns == 0
      turns -= 1
    end
    puts "\nYou couldn't guess the combination\n" if turns == 0
    puts "\nCongratulations you guessed the combination\n" if turns > 0
  else
    puts "\nEnter the secret combination (no repeated values, please):"
    comb = gets.chomp.split('')
    comb.map! {|v| v.to_i}
    g = Game.new(comb)
    pc_player = ComputerPlayer.new
    guess = pc_player.guess
    loop do   
    
      puts "\nMy guess: " + guess.inspect
    #  puts "Choices: " + pc_player.choice_values.inspect
    #  puts "Good Choices: " + pc_player.good_choice.inspect
    #  puts "Good Choices index: " + pc_player.good_choice_index.to_s
      results = g.check_comb(guess)
      break if results[0] == 4
      break if turns == 0
      turns -= 1
      guess = pc_player.next_guess(results, guess)
    end
    puts "\nComputer couldn't guess the combination\n" if turns == 0
    puts "\nComputer guessed the combination in #{(40-turns).to_s} turns\n" if turns > 0
  end
end

menu

