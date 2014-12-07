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
    previous_tab = 0 # This checks whether the last button pressed was tab
    tab_uncompleted_word = "" # This is the word prior to a full tab
    pointer = @history.length - 1
    @message = message + '>'
    Curses.addstr("#{@message} ")
    result = ''
    until result.include? "\n" or result.include? "\r"
      character = Curses.getch
      if character.ord == 9 # Tab
        previous_tab -= 1
        if previous_tab == -1
          word = autocomplete(result.split[-1])
        else
          word = autocomplete(tab_uncompleted_word)
        end
        result = result.split[0..-2].join(' ')
        if word.nil? or word[previous_tab].nil?
          result = result
        elsif result == ''
          result = word[previous_tab] + ' '
        else
          result = result + ' ' + word[previous_tab] + ' '
        end
      elsif character.ord == 8 or character.ord == 263 # Backspace // 263 is Backspace in the curses.h special function keys
        previous_tab = 0
        result.chop!
        tab_uncompleted_word = result
      elsif character.ord == Curses::KEY_UP
        previous_tab = 0
        result = @history[pointer]
        tab_uncompleted_word = result
        pointer -= 1
      elsif character.ord == Curses::KEY_DOWN
        previous_tab = 0
        if @history[pointer+1]
          result = @history[pointer+1]
          tab_uncompleted_word = result
          pointer += 1
        end
      else
        previous_tab = 0
        result << character
        tab_uncompleted_word = result
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

  def self.puts(message)
    Curses.addstr(message + "\n")
    @y += 1
    @x = 0
  end

  def self.autocomplete(result)
    tags = add_to_tags(SqlHandling.get_all_tags)
    out = Array.new
    tags.each do |tag|
      if tag[0] =~ /^#{result}.*/
        out << "#{tag[0]} "
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
