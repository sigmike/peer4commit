Feature: Some funds are transfered to cold storage
  Background:
    Given a project
    And our fee is "0.01"
    And the project address is "mqEtf1CcGtAmoVRHENBVmBRpYppoEcA8LH"
    And the project cold storage withdrawal address is "n1g6mxaEpMb6cERcS4bGhmJPjxKc3msvni"
    And the cold storage addresses are
      | mpjDVmvCgsi2WW9qZJDQN6WgpDTP5iGbpD |
      | mr6HkUBp3iUqH6JuvD33banN4vZkifvTGD |

  Scenario: A project receives funds to its non cold storage address
    When there's a new incoming transaction of "50" to address "mqEtf1CcGtAmoVRHENBVmBRpYppoEcA8LH" on the project account
    And the project balance is updated
    Then the project balance should be "49.5"
    And the project amount in cold storage should be "0"

  Scenario: A project receives funds to its cold storage address
    When there's a new incoming transaction of "50" to address "n1g6mxaEpMb6cERcS4bGhmJPjxKc3msvni" on the project account
    And the project balance is updated
    Then the project balance should be "0"
    And the project amount in cold storage should be "-50"

  Scenario: A project receives funds to an unknown address
    When there's a new incoming transaction of "50" to address "mmoS6KKr4Q4v6VQcTQmSWGPgBS8mhJ9f74" on the project account
    Then updating the project balance should raise an error
    And the project balance should be "0"
    And the project amount in cold storage should be "0"

  Scenario: Some funds are sent to cold storage
    When there's a new outgoing transaction of "50" to address "mpjDVmvCgsi2WW9qZJDQN6WgpDTP5iGbpD" on the project account
    And the project balance is updated
    Then the project balance should be "0"
    And the project amount in cold storage should be "50"

  Scenario: Unconfirmed transactions are not counted
    When there's a new incoming transaction of "50" to address "mqEtf1CcGtAmoVRHENBVmBRpYppoEcA8LH" on the project account with 0 confirmations
    And there's a new incoming transaction of "10" to address "n1g6mxaEpMb6cERcS4bGhmJPjxKc3msvni" on the project account with 0 confirmations
    And there's a new outgoing transaction of "20" to address "mpjDVmvCgsi2WW9qZJDQN6WgpDTP5iGbpD" on the project account with 0 confirmations
    And the project balance is updated
    Then the project balance should be "0"
    And the project amount in cold storage should be "0"

  Scenario: Sending funds to cold storage
    When "50" coins of the project funds are sent to cold storage
    Then there should be an outgoing transaction of "50" to address "mpjDVmvCgsi2WW9qZJDQN6WgpDTP5iGbpD" on the project account

  Scenario: Cold storage withdrawal address is created at balance update time if it doesn't exist
    Given the project has no cold storage withdrawal address
    When the project balance is updated
    Then the project should have a cold storage withdrawal address
    And the project cold storage withdrawal address should be linked to its account
