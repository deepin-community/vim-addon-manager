require 'vim/addon_manager'
require 'vim/addon_manager/registry'
require 'tmpdir'

begin
  require 'pry'
rescue LoadError
end

FAKE_REGISTRY = File.join(File.dirname(__FILE__), 'data/registry')
FAKE_SCRIPTS  = File.join(File.dirname(__FILE__), 'data/scripts')

module VimAddonManagerSpecHelper

  class Target
    attr :path
    def initialize(path)
      @path = path
    end
    alias :to_s :path
    def has_file?(file)
      File.exists?(File.join(path, file))
    end
    def has_symlink?(file)
      File.symlink?(File.join(path, file))
    end
    def rm(file)
      FileUtils.rm(File.join(path, file))
    end
  end

  def tmpdir
    @tmpdir ||= Dir.mktmpdir
  end

  def target_dir
    @target_dir ||= Target.new(tmpdir)
  end

  def registry
    @registry ||= Vim::AddonManager::Registry.new(FAKE_REGISTRY, FAKE_SCRIPTS)
  end

  def addon(name)
    registry[name]
  end

  def addons(*addon_names)
    addon_names.map { |name| registry[name] }
  end

  def addon_manager
    @addon_manager ||= Vim::AddonManager.new(target_dir.path)
  end

  def override_file
    @override_file ||= Vim::AddonManager.override_file(target_dir.path)
  end

end

require 'rspec'
RSpec.configure do |config|
  config.before { Vim::AddonManager.logger.quiet! }
  config.after { FileUtils.rm_rf(tmpdir) }
  config.include VimAddonManagerSpecHelper
end
