Feature: installing addons

  Scenario: installing foo
    When I run `vim-addons install foo`
    Then foo should be installed

  Scenario: unknown addons
    When I run `vim-addons install addonthatdoesnotexist`
    Then vim-addons should warn "Ignoring unknown addons: addonthatdoesnotexist"

  Scenario: installing newstyle
    When I run `vim-addons install newstyle`
    Then newstyle should be installed

  Scenario: addon with documentation
    When I run `vim-addons install withdoc`
    Then the documentation should be indexed
