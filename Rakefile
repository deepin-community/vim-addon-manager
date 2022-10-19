desc 'run all the tests'
task :default => [:rspec, :cucumber]

desc 'run unit tests'
task :rspec do
  ruby '-S rspec --color spec'
end

desc 'run acceptance tests'
task :cucumber do
  ruby '-S cucumber --format progress'
end

html = FileList['doc/*.markdown'].gsub(/\.markdown$/, '.html')

desc 'build documentation'
task :doc => html

rule '.html' => ['.markdown', 'doc/template.html'] do |t|
  sh %{pandoc --smart -f markdown --section-divs -t html5 --template=doc/template.html -o #{t.name} #{t.source}}
end

desc 'remove generated files'
task :clean do
  rm_f html
end
