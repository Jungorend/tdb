#!/usr/bin/ruby

#this will randomize the filenames array
#and then create the files from the original
#

require_relative "src/Information"
require_relative "src/SqlHandling"
require_relative "src/AlterDatabase"
require_relative "src/Configuration"
require_relative "src/Input"

Input.init do

  SqlHandling.update_parser

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
