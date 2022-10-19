# vim-addons: command line manager of Vim addons
#
# Copyright (c) 2012 Antonio Terceiro <terceiro@debian.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

module Vim

  class AddonManager

    class Addon

      class Directory < Addon

        def initialize(yaml, basedir)
          @directory = yaml['directory']
          super
        end

        attr_reader :directory

        def status(target_dir)
          if File.symlink?(destination(target_dir))
            AddonStatus.new :installed
          else
            AddonStatus.new :not_installed
          end
        end

        def install(target_dir)
          dest = destination(target_dir)
          self.mkdir(dest)
          FileUtils.ln_sf(source, dest)
          files
        end

        def remove(target_dir)
          FileUtils.rm_f(destination(target_dir))
          files
        end

        def files
          Dir.chdir(source) do
            Dir.glob('**/*')
          end.map do |filename|
            File.join('vam', name, filename)
          end
        end

      protected

        def source
          directory || File.join(basedir, 'vam', name)
        end

        def destination(target_dir)
          File.join(target_dir.to_s, 'vam', name)
        end

      end
    end

  end

end

