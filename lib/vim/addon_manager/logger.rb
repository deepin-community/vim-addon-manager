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

    class Logger

      def initialize
        @verbosity = 1
      end

      def increase_verbosity
        @verbosity += 1
      end

      def quiet!
        @verbosity = 0
      end

      def quiet?
        @verbosity < 1
      end

      def verbose?
        @verbosity > 1
      end

      def warn(s)
        $stderr.puts "Warning: #{s}"
      end

      def info(s)
        puts "Info: #{s}" unless quiet?
      end

    end

  end
end
