require 'fileutils'
require_relative 'SqlHandling'
require_relative 'Input'
require_relative 'Configuration'

module AlterDatabase
  @config = Configuration.config
  @base_dir = Dir.pwd
  @convert_dir = "to convert"

  def self.command(input)
    case input
      when "a"
        convert_update
      when "u"
        update
      when 'i'
        insert_tags
      when "d"
        delete_from_database
      else
        puts "Not a valid command, please re-enter"
    end
  end

  #This inserts everything in the conversion folder to the db, then
  #automatically copies the files into the db folder
  def self.convert_update
    gather_type_folders.each do |type|
      gather_tagname_folders(type).each do |tagname|
        files = gather_files(tagname, type).each do |file|
          SqlHandling.insert_to_database(type, tagname, file)
        end
      end
    end
  end

  #TODO: Check if still used anywhere
  def self.list_tag
    input = Input.read_input "Enter the type"
    character = SqlHandling.show_all_in_field input.chomp!
    Input.print_as_table character
  end

  # This allows new characters and similar to be created.
  def self.insert_tags
    tag = Input.read_input "Please enter the tag"
    type = Input.read_input "Please enter the type"
    tag.chomp!
    type.chomp!
    SqlHandling.add_tag(tag, type)
  end

  #This will go through sort and allow you to add tags then add to the database
  def self.update
    files = Dir["#{@config['new files']}/*"]
    files.map! { |file| file.split("/")[-1]}
    #We have the filenames now. So for each file we need to add the tags, then
    #we need to copy it to the database and delete the original.
    files.each do |file|
      SqlHandling.insert_into_file_table(file) unless SqlHandling.file_in_database? file
      unless File.exists? "#{@config['database directory']}/#{file}"
        FileUtils::cp "#{@config['new files']}/#{file}", "#{@config['database directory']}/#{file}"
      end
      array_of_file = Array.new
      array_of_array = Array.new
      array_of_file << file
      array_of_array  << array_of_file
      Configuration.view_media(array_of_array)
      input = Input.read_input "Enter associated tags"
      input.chomp!
      if input =~ /^q$/
        SqlHandling.remove_files([file])
        break
      end
      SqlHandling.parse_english(input).split.each do |tag|
        SqlHandling.update_into_database(tag, file)
      end
      FileUtils::rm "#{@config['new files']}/#{file}"
    end
  end

  def self.gather_tagname_folders(type)
    test = Dir["#{@base_dir}/#{@convert_dir}/#{type}/*"]
    test.map! { |x| x.split("/")[-1] }
  end

  def self.gather_type_folders
    folder = Dir["#{@base_dir}/#{@convert_dir}/*"]
    folder.map! { |fol| fol.split("/")[-1] }
  end

  def self.gather_files(folder_name, type)
    files = Dir["#{@base_dir}/#{@convert_dir}/#{type}/#{folder_name}/*"]
    files.map! { |file| file.split("/")[-1]}
  end

  def self.delete_from_database
    files = Dir["#{@base_dir}/to delete/*"]
    files.map! { |file| file.split("/")[-1] }
    puts files
    SqlHandling.remove_files(files)
  end
end
