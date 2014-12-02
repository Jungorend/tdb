require_relative 'SqlHandling'
require 'yaml'
require 'fileutils'

module Configuration
  @configuration = Hash.new

  @configuration = YAML::load(File.open( 'config.yml' ))


  # From here everything is automatic
  if @configuration["internal structure"]
    @configuration["output directory"] = @configuration["base directory"] + "/" + @configuration["output directory"]
    @configuration["database directory"] = @configuration["base directory"] + "/" + @configuration["database directory"]
    @configuration["database location"] = @configuration["base directory"] + "/" + @configuration["database location"]
    @configuration["new files"] = @configuration["base directory"] + "/" + @configuration["new files"]
  end

  if @configuration["windows"]
    require_relative 'FileHandling'
  end

  def self.config
    @configuration
  end

  def self.create_shortcut(source, destination)
    if @configuration["windows"]
      FileHandling.create_shortcut(source, destination)
    else
      File.symlink(source, destination)
    end
  end

  def self.copy_media(media)
    media.each do |image|
      FileUtils::cp "#{@configuration["database directory"]}/#{image[0]}", "#{@configuration["output directory"]}/#{image[0]}"
    end
  end

  def self.generate_files(a)
    SqlHandling.generate_files(a)
  end

  def self.view_media(a)
    Configuration.listen_to_music(a)
  end


  def self.listen_to_music(music)
    Configuration.generate_files(music).to_s[2..-3].split(".")[-1]
    first_to_view = "0.lnk"
    if @windows 
      command = "\"#{@configuration["media viewer"]}\" #{@configuration["output directory"]}/0.lnk"
      command.gsub!(/\//, "\\")
    else
      command = "#{@configuration["media viewer"]} #{@configuration["output directory"]}/0"
    end
    spawn(command)
  end
end
