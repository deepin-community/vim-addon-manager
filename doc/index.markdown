# vim-addon-manager

## Installation

If you use [Debian](http://debian.org/) (or any derivative), you can install
from the Debian repository.

```debian
$ apt-get install vim-addon-manager
```

On other systems, you can install vim-addon-manager using [Rubygems](http://rubygems.org/):

```rubygems
$ gem install vim-addon-manager
```

## Usage

Addon installation:

```shell
$ vam install tetris                                  # from vim-scripts package on Debian
$ vam install https://github.com/user/extension.git   # from git repository
```

Checking the status of your addons:

```shell
$ vam status
# Name                     User Status  System Status 
align                      installed    removed
alternate                  removed      removed
bufexplorer                removed      removed
calendar                   removed      removed
closetag                   removed      removed
[...]
```

Removing installed addons:

```shell
$ vam remove tetris
```

For more in-depth information, check the [documentation](documentation.html).
