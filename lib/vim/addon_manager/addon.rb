# vim-addons: command line manager of Vim addons
#
# Copyright (C) 2007 Stefano Zacchiroli
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

require 'vim/addon_manager/addon_status'

module Vim

  class AddonManager

    class Addon

      # Initializes a new Addon instance.
      #
      # If a subclass defines its own +initialize+ method, then it *must* call
      # super at some point to make sure essential data is properly
      # initialized.
      #
      def initialize(yaml, basedir)
        @metadata = yaml

        @basedir = (yaml['basedir'] or basedir)
        @description = yaml['description']
        @name = yaml['addon']

        @disabled_by_line = yaml['disabledby']
        if @disabled_by_line then
          @disabled_by_RE = /^\s*#{Regexp.escape @disabled_by_line}\s*$/
        else
          @disabled_by_RE = nil
        end

      end

      # Returns a Set of the files contained in this addon.
      #
      # This method must be overridden by subclasses.
      #
      def files
        Set.new
      end

      # return the status of the self add-on wrt a target installation
      # directory, and the system wide installation directory.
      #
      # A status may be one of the following values
      #  * :not_installed (the addon is not installed at all)
      #  * :installed (the addon is completely installed)
      #  * :broken (the addon is only partially installed)
      #  * :unavailable (source files are missing)
      #  * :unknown (the addon is unknown to the system)
      #
      # This method must be overridden by subclasses.
      #
      def status(target_dir)
        AddonStatus.new :unknown
      end

      def mkdir(dest)
        dest_dir = File.dirname dest
        if Process.euid == 0
          FileUtils.mkdir_p dest_dir, :mode => 0755
        else
          FileUtils.mkdir_p dest_dir
        end
      end

      # Installs addon files into +target_dir+ and returns a list of installed
      # files.
      #
      # This method must be overridden by subclasses.
      #
      def install(target_dir)
        []
      end

      # Removes addon files from +target_dir+ and returns a list of installed
      # files.
      #
      # This method must be overridden by subclasses.
      #
      def remove(target_dir)
        []
      end

      def to_s
        name
      end

      def <=>(other)
        self.name <=> other.name
      end

      # checks if a given line (when present in a Vim configuration file) is
      # suitable for disabling the addon
      #
      def is_disabled_by?(line)
        return false unless @disabled_by_RE # the addon can't be disabled if no
        # disabledby field has been provided
        line =~ @disabled_by_RE ? true : false
      end

      attr_reader :metadata
      attr_reader :basedir
      attr_reader :description
      attr_reader :name
      attr_reader :disabled_by_line
      alias_method :addon, :name

      def self.build(yaml, basedir)
        case yaml['type']
        when 'directory'
          Vim::AddonManager::Addon::Directory.new(yaml, basedir)
        else
          Vim::AddonManager::Addon::Legacy.new(yaml, basedir)
        end
      end

      private

      def logger
        Vim::AddonManager.logger
      end

      # checks whether the addon is disabled wrt a given target installation dir
      #
      def is_disabled_in?(target_dir)
        filename = Vim::AddonManager.override_file(target_dir)
        return false unless File.exist?(filename)
        File.open(filename) do |file|
          file.any? {|line| is_disabled_by? line}
        end
      end

    end

  end

end

require 'vim/addon_manager/addon/legacy'
require 'vim/addon_manager/addon/directory'
