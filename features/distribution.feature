Feature: Fundraisers can distribute funds
  @javascript
  Scenario: Send distribution to a single user who has set his address
    Given a GitHub user "bob" who has set his address to "mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I fill the amount to "bob" with "10"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |     10 |        100 |
    And I should see "Total amount: 10.00 PPC"

    When the tipper is started
    Then no coins should have been sent

    Given the current time is "2014-03-01 12:35:02 UTC"
    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And I should see "Transaction sent on Sat, 01 Mar 2014 12:35:02 +0000"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |   10.0 |
    And the project balance should be "490"

  @javascript
  Scenario: Send distribution to multiple users
    Given a GitHub user "bob" who has set his address to "mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1"
    And a GitHub user "carol" who has set his address to "mi9SLroAgc8eUNuLwnZmdyqWdShbNtvr3n"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I add the GitHub user "carol" to the recipients
    And I fill the amount to "bob" with "10"
    And I fill the amount to "carol" with "13.56"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |     10 |       42.4 |
      | carol     | mi9SLroAgc8eUNuLwnZmdyqWdShbNtvr3n |  13.56 |       57.6 |
    And I should see "Total amount: 23.56 PPC"

    When the tipper is started
    Then no coins should have been sent

    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |   10.0 |
      | mi9SLroAgc8eUNuLwnZmdyqWdShbNtvr3n |  13.56 |
    And the project balance should be "476.44"

  @javascript
  Scenario: Send to an unknown GitHub user
    Given "bob" is an user registered on GitHub

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I fill the amount to "bob" with "10"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       |                                    |     10 |      100.0 |
    And I should see "Total amount: 10.00 PPC"
    And I should not see "Send the transaction"
    And I should see "The transaction cannot be sent because some addresses are missing"

    And no email should have been sent

    When the tipper is started
    Then no coins should have been sent

    When I log out
    And I log in as "bob"
    And I set my address to "mnVba8qrpy5uxYD7dV4NZMQPWjgdt2QC1i"

    When I log out
    And I log in as "alice"
    And I go to the project page
    And I click on the last distribution
    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       | mnVba8qrpy5uxYD7dV4NZMQPWjgdt2QC1i |     10 |      100.0 |

    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mnVba8qrpy5uxYD7dV4NZMQPWjgdt2QC1i |   10.0 |
    And the project balance should be "490.00"

  @javascript
  Scenario: Send to an invalid GitHub user
    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    Then I should see "Invalid GitHub user"

    When I save the distribution
    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
    And I should see "Total amount: 0.00 PPC"

  @javascript
  Scenario: Send to an user without an address
    Given a GitHub user "bob"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I fill the amount to "bob" with "10"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       |                                    |     10 |      100.0 |
    And I should see "Total amount: 10.00 PPC"
    And I should not see "Send the transaction"
    And I should see "The transaction cannot be sent because some addresses are missing"

    And no email should have been sent

    When the tipper is started
    Then no coins should have been sent

    When I log out
    And I log in as "bob"
    And I set my address to "mnVba8qrpy5uxYD7dV4NZMQPWjgdt2QC1i"

    When I log out
    And I log in as "alice"
    And I go to the project page
    And I click on the last distribution
    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       | mnVba8qrpy5uxYD7dV4NZMQPWjgdt2QC1i |     10 |      100.0 |

    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mnVba8qrpy5uxYD7dV4NZMQPWjgdt2QC1i |   10.0 |
    And the project balance should be "490.00"

  @javascript
  Scenario: Send to an unknown email address
    Given the current time is "2014-03-01 12:35:02 UTC"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the email address "bob@example.com" to the recipients
    And I fill the amount to "bob@example.com" with "10"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient       | address  | amount | percentage |
      | bob@example.com |          |     10 |      100.0 |
    And I should see "The transaction cannot be sent because some addresses are missing"

    And no email should have been sent

    When the tipper is started
    Then no coins should have been sent
    And no email should have been sent

    When I click on "Send email request to provide an address"
    Then I should see these distribution lines:
      | recipient       | address | amount | percentage |
      | bob@example.com |         |     10 |      100.0 |

    And an email should have been sent to "bob@example.com"
    And the email should include "alice"
    And the email should include a link to the last distribution
    When I visit the link to set my password and address from the email
    And I fill "Password" with "password"
    And I fill "Password confirmation" with "password"
    And I fill "Peercoin address" with "mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK"
    And I click on "Save"

    Then I should see "Information saved"
    And the user with email "bob@example.com" should have "password" as password
    And the user with email "bob@example.com" should have "mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK" as peercoin address

    When I log out
    And I log in as "alice"
    And I go to the project page
    And I click on the last distribution
    Then I should see these distribution lines:
      | recipient           | address                            | amount | percentage |
      | bob@example.com     | mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK |     10 |      100.0 |

    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK |   10.0 |
    And the project balance should be "490.00"

  @javascript
  Scenario: Send to a known email address who has no confirmation token
    Given an user with email "bob@example.com" and without password nor confirmation token
    And a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the email address "bob@example.com" to the recipients
    And I fill the amount to "bob@example.com" with "10"
    And I save the distribution
    Then I should see these distribution lines:
      | recipient       | address  | amount | percentage |
      | bob@example.com |          |     10 |      100.0 |
    When I click on "Send email request to provide an address"
    Then I should see "Request sent"
    And an email should have been sent to "bob@example.com"
    When I visit the link to set my password and address from the email
    And I fill "Password" with "password"
    And I fill "Password confirmation" with "password"
    And I fill "Peercoin address" with "mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK"
    And I click on "Save"

    Then I should see "Information saved"
    And the user with email "bob@example.com" should have "password" as password
    And the user with email "bob@example.com" should have "mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK" as peercoin address

  Scenario: Send to someone who doesn't want to be notified
    Then pending

  Scenario: Cannot login from email link if a password has already been set
    Then pending

  Scenario: Cannot login from an old email link
    Then pending

  @javascript
  Scenario: Edit a distribution
    Given a GitHub user "bob" who has set his address to "mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I fill the amount to "bob" with "10"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |     10 |        100 |
    And I should see "Total amount: 10.00 PPC"

    Given a GitHub user "carol" who has set his address to "mi9SLroAgc8eUNuLwnZmdyqWdShbNtvr3n"

    And I click on "Edit"
    And I fill the amount to "bob" with "15"
    And I add the GitHub user "carol" to the recipients
    And I fill the amount to "carol" with "5"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | address                            | amount | percentage |
      | bob       | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |     15 |       75.0 |
      | carol     | mi9SLroAgc8eUNuLwnZmdyqWdShbNtvr3n |      5 |       25.0 |

    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |   15.0 |
      | mi9SLroAgc8eUNuLwnZmdyqWdShbNtvr3n |    5.0 |
    And the project balance should be "480"

  @javascript
  Scenario: Send to a known email address
    Given an user with email "bob@example.com"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    Given I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the email address "bob@example.com" to the recipients
    And I fill the amount to "bob@example.com" with "10"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient                               | address  | amount | percentage |
      | bob@example.com                         |          |     10 |      100.0 |
    And I should see "The transaction cannot be sent because some addresses are missing"

    And no email should have been sent

    When the tipper is started
    Then no coins should have been sent
    And no email should have been sent

    When I click on "Send email request to provide an address"
    Then I should see these distribution lines:
      | recipient       | address | amount | percentage |
      | bob@example.com |         |     10 |      100.0 |

    And an email should have been sent to "bob@example.com"
    And the email should include "alice"
    And the email should include a link to the last distribution
    When I log out
    And I click on the "Set your Peercoin address" link in the email
    Then I should see "Forgot your password?"
    When I fill "Email" with "bob@example.com"
    And I fill "Password" with "password"
    And I click on "Sign in" in the sign in form
    Then I should see "Peercoin address"
    When I fill "Peercoin address" with "mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK"
    And I fill "Current password" with "password"
    And I click on "Update"
    Then I should see "You updated your account successfully"

    And the user with email "bob@example.com" should have "mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK" as peercoin address

    When I log out
    And I log in as "alice"
    And I go to the project page
    And I click on the last distribution
    Then I should see these distribution lines:
      | recipient           | address                            | amount | percentage |
      | bob@example.com     | mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK |     10 |      100.0 |

    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mubmzLrtTgDE2WrHkiwSFKuTh2VTSXboYK |   10.0 |
    And the project balance should be "490.00"

  @javascript
  Scenario: Send distribution with a comment
    Given a GitHub user "bob" who has set his address to "mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    When I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I fill the amount to "bob" with "10"
    And I fill the comment to "bob" with "Great idea"
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | address                            | reason     | amount | percentage |
      | bob       | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 | Great idea |     10 |        100 |


  Scenario: Send multiple times to the same recipient
    Then pending

  @javascript
  Scenario: Remove a distribution line
    Given a GitHub user "bob"
    And a GitHub user "carol"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    When I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I add the GitHub user "carol" to the recipients
    And I remove the recipient "bob"
    Then the distribution form should have these recipients:
      | recipient |
      | bob       |
      | carol     |

    When I save the distribution
    Then I should see these distribution lines:
      | recipient |
      | carol     |

    When I click on "Edit the distribution"
    And I remove the recipient "carol"
    And I save the distribution
    Then I should see these distribution lines:
      | recipient |

  @javascript
  Scenario: Create distribution line without an amount
    Given a GitHub user "bob" who has set his address to "mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    When I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I save the distribution

    Then I should see these distribution lines:
      | recipient | amount    | percentage |
      | bob       | Undecided |            |
    And I should not see the button "Send the transaction"

  @javascript
  Scenario: Send too much funds
    Given a GitHub user "bob" who has set his address to "mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    When I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I fill the amount to "bob" with "500.01"
    And I click on "Save"
    Then I should see "Not enough funds"

  @javascript
  Scenario: Send all the funds
    Given a GitHub user "bob" who has set his address to "mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1"

    Given a project managed by "alice"
    And our fee is "0"
    And a deposit of "500"

    When I'm logged in as "alice"
    And I go to the project page
    And I click on "New distribution"
    And I add the GitHub user "bob" to the recipients
    And I fill the amount to "bob" with "500.00"
    And I click on "Save"
    Then I should not see "Not enough funds"

    When I click on "Send the transaction"
    Then I should see "Transaction sent"
    And these amounts should have been sent from the account of the project:
      | address                            | amount |
      | mxWfjaZJTNN5QKeZZYQ5HW3vgALFBsnuG1 |  500.0 |
    And the project balance should be "0.00"
