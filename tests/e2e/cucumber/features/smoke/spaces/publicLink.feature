Feature: spaces public link


  Background:
    Given "Admin" creates following users using API
      | id    |
      | Alice |
      | Brian |

  Scenario: public link for space
    Given "Admin" creates following users using API
      | id    |
      | Carol |
      | David |
    And "Admin" assigns following roles to the users using API
      | id    | role        |
      | Alice | Space Admin |
    When "Alice" logs in
    And "Alice" creates the following project space using API
      | name | id     |
      | team | team.1 |
    And "Alice" creates the following folder in space "team" using API
      | name                  |
      | spaceFolder/subFolder |
    And "Alice" adds the following members to the space "team" using API
      | user  | role       | shareType |
      | Brian | Can edit   | space     |
      | Carol | Can view   | space     |
      | David | Can manage | space     |
    And "Alice" navigates to the projects space page
    And "Alice" navigates to the project space "team.1"
    And "Alice" creates a public link for the space using the sidebar panel
    And "Alice" renames the most recently created public link of space to "spaceLink"
    And "Alice" creates a public link for the resource "spaceFolder" using the sidebar panel
    And "Alice" renames the most recently created public link of resource "spaceFolder" to "folderLink"
    And "Alice" logs out
    When "Brian" logs in
    And "Brian" opens the public link "spaceLink"
    Then "Brian" should not be able to edit the public link named "spaceLink"
    And "Brian" should not be able to edit the public link named "folderLink"
    And "Brian" logs out
    When "Carol" logs in
    And "Carol" opens the public link "spaceLink"
    But "Carol" should not be able to edit the public link named "spaceLink"
    And "Carol" should not be able to edit the public link named "folderLink"
    When "Carol" opens the public link "folderLink"
    Then "Carol" should see folder "subFolder" but should not be able to edit
    And "Carol" logs out
    When "David" logs in
    And "David" opens the public link "spaceLink"
    And "David" edits the public link named "spaceLink" of the space changing role to "Can edit"
    And "David" edits the public link named "folderLink" of resource "spaceFolder" changing role to "Can edit"
    And "David" logs out


  Scenario: public link for folder
    Given "Alice" logs in
    And "Alice" creates the following resources
      | resource         | type   |
      | folderPublic     | folder |
    And "Alice" uploads the following resources
      | resource  | to               |
      | lorem.txt | folderPublic     |
    And "Alice" creates a public link for the resource "folderPublic" using the sidebar panel
    And "Alice" renames the most recently created public link of resource "folderPublic" to "folderLink"
    And "Alice" logs out
    And "Brian" logs in
    When "Brian" opens the public link "folderLink"
    Then "Brian" should see file "lorem.txt" but should not be able to edit
    And "Brian" logs out
    When "Anonymous" opens the public link "folderLink"
    Then "Anonymous" should see file "lorem.txt" but should not be able to edit
