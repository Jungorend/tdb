require 'fileutils'
require_relative 'Configuration'
require 'sqlite3'

module SqlHandling
  @config = Configuration.config
  @convert_dir = Dir.pwd + "/" + "to convert"
  $table = "filetags"
  $filename = "filename"

  unless File.exists? @config["database location"]
    require_relative 'Initializer'
    Initializer.create_new_database
  end

  $database = SQLite3::Database.new("#{@config["database location"]}")
  $database.execute("PRAGMA foreign_keys = on")

  # The parser variables
  $english_to_delete = Array.new
  $english_to_parse = Hash.new

  def self.update_parser
    begin
      $english_to_delete = $database.execute("SELECT word FROM ignored_english")
      $english_to_delete.map! { |x| x[0] }

      results = $database.execute("SELECT word, replacement_word FROM parsed_english")
      results.each do |record|
        $english_to_parse[record[0]] = record[1]
      end
    rescue
      exit
    end
  end

  def self.provide_special_english
    result = Array.new
    $english_to_parse.keys.each do |x|
      result << [x]
    end

    $english_to_delete.each do |x|
      result << [x]
    end
    result
  end

  def self.generate_files(filenames)
    delete_watch_directory
    filenames.shuffle!
    filenames.each_with_index do |x, index|
      x = x.to_s[2..-3]
      Configuration.create_shortcut("#{@config["database directory"]}/#{x}", "#{@config["output directory"]}/#{index}")
    end
    return filenames[0]
  end

  def self.delete_watch_directory
    FileUtils.rm_rf(Dir.glob("#{@config["output directory"]}/*"))
  end

  # This section is for selecting files

  def self.adjust_modifiers(statement)
    statement.split.each_with_index.map do |token, index|
      result = token
      
      if index >= 1 and statement.split[index - 1].casecmp("NOT") == 0
        result = "NOT #{token}"
      end

      if index >= 1 and statement.split[index - 1].casecmp("ONLY") == 0
        result = "ONLY #{token}"
      end

      if index + 1 < statement.split.length and statement.split[index + 1].casecmp("OTHERS") == 0
        result = "OTHERS #{token}"
      end

      result
    end.delete_if do |token|
      token =~ /^not$|^others$|^only$/i
    end
  end

  def self.tokenize( word )
    "\"#{word}\""
  end

  def self.split_or_statements( statement ) 
    statement.split(/ or /i)
  end


  def self.parse_english(sql_statement)
    tokens = sql_statement.split()
    tokens.delete_if { |token| $english_to_delete.include? token }
    result = ""
    while tokens.any?
    token = tokens.shift
      if $english_to_parse.include? token
        result += $english_to_parse[token] + " "
      elsif token =~ /^or$/
        result += "#{token} "
      elsif token =~ /[\(\)]/
        result += "#{token} "
      else
        result += "#{token} "
      end
    end
    result
  end

  def self.parse(statement)
    split_or_statements(parse_english(statement)).map do |sub_statement|
      adjust_modifiers( sub_statement )
    end
  end

  def self.get_type(tagname)
    statement = "SELECT type from tags WHERE tagname='#{tagname}'"
    begin
      $database.execute(statement)[0][0]
    rescue
      'Type not found'
    end
  end

  def self.sqlize(statement)
    result = ""
    statement.each do |token|
      
      if token =~/NOT (.*)/
        result << " AND filename NOT IN (SELECT filename FROM filetags WHERE tagname = #{tokenize($1)})"
      elsif token =~ /OTHERS (.*)/
        type = get_type($1)
        if type.nil?
          puts("Unknown tag associated with OTHERS")
          Input.reset
        else
          result << " AND filename IN (SELECT filename FROM filetags WHERE tagname = #{tokenize($1)} AND filename IN (SELECT filename FROM filetags WHERE tagname != #{tokenize($1)} AND type=\"#{type}\"))"
        end
      elsif token =~ /ONLY (.*)/
        type = get_type($1)
        if type.nil?
          puts "Unknown tag associated with ONLY"
          Input.reset
        else
          result << " AND filename IN (SELECT filename FROM filetags WHERE tagname = #{tokenize($1)} AND filename NOT IN (SELECT filename FROM filetags WHERE tagname != #{tokenize($1)} AND type=\"#{type}\"))"
        end
      else
        result << " AND filename IN (SELECT filename FROM filetags WHERE tagname=#{tokenize(token)})"
      end
    end
    result.sub(")", "")[18..-1]
  end

  def self.make_sql_statement(statement) # merges substatements
    sql_statement = ""
    parse(statement).each do |sub_statement|
      sql_statement << " UNION #{sqlize(sub_statement)}"
    end
    sql_statement.sub(" UNION ", "")
  end
    


  def self.run_sql_statement(statement) # actually runs the command
    statement = make_sql_statement(statement)
    begin
      $database.execute("#{statement}")
    rescue
      puts 'Invalid command'
      []
    end
  end

  def self.show_all_types
    string = "SELECT type FROM (SELECT distinct tagname, type FROM #{$table})"
    begin
      $database.execute("#{string}")
    rescue
      puts 'database unreachable'
    end
  end

  def self.show_all_in_field(tag)
    string = "SELECT tagname FROM #{$table} WHERE type=\"#{tag}\""
    begin
      $database.execute("#{string}")
    rescue
      puts 'Invalid tag'
    end
  end

  def self.get_all_tags
    string = "SELECT * FROM tags"
    begin
      $database.execute(string)
    rescue
      puts 'Unusual Failure'
    end
  end

  def self.random_selection(lower_bound, upper_bound)
    begin
      tags = $database.execute('SELECT tagname FROM tags')
    rescue
      exit
    end
    results = []
    until results.length > lower_bound and results.length < upper_bound
      tags.shuffle!
      selection =  "#{tags[0][0]} #{tags[1][0]}"
      if rand(2) == 0
        selection = "#{tags[0][0]} #{tags[1][0]} or #{tags[2][0]} #{tags[3][0]}"
      end
      puts selection
      results = run_sql_statement(selection)
    end
    Configuration.view_media(results) unless results == []
  end

  ##For AlterDatabase commands
  def self.file_in_database?(file)
    file = "\"#{file}\""
    statement = "SELECT * FROM files WHERE #{$filename}=#{file}"
    begin
      unless $database.execute(statement) == []
        true
      end
    rescue
      nil
    end
  end

  def self.filetag_in_database?(type, tagname, file)
    statement = "SELECT * FROM filetags WHERE type=\"#{type}\" AND tagname=\"#{tagname}\" AND filename=\"#{file}\""
    begin
      unless $database.execute(statement) == []
        true
      end
    rescue
      nil
    end
  end

  def self.insert_to_database(type, tagname, file)
        puts "Updating..."
        unless file_in_database? file
          insert_into_file_table(file)
        end
        unless filetag_in_database?(type, tagname, file)
          statement = "INSERT INTO filetags (type, tagname, filename) VALUES (\"#{type}\", \"#{tagname}\", \"#{file}\")"
          begin
            $database.execute("#{statement}")
          rescue
            puts 'Probably a new category. Try again.'
            exit
          end
        end
        insert_file(type, tagname, file)
  end

  def self.get_type_from_tagname(tagname)
    statement = "SELECT DISTINCT type FROM tags WHERE tagname=\"#{tagname}\""
    begin
      $database.execute(statement)
    end
  rescue
    []
  end

  def self.update_into_database(tag, file)
    type = get_type_from_tagname(tag)
    type = type[0][0]
    unless filetag_in_database?(type, tag, file)
      statement = "INSERT INTO filetags (type, tagname, filename) VALUES (\"#{type}\", \"#{tag}\", \"#{file}\")"
      begin
        $database.execute(statement)
      rescue
        puts "Issue with inserting during update."
        exit
      end
    end
  end

  def self.insert_into_file_table(filename)
    statement = "INSERT INTO files (filename) VALUES (\"#{filename}\")"
    begin
      $database.execute(statement)
    rescue
      exit
    end
  end

  def self.add_tag(tag, type)
    statement = "INSERT INTO tags (tagname, type) VALUES (\"#{tag}\", \"#{type}\")"
    begin
      $database.execute(statement)
    rescue
      puts "error with adding new tags"
      exit
    end
  end

  def self.insert_file(type, tagname, file)
    unless File.exists? "#{@config["database directory"]}/#{file}"
      FileUtils::cp "#{@convert_dir}/#{type}/#{tagname}/#{file}", "#{@config["database directory"]}/#{file}"
    end
    FileUtils::rm("#{@convert_dir}/#{type}/#{tagname}/#{file}")
  end

  def self.remove_files(files)
    files.each do |file|
      begin
        statement = "DELETE FROM filetags WHERE #{$filename}=\"#{file}\""
        $database.execute("#{statement}")
        statement = "DELETE FROM files WHERE filename=\"#{file}\""
        $database.execute("#{statement}")
        FileUtils.rm "#{@config["database directory"]}/#{file}"
      rescue
        exit
      end
    end
  end
end

