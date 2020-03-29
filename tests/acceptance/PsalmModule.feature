Feature: Psalm module
  In order to test Psalm plugins
  As a Psalm plugin developer
  I need to be able to write tests

  Background:
    Given I have the following code preamble
    """
    <?php

    """

  Scenario: Running with no errors
    Given I have the following code
      """
      atan(1.1);
      """
    When I run Psalm
    Then I see no errors

  Scenario: Running with errors
    Given I have the following code
      """
      atan("asd");
      """
    When I run Psalm
    Then I see these errors
      | Type                  | Message                                            |
      | InvalidScalarArgument | Argument 1 of atan expects float, string% provided |
    And I see no other errors

  Scenario: Skipping depending on a certain Psalm version
    Given I have Psalm newer than "999.99" (because of "me wanting to see if it skips")
    And I have the following code
      """
      atan(1.);
      """
    When I run Psalm
    Then I see no errors

  Scenario: Running depending on a certain Psalm version
    Given I have Psalm older than "999.99" (because of "me wanting to see if it runs")
    And I have the following code
      """
      atan(1.);
      """
    When I run Psalm
    Then I see no errors

  Scenario: Running Psalm with dead code detection
    Given I have the following code
      """
      class C {
        /** @return void */
        private function m(int $p) {}
      }
      """
    When I run Psalm with dead code detection
    Then I see these errors
      | Type         | Message                                     |
      | UnusedParam  | Param $p is never referenced in this method |
      | UnusedClass  | Class C is never used                       |
    And I see no other errors

  Scenario: Running Psalm with custom config
    Given I have the following config
      """
      <?xml version="1.0"?>
      <psalm totallyTyped="true">
        <projectFiles>
          <directory name="."/>
        </projectFiles>
        <issueHandlers>
          <InvalidScalarArgument errorLevel="suppress"/>
        </issueHandlers>
      </psalm>
      """
    And I have the following code
      """
      atan("asd");
      """
    When I run Psalm
    Then I see no errors

  Scenario: Running psalm on an individual file
    Given I have the following code in "C.php"
      """
      <?php
      class C extends PPP {}
      """
    And I have the following code in "P.php"
      """
      <?php
      class PPP {}
      """
    When I run Psalm on "P.php"
    Then I see no errors

  Scenario: Running psalm on an individual file without autoloader
    Given I have the following code in "C.php"
      """
      <?php
      class C extends PPP {}
      """
    And I have the following code in "P.php"
      """
      <?php
      class PPP {}
      """
    When I run Psalm on "C.php"
    Then I see these errors
      | Type           | Message                               |
      | UndefinedClass | Class or interface PPP does not exist |

  Scenario: Running psalm on an individual file with autoloader
    Given I have the following code in "C.php"
      """
      <?php
      class C extends PPP {}
      """
    And I have the following code in "P.php"
      """
      <?php
      class PPP {}
      """
    And I have the following class map
      | Class | File  |
      | C     | C.php |
      | PPP   | P.php |
    When I run Psalm on "C.php"
    Then I see no errors

