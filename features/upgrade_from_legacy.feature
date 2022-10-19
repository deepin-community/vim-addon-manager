Feature: upgrading legacy addons

  Scenario: upgrading newstylemigrated
    Given newstylemigrated was previously installed as an old-style addon
    When I run `vim-addons upgrade-from-legacy`
    Then there should be no broken symlinks
    And newstylemigrated should be installed
