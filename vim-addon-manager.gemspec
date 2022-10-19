require './lib/vim/addon_manager/version.rb'

Gem::Specification.new do |s|
  s.name        = 'vim-addon-manager'
  s.version     = Vim::AddonManager::VERSION
  s.summary = "Extension manager for the Vim text editor"
  s.description = "vim-addon-manager lets you install, remove and upgrade
extension for the Vim text editor. Those extensions can be obtained from system
directories or from the internet."
  s.authors     = `git log --format=%aN | sort | uniq -c | sort -n -r  | sed -e 's/\\s*[0-9]\\+\\s*//'`.lines.map(&:strip)
  s.email       = 'terceiro@softwarelivre.org'
  s.files       = Dir.glob('**/*')
  s.homepage    = 'http://rubygems.org/gems/vim-addon-manager'
end
