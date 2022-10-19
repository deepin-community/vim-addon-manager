# vim-addons: command line manager of Vim addons
#
# Copyright (C) 2007 Stefano Zacchiroli
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

module Vim

  class AddonManager

    class Addon

      class Legacy < Addon

        def initialize(yaml, basedir)
          @files = Set.new yaml['files']
          raise ArgumentError.new('empty addon') if @files.size == 0
          super
        end

        attr_reader :files

        def status(target_dir)
          expected_dest = @files.collect {|f| File.join(target_dir, f)}
          installed = expected_dest.select do |f|
            File.exist? f
          end
          expected_src = @files.collect {|f| File.join(@basedir, f)}
          available = expected_src.select do |f|
            File.exist? f
          end

          status =
            if available.size != expected_src.size
              missing = expected_src - available
              AddonStatus.new(:unavailable, missing)
            elsif installed.size == expected_dest.size
              AddonStatus.new :installed
            elsif installed.size == 0
              AddonStatus.new :not_installed
            else
              missing = expected_dest - installed
              prefix = /^#{Regexp.escape target_dir}\/+/o
              missing.collect! {|f| f.gsub(prefix, '')}
              AddonStatus.new(:broken, missing)
            end

          status.disabled = is_disabled_in? target_dir
          status
        end

        def install(target_dir)
          installed_files = []
          symlink = lambda do |file|
            dest = File.join(target_dir, file)
            self.mkdir(dest)
            FileUtils.ln_sf(File.join(basedir, file), dest)
          end
          status = self.status(target_dir)
          case status.status
          when :broken
            logger.info "installing broken addon '#{self}' to #{target_dir}"
            status.missing_files.each(&symlink)
            installed_files.concat(status.missing_files.to_a)
          when :not_installed
            logger.info "installing removed addon '#{self}' to #{target_dir}"
            self.files.each(&symlink)
            installed_files.concat(self.files.to_a)
          when :unavailable
            s = "ignoring '#{self}' which is missing source files"
            s << "\n- #{status.missing_files.join "\n- "}" if logger.verbose?
            logger.warn s
          else
            logger.info "ignoring '#{self}' which is neither removed nor broken"
          end
          installed_files
        end

        def remove(target_dir)
          removed_files = []
          status = self.status(target_dir)
          case status.status
          when :installed
            logger.info "removing installed addon '#{self}' from #{target_dir}"
            self.files.each { |f| rmdirs(target_dir, f) }
            removed_files.concat(self.files.to_a)
          when :broken
            logger.info "removing broken addon '#{self}' from #{target_dir}"
            files = (self.files - status.missing_files)
            files.each { |f| rmdirs(target_dir, f) }
            removed_files.concat(files.to_a)
          else
            logger.info "ignoring '#{self}' which is neither installed nor broken"
          end
          removed_files
        end

        private

        def rmdirs(target_dir, file)
          File.delete(File.join(target_dir, file))
          dir = File.dirname(file)
          paths = (dir.include? File::Separator) ? File.split(dir) : [dir]
          while paths.size > 0
            begin
              FileUtils.rmdir(File.join(target_dir, paths))
            rescue Errno::ENOTEMPTY
              break
            end
            paths.pop
          end
        end

      end

    end

  end

end
