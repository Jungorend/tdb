require_relative 'SqlHandling'
require 'yaml'
require 'fileutils'

module Configuration
  @configuration = Hash.new

  directory = File.dirname(__FILE__)
  @configuration = YAML::load(File.open( "#{directory}/../config.yml" ))

  if @configuration['base directory'].nil?
    @configuration['base directory'] = Dir.pwd
  end

  # From here everything is automatic
  if @configuration['internal structure']
    @configuration['output directory'] = @configuration['base directory'] + '/' + @configuration['output directory']
    @configuration['database directory'] = @configuration['base directory'] + '/' + @configuration['database directory']
    @configuration['database location'] = @configuration['base directory'] + '/' + @configuration['database location']
    @configuration['new files'] = @configuration['base directory'] + '/' + @configuration['new files']
    @configuration['deleted directory'] = @configuration['base directory'] + '/' + @configuration['deleted directory']
    @configuration['potential duplicates'] = @configuration['base directory'] + '/' + @configuration['potential duplicates']
  end

  if @configuration['windows']
    require 'win32ole'
    include Win32
  end

  def self.config
    @configuration
  end

  def self.create_shortcut(source, destination)
    if @configuration['windows']
      destination = destination + '.lnk'
      shortcut = WIN32OLE.new('WScript.Shell').CreateShortcut(destination)
      shortcut.TargetPath = source
      shortcut.WindowStyle = 1 # SHOWNORMAL
      shortcut.save
    else
      File.symlink(source, destination)
    end
  end

  def self.copy_media(media)
    media.each do |image|
      FileUtils::cp "#{@configuration['database directory']}/#{image[0]}", "#{@configuration['output directory']}/#{image[0]}"
    end
  end

  def self.generate_files(a)
    SqlHandling.generate_files(a)
  end

  def self.clear_output_directory
    FileUtils::rm_rf Dir.glob("#{@configuration['output directory']}/*")
  end

  def self.view_media(a)
    Configuration.generate_files(a).to_s[2..-3].split('.')[-1]
    if @configuration['windows']
      command = "#{@configuration['media viewer']} #{@configuration['output directory']}/0.lnk"
      command.gsub!(/\//, "\\")
    else
      command = "#{@configuration['media viewer']} #{@configuration['output directory']}/0"
    end
    spawn(command)
  end
end
