require 'spec_helper'

describe Vim::AddonManager::Registry do

  before do
    @registry = Vim::AddonManager::Registry.new(FAKE_REGISTRY, FAKE_SCRIPTS)
  end

  it 'finds all addons in a directory' do
    list = []; @registry.each { |a| list << a.name }
    expect(list).to include('foo')
    expect(list).to include('bar')
  end

end
