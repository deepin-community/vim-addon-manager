Feature: different program names

  Scenario Outline:
    When I run `<program_name> --help`
    Then the output should match "Usage:"
  Examples:
    | program_name |
    | vim-addons |
    | vim-addon-manager |
    | vam |
