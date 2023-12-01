# This script was written for the advent of code 2023 day 1.
# https://adventofcode.com/2023/day/1

require 'uri'
require 'net/http'

class Solver
  def initialize(day, year = 2023)
    @day = day
    @year = year
  end

  def decipher
    fetch_input
    first_answer = solve_first(@input)
    puts "the first answer is: #{first_answer}"
    second_answer = solve_second(@input)
    puts "the second answer is: #{second_answer}"
  end

  def fetch_input
    filename = 'cookie.txt'
    unless File.exist?(filename)
      abort('"cookie.txt" is required to get the puzzle input for your account.')
    end

    file = File.open(filename)

    uri = URI("https://adventofcode.com/#{@year}/day/#{@day}/input")
    cookie_value = file.read.chomp
    user_agent = 'github.com/naturaln0va/aoc2022 by Ryan Ackermann'
    headers = { 'Cookie' => "session=#{cookie_value}", 'User-Agent' => user_agent }
    
    file.close

    puts "fetching the puzzle input for day #{@day}..."
    res = Net::HTTP.get_response(uri, headers)

    unless res.is_a?(Net::HTTPSuccess)
      abort(res.body)
    end
    
    @input = res.body
  end

  def test_case
    test_input = "1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet"
    first_answer = solve_first(test_input) # 142
    puts "the first test answer is: #{first_answer}"
    second_test_input = "two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    eighthree5sevenine"
    second_answer = solve_second(second_test_input)
    puts "the second test answer is: #{second_answer}"
  end

  def solve_first(input)
    lines = input.lines.map(&:strip)
    numbers = lines.map do |line|
      nums = line.split('').map { |s| s.to_i }.select { |e| e.nonzero? }
      [nums.first, nums.last].map { |n| n.to_s }.join.to_i
    end
    numbers.sum
  end

  def solve_second(input)
    lines = input.lines.map(&:strip)
    numbers = []
    for line in lines do
      nums = get_nums_in(line)
      puts nums.join
      # if nums.length == 1
      #   numbers << nums.first
      # else
      #   numbers << [nums.first, nums.last].map { |n| n.to_s }.join.to_i 
      # end
      numbers << [nums.first, nums.last].map { |n| n.to_s }.join.to_i 
    end
    # puts numbers
    numbers.sum
  end
  
  def get_nums_in(line)
    word_nums = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    mut = line
    nums = []
    while not mut.empty? do
      if mut.chr.to_i > 0
        nums << mut.chr.to_i
        mut.slice!(0)
      else
        did_find = false
        word_nums.each_with_index do |element, index|
          if mut.start_with?(element)
            nums << index + 1
            mut.slice!(0..element.length-2)
            did_find = true
            break
          end
        end
        if not did_find
          mut.slice!(0)
        end
      end
    end
    nums
  end
end

s = Solver.new(day = 1)
s.decipher
s.test_case
