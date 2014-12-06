require_relative 'Configuration'
require 'sqlite3'

module Initializer
  @config = Configuration.config

  def self.create_new_database
    @database = SQLite3::Database.new("#{@config['database location']}")
    @database.execute('PRAGMA foreign_keys = on')

    schema = [
      'create table files (filename primary key);',
      'create table tags (tagname, type, primary key (tagname, type));',
      'create table filetags (filename, tagname, type,
                            unique (filename, tagname, type),
                            foreign key (filename) references files(filename),
                            foreign key (tagname, type) references tags (tagname, type));',
      'create table ignored_english ( word primary key );',
      'create table parsed_english (word primary key, replacement_word, type,
                            foreign key (replacement_word, type) references tags(tagname, type));'
    ]
    
    begin
      schema.each do |statement|
        results = @database.execute(statement)
      end
    rescue
      exit
    end
  end
end
