# This script was written for the advent of code 2023 day 3.
# https://adventofcode.com/2023/day/3
# 
# Solution by: https://www.reddit.com/r/adventofcode/comments/189m3qw/2023_day_3_solutions/kbtqifk/
#

require 'uri'
require 'net/http'
require 'strscan'

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
    first_test_input = "467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598.."
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
    engine = input.lines.map(&:strip)
    engine.unshift '.' * engine[0].length
    engine.push '.' * engine[0].length
    engine.each.each_with_index do |line, idx|
      engine[idx] = '.' + line + '.'
    end
    
    good_parts = []
    engine.each_with_index do |line, idx|
      # determine all engine part numbers and their position in the line
      positions = line.enum_for(:scan, /[0-9]+/).map { [Regexp.last_match.to_s, Regexp.last_match.begin(0)] }
      
      positions.each do |part_num, position|
        c = ''
        c << engine[idx - 1].slice(position - 1..position + part_num.length)
        c << line[position - 1]
        c << line[position + part_num.length]
        c << engine[idx + 1].slice(position - 1..position + part_num.length)
        good_parts.push part_num.to_i if not c.scan(/[^\.]/).empty?
      end
    end
    
    good_parts.sum
  end

  def solve_second(input)
    engine = input.lines.map(&:strip)
    engine.unshift '.' * engine[0].length
    engine.push '.' * engine[0].length
    engine.each.each_with_index do |line, idx|
      engine[idx] = '.' + line + '.'
    end
    
    gear = {}
    engine.each_with_index do |line, idx|
      positions = line.enum_for(:scan, /[0-9]+/).map { [Regexp.last_match.to_s, Regexp.last_match.begin(0)] }
      
      positions.each do |part_num, position|
        c = ''
        (idx - 1..idx + 1).each do |i|
          c << engine[i].slice(position - 1..position + part_num.length)
        end
        gears = c.enum_for(:scan, /\*/).map { [Regexp.last_match.to_s, Regexp.last_match.begin(0)] }
        gears.each do |g|
          l = idx + (g[1]/(part_num.length+2)-1)
          p = position + (g[1]%(part_num.length+2)-1)
          k = "#{l.to_s+','+p.to_s}"
          gear[k] ||= []
          gear[k] << part_num.to_i
        end
      end
    end
    
    ratio = 0
    gear.each do |k, v|
      if v.length == 2
        ratio += v[0] * v[1]
      end
    end
    
    ratio
  end
end

s = Solver.new(day = 3)
s.test_case
puts ""
s.decipher
