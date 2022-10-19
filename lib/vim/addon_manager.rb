# vim-addons: command line manager of Vim addons
#
# Copyright (C) 2007 Stefano Zacchiroli
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

require 'fileutils'

require 'vim/addon_manager/constants'
require 'vim/addon_manager/addon'
require 'vim/addon_manager/logger'
require 'vim/addon_manager/upgrade_from_legacy'

module Vim

  class AddonManager

    def initialize(target_dir)
      @target_dir = target_dir
    end

    attr_accessor :target_dir

    def self.override_file(dir)
      File.join dir, OVERRIDE_FILE
    end

    def self.system(cmd)
      logger.info "executing '#{cmd.join(' ')}'" if logger.verbose?
      Kernel::system *cmd
    end

    def self.logger
      @logger ||= Vim::AddonManager::Logger.new
    end

    def logger
      self.class.logger
    end

    def install(addons)
      installed_files = []
      addons.each do |addon|
        installed_files.concat(addon.install(@target_dir))
      end
      rebuild_tags(installed_files)
    end

    def remove(addons)
      removed_files = []
      addons.each do |addon|
        removed_files.concat(addon.remove(@target_dir))
      end
      # Try to clean up the tags file and doc dir if it's empty
      tagfile = File.join(@target_dir, 'doc', 'tags')
      if File.exists? tagfile
        File.unlink tagfile
        begin
          FileUtils.rmdir File.join(@target_dir, 'doc')
        rescue Errno::ENOTEMPTY
          rebuild_tags(removed_files)
        end
      end
    end

    def disable(addons)
      map_override_lines do |lines|
        addons.each do |addon|  # disable each not yet disabled addon
          if not addon.disabled_by_line
            logger.warn \
              "#{addon} can't be disabled (since it has no 'disabledby' field)"
            next
          end
          if lines.any? {|line| addon.is_disabled_by? line}
            logger.info "ignoring addon '#{addon}' which is already disabled"
          else
            logger.info "disabling enabled addon '#{addon}'"
            lines << addon.disabled_by_line + "\n"
          end
        end
      end
    end

    def enable(addons)
      map_override_lines do |lines|
        addons.each do |addon|
          if not addon.disabled_by_line
            logger.warn \
              "#{addon} can't be enabled (since it has no disabledby field)"
            next
          end
          if lines.any? {|line| addon.is_disabled_by? line}
            logger.info "enabling disabled addon '#{addon}'"
            lines.reject! {|line| addon.is_disabled_by? line}
          else
            logger.info "ignoring addon '#{addon}' which is enabled"
          end
        end
      end
    end

    def amend(addons)
      logger   "the 'amend' command is deprecated and will disappear in a " +
               "future release.  Please use the 'enable' command instead."
      enable(addons)
    end

    def show(addons)
      addons.each do |addon|
        puts "Addon: #{addon}"
        puts "Status: #{addon.status(@target_dir)}"
        puts "Description: #{addon.description}"
        puts "Files:\n#{addon.files.map { |f| " - #{f}\n"}.join}"
        puts ""
      end
    end

    private

    def map_override_lines
      override_lines = []
      override_file = Vim::AddonManager.override_file @target_dir
      if File.exist? override_file
        File.open(override_file) do |file|
          override_lines += file.to_a
        end
      end
      checksum = override_lines.hash

      yield override_lines

      if override_lines.empty?
        FileUtils.rm override_file if File.exist? override_file
      elsif override_lines.hash != checksum
        FileUtils.mkdir_p(File.dirname(override_file))
        File.open(override_file, 'w') do |file|
          override_lines.each do |line|
            file.write line
          end
        end
      end
    end

    def rebuild_tags(files)
      needs_rebuilding = files.any? {|file| file =~ /^doc\//}
      if needs_rebuilding
        logger.info 'Rebuilding tags since documentation has been modified ...'
        Vim::AddonManager.system [HELPZTAGS, File.join(@target_dir, 'doc/')]
        logger.info 'done.'
      end
    end

  end

end

