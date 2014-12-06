require_relative 'SqlHandling'
require 'curses'

module Input
  def self.init
    @x, @y = 0 ,0
    @message='>'
    Curses.noecho
    Curses.cbreak
    Curses.curs_set(0)
    Curses.setpos(@y, @x)
    Curses.stdscr.keypad(true)
    Curses.init_screen
    @history = []
    begin
      yield
    ensure
      Curses.close_screen
    end
  end

  def self.read_input(message='TDB')
    pointer = @history.length - 1
    @message = message + '>'
    Curses.addstr("#{@message} ")
    result = ''
    until result.include? "\n" or result.include? "\r"
      character = Curses.getch
      if character.ord == 9 # Tab
        word = autocomplete(result.split[-1])
        result = result.split[0..-2].join(' ')
        if result == ''
          if word == ''
            result = ''
          else
            result = word + ' '
          end
        else
          result = result + ' ' + word + ' '
        end
      elsif character.ord == 8 or character.ord == 263 # Backspace // 263 is Backspace in the curses.h special function keys
        result.chop!
      elsif character.ord == Curses::KEY_UP
        result = @history[pointer]
        pointer -= 1
      elsif character.ord == Curses::KEY_DOWN
        if @history[pointer+1]
          result = @history[pointer+1]
          pointer += 1
        end
      else
        result << character
      end
      Curses.clrtoeol
      Curses.setpos(@y, 0)
      string = @message + result
      string.gsub!(/\s+/, ' ')
      Curses.addstr(string+"\n")
      @x = string.length
    end
    @history << result
    @y += 1
    result
  end

  def self.autocomplete(result)
    tags = add_to_tags(SqlHandling.get_all_tags)
    out = ''
    tags.each do |tag|
      if tag[0] =~ /^#{result}.*/
        out = tag[0] + ' '
      end
    end
    out
  end

  def self.add_to_tags(tags)
    tags.concat([['others'],['only'],['not'],['or']]).concat(SqlHandling.provide_special_english)
  end

  def self.print_as_table(values)
    values.each { |x| x.compact! }
    table_values = count_occurrences(values)
    sum = 0
    table_values.sort_by { |k, v| k }.each do |index, amount|
      printf "%12s(%3s)", index.to_s[2..-3], amount
      sum += 1
      if sum % 4 == 0
        print "\n"
      end
    end
    reset
  end

  def self.new_menu(information)
    Curses.clear
    @x, @y = 0, 0
    Curses.setpos(@x, @y)

    information.each do |line|
      Curses.addstr(line + "\n")
      @y = 0
      @x += 1
      Curses.setpos(@x, @y)
    end
    reset
  end

  def self.reset
    Curses.getch
    Curses.clear
    @x, @y = 0, 0
    Curses.setpos(@x, @y)
  end

  def self.count_occurrences(array)
    values_and_counts = Hash.new(0)
    array.each do |x|
      values_and_counts[x] += 1
    end
    return values_and_counts
  end
end
