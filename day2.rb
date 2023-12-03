# This script was written for the advent of code 2023 day 2.
# https://adventofcode.com/2023/day/2

require 'uri'
require 'net/http'

class Solver
  def initialize(day, year = 2023)
    @day = day
    @year = year
  end

  def fetch_input
    input_directory = 'input'
    unless Dir.exist? input_directory
      Dir.mkdir input_directory
    end
    
    input_file_name = "#{@year}-#{@day}-input.txt"
    input_file_path = File.join input_directory, input_file_name
    
    if File.exist? input_file_path
      input_file = File.open input_file_path
      @input = input_file.read.chomp
      input_file.close
      return
    end
    
    auth_filename = 'cookie.txt'
    unless File.exist? auth_filename
      abort('"cookie.txt" is required to get the puzzle input for your account.')
    end

    cookie_file = File.open auth_filename

    uri = URI("https://adventofcode.com/#{@year}/day/#{@day}/input")
    cookie_value = cookie_file.read.chomp
    user_agent = 'github.com/naturaln0va/aoc2023 by Ryan Ackermann'
    headers = { 'Cookie' => "session=#{cookie_value}", 'User-Agent' => user_agent }
    
    cookie_file.close

    puts "fetching the puzzle input for day #{@day}..."
    res = Net::HTTP.get_response(uri, headers)

    unless res.is_a? Net::HTTPSuccess
      abort("HTTP Error: #{res.code} - #{res.body}")
    end
    
    @input = res.body
    
    File.write(input_file_path, @input)
  end

  def test_case
    puts "===TEST==="
    first_test_input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
    first_answer = solve_first(first_test_input)
    puts "1st answer: #{first_answer}"
    second_test_input = first_test_input
    second_answer = solve_second(second_test_input)
    puts "2nd answer: #{second_answer}"
  end

  def decipher
    fetch_input
    puts "===PUZZLE==="
    first_answer = solve_first(@input)
    puts "1st answer: #{first_answer}"
    second_answer = solve_second(@input)
    puts "2nd answer: #{second_answer}"
  end

  def solve_first(input)
    lines = input.lines.map(&:strip)
    limits = {red: 12, green: 13, blue: 14}
    possible_hands = []
    for line in lines do
      comps = line.split(':')
      game_id = comps[0][5..].to_i
      hands = comps[1].split(';').map(&:strip)
      is_possible = true
      for hand in hands do
        # puts "---"
        counts = hand.split(',').map(&:strip)
        for count in counts do
          parts = count.split
          val = parts[0]
          key = parts[1]
          limit = limits[key.to_sym]
          # puts "Limit: #{limit}, for: #{key}, val: #{val}"
          if val.to_i > limit
            is_possible = false
          end
        end
      end
      possible_hands << game_id if is_possible
      # puts "---"
    end
    possible_hands.sum
  end

  def solve_second(input)
    lines = input.lines.map(&:strip)
    powers = []
    for line in lines do
      comps = line.split(':')
      game_id = comps[0][5..].to_i
      hands = comps[1].split(';').map(&:strip)
      min_vals = {red: 0, green: 0, blue: 0}
      for hand in hands do
        counts = hand.split(',').map(&:strip)
        for count in counts do
          parts = count.split
          val = parts[0].to_i
          key = parts[1].to_sym
          current_min = min_vals[key]
          current_min = val if val > current_min
          min_vals[key] = current_min
        end
      end
      power = min_vals.values.reject(&:zero?).inject(:*)
      powers << power
      # puts "Power: #{power} for: #{min_vals}"
    end
    powers.sum
  end
end

s = Solver.new(day = 2)
s.test_case
puts ""
s.decipher
