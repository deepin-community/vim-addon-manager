Feature: showing addons

  Scenario: showing foo
    When I run `vim-addons show foo`
    Then vim-addons must output "Addon: foo"
    And  vim-addons must output "Description:.*"
    And  vim-addons must output " - syntax/foo.vim"
    And  vim-addons must output " - ftplugin/foo.vim"
