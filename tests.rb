require_relative 'secretsanta'

TEST_ITERATIONS = 1000

PARTICIPANTS =  { 'A' => { exclude: ['B','C'] },
                  'B' => { exclude: ['A','C'] },
                  'C' => { exclude: ['D','A'] },
                  'D' => { exclude: ['C','G'] },
                  'E' => { exclude: ['F'] },
                  'F' => { exclude: ['G','D'] },
                  'G' => { exclude: ['F','B'] },
                  'H' => { exclude: ['E'] }
                }

def assert conditional
  raise "test failed" if !conditional
end

def run_tests iterations

  #iterates in order to check random input. adjust number of tests at method call.
  iterations.times do

    #testing dependency
    assignments = SecretSanta.assign_all(PARTICIPANTS)

    #correct number of assignments
    assert(assignments.length == PARTICIPANTS.length)

    #all participants should be asssigned as a giver and getter
    PARTICIPANTS.each do |giver, info|
      assert(assignments.keys.include?(giver))
      assert(assignments.values.include?(giver))
    end

    #no individual is assigned to someone who has been explicitly excluded
    PARTICIPANTS.each do |giver, info|
      if info[:exclude]
        info[:exclude].each do |exclusion|
          assert(assignments[giver] != exclusion)
        end
      end
    end

    #no inidividual is assigned to themselves
    PARTICIPANTS.each do |giver, info|
      assert(assignments[giver] != giver)
    end

    #no individual is assigned to the person assigned to them
    PARTICIPANTS.each do |giver, info|
      assert(assignments[assignments[giver]] != giver)
    end

  end

end

run_tests(TEST_ITERATIONS)

puts "all tests passed"
