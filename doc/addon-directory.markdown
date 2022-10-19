# vim-addon-manager: one addon per directory

The original addon format used by vim-addon-manager has a serious problem. When
you have the addon installed (say, into your ~/.vim), then you have one symlink
for each file contained by the addon. When that addon is upgraded system-wide
and new files are added, or existing files are removed, then it effectively
becomes broken, because you will either have missing symlinks or broken ones.

Another problem with the current addon system is that you cannot easily install
new addons that are not packaged.

This new addon type tries to solve both issues.

## Registry entry

The registry file for directory addons must be like this:

    addon: my-addon
    description: "new style addon with a directory instead of files"
    type: directory
    directory: /path/to/my/addon

The "type" field must contain the value "directory".

The "directory" field must contain the path were the addon is installed. If
this field is omitted, vim-addon-manager will assume that the addon was
installed to /usr/share/vim/addons/vam/$(addon), where $(addon) is the addon
name from the "addon" field.

## Addon contents

Each addon must reproduce the contents of a vim runtimepath directory, i.e. it
can contain subdirectories doc/, plugin/, autoload/, syntax/, etc. For example, the migrated vim-rails package installs the following files.

/usr/share/vim/addons/vam/rails/doc/tags
/usr/share/vim/addons/vam/rails/doc/rails.txt
/usr/share/vim/addons/vam/rails/plugin/rails.vim
/usr/share/vim/addons/vam/rails/autoload/rails.vim

These files were previously installed directly into /usr/share/vim/addons, and
they are now being installed to /usr/share/vim/addons/vam/rails.

When such an addon is installed via `vim-addon-manager install rails`, you will
end up with a symlink at ~/.vim/vam/rails pointing at
/usr/share/vim/addons/vam/rails. That symlink will be added to the vim
runtimepath during startup.

## Tags files

Since the installation involves a single symlink to a directory writable only
by root, new style addons must include pre-buit tags files. Note the listing of
the vim-rails package above: it already includes a tags file under `doc/tags`.

## Migrating from the old-style addon format

If you maintain an existing addon and want to migrate it to the new addon
format, follow these steps:

* add a "type" field to the registry file, with "directory" as value
* rename the "files" field to "legacy\_files". This will help vim-addon-manager
  with upgrading the addon.
* change the package to install to /usr/share/vim/addons/vam/$(addon) instead
  of scatering its files into /usr/share/vim/addons.

During package upgrades, a dpkg trigger via vim-addon-manager will remove the
existing multiple symlinks from the target directory and install the new
symlink into $(target\_dir)/vam.

## See also

See the dh-vim-addon package, which automates most of the work needed to
package vim addons in this new format supported by vim-addon-manager.
