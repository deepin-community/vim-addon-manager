require 'spec_helper'

describe Vim::AddonManager do

  it 'installs addons' do
    addon_manager.install addons('foo')
    expect(target_dir).to have_file('syntax/foo.vim')
  end

  it 'installs multiple addons at once' do
    addon_manager.install addons('foo', 'bar')
    expect(target_dir).to have_file('syntax/foo.vim')
    expect(target_dir).to have_file('syntax/bar.vim')
  end

  it 'removes addons' do
    addon_manager.install addons('foo')
    addon_manager.remove addons('foo')
    expect(target_dir).to_not have_file('syntax/foo.vim')
  end

  it 'fixes broken addons after they are upgraded to the new style' do
    Dir.chdir target_dir.path do
      FileUtils.mkdir_p 'syntax'
      FileUtils.ln_s '/non/existing/path', 'syntax/newstylemigrated.vim'
    end
    addon_manager.upgrade_from_legacy(registry.to_a)

    expect(target_dir).to_not have_symlink('syntax/newstylemigrated.vim')
    expect(target_dir).to have_file('vam/newstylemigrated/syntax/newstylemigrated.vim')
  end

  it 'disables addons' do
    addon_list = addons('foo')
    addon_manager.install(addon_list)
    addon_manager.disable(addon_list)

    output = File.readlines(override_file).map(&:strip)
    expect(output).to include(addon_list.first.disabled_by_line)
  end

  it 're-enables addons' do
    addon_list = addons('foo')
    addon_manager.install(addon_list)
    addon_manager.disable(addon_list)
    expect(File.exists?(override_file)).to eq(true)

    addon_manager.enable(addon_list)
    expect(File.exists?(override_file)).to eq(false)
  end

end
