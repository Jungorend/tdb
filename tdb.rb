#!/usr/bin/ruby

# Main Entry Point to the program. All the options
# are access through the menu.


require_relative 'src/Information'
require_relative 'src/SqlHandling'
require_relative 'src/AlterDatabase'
require_relative 'src/Configuration'
require_relative 'src/Input'
require_relative 'src/Initializer'

Initializer.do_your_thing

Input.init do

  SqlHandling.initialize

  while true
    input = Input.read_input
    input.chomp!
    case input
      when /^[qQ]$/
        Configuration.clear_output_directory
        exit
      when /^[rR] (\d+) (\d+)$/
        SqlHandling.random_selection($1.to_i, $2.to_i)
      when /^\?$/
        Information.help
	    when /^(\d)$/
	      Information.list_all($1)
      when /^([a-z])$/
        AlterDatabase.command($1)
      when /^c\s+(.*)/
        values = SqlHandling.run_sql_statement($1)
        Configuration.copy_media(values) unless values == []
      else
        values = SqlHandling.run_sql_statement(input)
	      Configuration.view_media(values) unless values == []
    end
  end
end
