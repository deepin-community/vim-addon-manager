require 'spec_helper'
describe Vim::AddonManager::Addon::Legacy do

  it 'should have a :unavailable status if it misses files' do
    expect(addon('missingfiles').status(target_dir.path).status).to eq(:unavailable)
  end

  it 'should have a :broken status if files are removed in the target dir' do
    addon_manager.install addons('foo')
    target_dir.rm('syntax/foo.vim')
    expect(addon('foo').status(target_dir.path).status).to eq(:broken)
  end

  it 'should have a :not_installed status by default' do
    expect(addon('foo').status(target_dir.path).status).to eq(:not_installed)
  end

  it 'should have a :installed status after being installed' do
    addon_manager.install addons('foo')
    expect(addon('foo').status(target_dir.path).status).to eq(:installed)
  end

  it 'go back to :not_installed after being removed' do
    addon_manager.install addons('foo')
    addon_manager.remove addons('foo')
    expect(addon('foo').status(target_dir.path).status).to eq(:not_installed)
  end

end
