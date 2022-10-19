# vim-addons: command line manager of Vim addons
#
# Copyright (C) 2007 Stefano Zacchiroli
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

require 'find'
require 'set'
require 'yaml'

require 'vim/addon_manager/addon'

module Vim

  class AddonManager

    class Registry

      include Enumerable

      def initialize(registry_dir, source_dir)
        @basedir = source_dir # default basedir, can be overridden by addons
        @addons = {}
        self.class.each_addon(registry_dir, @basedir) {|a| @addons[a.name] = a}
      end

      def [](name)
        @addons[name]
      end

      def each
        @addons.each_value {|a| yield a}
      end

      def self.each_addon(dir, basedir)
        Dir.glob(File.join(dir, '*.yaml')).each do |yaml|
          stream = YAML.load_stream(File.read(yaml))
          stream = stream.documents if stream.respond_to?(:documents) # Ruby 1.8 compatibility
          if stream
            stream.each do |ydoc|
              yield(Addon.build(ydoc, basedir)) if ydoc
            end
          end
        end
      end

    end

  end

end

