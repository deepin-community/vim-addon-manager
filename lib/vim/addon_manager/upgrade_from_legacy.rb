module Vim

  class AddonManager

    def upgrade_from_legacy(addons)
      addons.each do |addon|
        upgrade_addon_from_legacy(addon, @target_dir)
      end
    end

    def upgrade_addon_from_legacy(addon, target_dir)
      if addon.metadata['legacy_files']
        links = addon.metadata['legacy_files'].map do |f|
          File.join(target_dir, f)
        end.select do |f|
          File.symlink?(f)
        end
        unless links.empty?
          links.each do |f|
            File.unlink(f)
          end
          addon.install(target_dir)
        end
      end
    end

  end

end
