#uses some values set by table type

require_relative 'SqlHandling'
require_relative 'Input'

module Information
  def self.help
    help_info = [
      "\t\t\tTDB help files",
      '=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=',
      'Primary Commands:',
      '',
  	  '? - Display this Page',
	    '1 - List all the types in the database',
	    '2 - It will ask for a type, and then provides all tags of that type in the database',
      'u - Add files to the database, provide all associated tags for the file. If you type',
      "\tjust \'q\', it will stop updating and remove the file.",
      'a - Add to the database from the \'to convert\' folder <MAY DEPRECATE>',
      'd - Remove from database everything in the to_delete folder. The files remain in the',
      "\tto_delete folder for safety.",
      'i - Create new tags for use in the database',
      'l - Add words you want to be ignored, or words you want to substitute for tags',
      'c [query] - This creates copies of all the files in the watch directory rather than',
      "\tshortcuts.",
      'q - quit',
      '[query]   - Creates shortcuts to all the files that match the query in a random order',
      "\tand calls the media viewer on them",
      '',
      'Queries',
      '=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=',
      'Built-In Functionality:',
      '',
      'only [tag] - This will take the proceeding tag and remove all files which are not of',
      "\tthat tag with the tag's type.",
      '[tag] others - This will only include files which have tag as well as other tags in',
      "\tthe same type as tag.",
      'not [tag] - This will include all files not of tag',
      'or - Connects to separate queries together and combines result',
      '',
      'Tab autocompletes words, up and down arrow keys let you choose previous queries',
      'Any words in the ignored_english table can be autocompleted and do not affect the query',
      'Any words in the parsed_english table can be substitude in place of the actual tag',
      'The only other valid input are tags'
    ]
    Input.new_menu help_info
  end
  
  def self.list_all(number)
    case number.to_i
	  when 1
	    types = SqlHandling.show_all_types
      Input.print_as_table(types)
	  when 2
      input = Input.read_input 'Enter the type'
      tags = SqlHandling.show_all_in_field(input.chomp!)
      Input.print_as_table(tags)
	  else
	    puts "#{number} is an unknown command"
	  end
  end
end
