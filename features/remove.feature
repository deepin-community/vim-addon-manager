Feature: removing addons

  Scenario: removing foo
    Given foo is installed
    When I run `vim-addons remove foo`
    Then foo should not be installed anymore

  Scenario: removing newstyle
    Given newstyle is installed
    When I run `vim-addons remove newstyle`
    Then newstyle should not be installed anymore
