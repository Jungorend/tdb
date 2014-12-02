# On linux just call Linux.create_shortcut
require 'win32/shortcut'
include Win32

module FileHandler
  def self.create_shortcut(source, destination)
    Shortcut.new(destination) do |s|
      s.path = source
      s.show_cmd = Shortcut::SHOWNORMAL
    end
  end
end