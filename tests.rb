require_relative 'secretsanta'

TEST_ITERATIONS = 1000

PARTICIPANTS =  [
  { name: 'A', exclusions: ['B','C'], phone_number: "555-555-5555" },
  { name: 'B', exclusions: ['A','C'], phone_number: "555-555-5555" },
  { name: 'C', exclusions: ['D','A'], phone_number: "555-555-5555" },
  { name: 'D', exclusions: ['C','G'], phone_number: "555-555-5555" },
  { name: 'E', exclusions: ['F'], phone_number: "555-555-5555" },
  { name: 'F', exclusions: ['G','D'], phone_number: "555-555-5555" },
  { name: 'G', exclusions: ['F','B'], phone_number: "555-555-5555" },
  { name: 'H', exclusions: ['E'], phone_number: "555-555-5555" },
]

def assert actual, expected
  fail "expected: #{expected}, got: #{actual}" if actual != expected
end

def refute actual, expected
  fail "did not expect: #{expected}, got: #{actual}" if actual == expected
end

def run_tests iterations

  #iterates in order to check random input. adjust number of tests at method call.
  iterations.times do

    #testing dependency
    participants = SecretSanta.assign_all(PARTICIPANTS)

    #correct number of participants
    assert(participants.length, PARTICIPANTS.length)

    PARTICIPANTS.each do |participant_hash|
      name, exclusions = participant_hash.values_at(:name, :exclusions)
      participant  = participants.find { |participant| participant.name == name }
      secret_santa = participants.find { |participant| participant.assignment.name == name }

      # all participants should have an assignment
      assert participant.nil?, false

      # all participants should be someone else's assignment
      assert secret_santa.nil?, false

      # no individual is assigned to someone who has been explicitly excluded
      assert exclusions.include?(participant.assignment.name), false

      # no inidividual is assigned to themselves
      refute name, participant.assignment.name

      # no individual is assigned to the person assigned to them
      refute name, participant.assignment.assignment.name
    end
  end
end

run_tests(TEST_ITERATIONS)

puts "all tests passed"
