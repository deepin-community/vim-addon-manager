require 'spec_helper'

describe Vim::AddonManager::Addon::Directory do

  it 'report status as :not_installed by default' do
    expect(addon('newstyle').status(target_dir).status).to eq(:not_installed)
  end

  it 'lists files inside the directory' do
    addon = addon('newstyle')
    expect(addon).to receive(:basedir).and_return(File.join(FAKE_SCRIPTS)).at_least(:once)

    expect(addon.files).to include('vam/newstyle/ftplugin/newstyle.vim')
    expect(addon.files).to include('vam/newstyle/syntax/newstyle.vim')
  end

  it 'constructs source with basedir by default' do
    addon = addon('newstyle')
    expect(addon).to receive(:basedir).and_return('/base/dir').at_least(:once)

    expect(addon.directory).to be_nil
    expect(addon.send(:source)).to eq('/base/dir/vam/newstyle')
  end

  it 'uses directory as source if specified' do
    addon = addon('newstylewithdir')
    expect(addon.directory).to eq('/path/to/newstylewithdir')
    expect(addon.send(:source)).to eq('/path/to/newstylewithdir')
  end

  context 'when installed' do
    before do
      @addon = addon('newstyle')
      @addon.install(target_dir)
    end

    it 'installs symlink into ~/.vim/vam/' do
      expect(Dir.glob(File.join(target_dir.path, 'vam', 'newstyle'))).to_not be_empty
    end

    it 'points to the source directory' do
      expect(File.readlink(File.join(target_dir.path, 'vam', 'newstyle'))).to eq(@addon.send(:source))
    end

    it 'reports status as :installed' do
      expect(@addon.status(target_dir).status).to eq(:installed)
    end

    context 'and removed' do

      before do
        @addon.remove(target_dir)
      end

      it 'reports status as :not_installed' do
        expect(@addon.status(target_dir.path).status).to eq(:not_installed)
      end

      it 'removes symlink from ~/.vim/vam/' do
        expect(Dir.glob(File.join(target_dir.path, 'vam', 'newstyle'))).to be_empty
      end

    end
  end

end
