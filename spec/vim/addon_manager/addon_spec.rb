require 'spec_helper'

describe Vim::AddonManager::Addon do

  it 'should build legacy addon objects if files attribute is specified' do
    expect(addon('foo')).to be_a(Vim::AddonManager::Addon::Legacy)
  end

  it 'should build new style addon objects if files attribute is not specified' do
    expect(addon('newstyle')).to be_a(Vim::AddonManager::Addon::Directory)
  end

end
