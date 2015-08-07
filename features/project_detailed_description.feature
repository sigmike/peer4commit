Feature: Project detailed description is markdown formatted
  Background:
    Given a project
    And the project single collaborator is "bob"
    And I'm logged in as "bob"
    And I go to the project page
    And I click on "Edit project"

  Scenario: Standard markdown
    When I fill "Detailed description" with:
      """
      foo [bar](http://foo.example.com/)
      """
    And I click on "Save"
    Then I should see a link "bar" to "http://foo.example.com/"

  Scenario: XSS attempt
    When I fill "Detailed description" with:
      """
      foo [bar](javascript:alert('xss'))
      """
    And I click on "Save"
    Then I should not see a link "bar" to "javascript:alert('xss')"

  Scenario: Embedded HTML
    When I fill "Detailed description" with:
      """
      foo <a href="javascript:alert('xss')">bar</a>
      """
    And I click on "Save"
    Then I should not see a link "bar" to "javascript:alert('xss')"

  Scenario: Inline external image
    When I fill "Detailed description" with:
      """
      ![foo](http://example.com/img.jpg)
      """
    And I click on "Save"
    Then I should not see the image "http://example.com/img.jpg"

