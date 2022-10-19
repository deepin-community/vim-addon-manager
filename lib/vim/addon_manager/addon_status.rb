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

    # an addon status is one of the following
    # - :not_installed
    # - :installed
    # - :broken (missing_files attribute is then used to list not installed
    # files)
    # - :unavailable (missing_files attribute is then used to list source files
    # that weren't found)
    #
    AddonStatusStruct = Struct.new(:status, :missing_files)

    class AddonStatus < AddonStatusStruct

      def initialize(*args)
        super(*args)
        @disabled = false
      end

      def logger
        Vim::AddonManager.logger
      end

      attr_accessor :disabled

      def to_s
        if @disabled
          'disabled'
        else
          case status
          when :installed
            'installed'
          when :not_installed
            'removed'
          when :broken
            s = 'broken'
            if logger.verbose?
              s << " (missing: #{missing_files.join ', '})"
            end
            s
          when :unavailable
            s = 'unavailable'
            if logger.verbose?
              s << " (missing source files: #{missing_files.join ', '})"
            end
            s
          end
        end
      end

    end

  end

end
