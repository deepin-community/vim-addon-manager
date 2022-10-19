require 'rbconfig'
require 'tmpdir'
ruby = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
$sources_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
libdir = File.join($sources_root, 'lib')
registry = File.join($sources_root , 'spec/data/registry')
source = File.join($sources_root, 'spec/data/scripts')

def program_path(program)
  if ENV['AUTOPKGTEST_TMP']
    ['-S', program]
  else
    File.join($sources_root, 'bin', program)
  end
end

Before do
  $tmpdir = Dir.mktmpdir
end

After do
  FileUtils.rm_rf($tmpdir)
end

When /^I run `(\S+) (.*)`$/ do |program, args|
  command = [ruby, "-I#{libdir}", *program_path(program), '--silent', '--registry-dir', registry, '--source-dir', source, '--target-dir', $tmpdir]
  args.split.each { |a| command << a }

  stdout = File.join($tmpdir, 'stdout')
  stderr = File.join($tmpdir, 'stderr')

  cmd = command.join(' ')
  success = system("#{cmd} >#{stdout} 2>#{stderr}")

  @stdout = File.read(stdout)
  @stderr = File.read(stderr)

  if !success
    errormsgs = []
    errormsgs << "Command `#{cmd}` failed with exit status #{$?.exitstatus}"
    errormsgs << "stdout:"
    errormsgs << '======='
    errormsgs << @stdout
    errormsgs << "stderr:"
    errormsgs << '======='
    errormsgs << @stderr
    raise errormsgs.join("\n")
  end

end

def installed_addon_files(addon)
  descriptor = File.join($sources_root, 'spec/data/registry/' + addon + '.yaml')
  if !File.exists?(descriptor) || YAML.load_file(descriptor)['files']
    Dir.glob(File.join($tmpdir, '*', addon + '.vim'))
  else
    Dir.glob(File.join($tmpdir, 'vam', addon))
  end
end

Then /^(.*) should be installed$/ do |addon|
  expect(installed_addon_files(addon)).to_not be_empty
end

Given /^(.*) is installed$/ do |addon|
  step "I run `vim-addons install #{addon}`"
end

Then /^(.*) should not be installed anymore$/ do |addon|
  expect(installed_addon_files(addon)).to be_empty
end

Then /^(?:vim-addons must output|the output should match) "([^"]*)"$/ do |text|
  expect(@stdout).to match(Regexp.new(text))
end

Then /^vim-addons should warn "([^"]*)"$/ do |text|
  expect(@stderr).to match(Regexp.new(text))
end

Then /^the documentation should be indexed$/ do
  expect(Dir.glob(File.join($tmpdir, 'doc', 'tags'))).to_not be_empty
end

Given /^(\S*) was previously installed as an old\-style addon$/ do |addon|
  Dir.chdir $tmpdir do
    FileUtils.mkdir_p 'syntax'
    FileUtils.ln_s '/not/existing/syntax', "syntax/#{addon}.vim"
    FileUtils.mkdir_p 'ftplugin'
    FileUtils.ln_s '/not/existing/ftplugin', "ftplugin/#{addon}.vim"
  end
end

Given /^there should be no broken symlinks$/ do
  expect(Dir.glob(File.join($tmpdir, '**/*')).select { |f| File.symlink?(f) && !File.exists?(f) }).to be_empty
end
