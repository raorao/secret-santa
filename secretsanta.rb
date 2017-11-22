require 'twilio-ruby'
require 'dotenv'

module SecretSanta
  class NoValidAssignment < StandardError; end;

  extend self

  # input of assign_all expected as hash. Each key in hash is a unique name,
  # each value is another hash. the interior can optionally include an array
  # with the key 'exclude', specifying those participants tho which the given
  # individual will not be assigned.
  #
  # @param [Hash{String => Hash}] participants with options. e.g. `{ 'A' => { exclude: ['B','C'] } }`
  # @return [Hash{String => String}] givers and getters. e.g. `{ 'A' => 'D' }`
  def assign_all participants
    participants.each_with_object({}) do |entry, assignments|
      participant, information = entry
      assignments[participant] = assign participant, information, participants, assignments
    end

  rescue NoValidAssignment
    assign_all participants
  end

  # input of send_all_assignments is two hashes, both with giver names as keys.
  # the assignments hash points to getter names, the phone_numbers hash points
  # to valid phone numbers that can receive text messages.

  # @param [Hash{String => String}] givers and getters. e.g. `{ 'A' => 'D' }`
  # @param [Hash{String => String}] lookup table of phone numbers. e.g. `{ 'A' => "555-867-5309" } }`
  def send_all_assignments assignments, phone_numbers
    assignments.each do |giver, getter|
      send_assignment giver, getter, phone_numbers[giver]
    end
  end

  # input of send_backup_message is the assignment hash of giver key values
  # and getter values, as well as a phone number to receive the message.

  # @param [Hash{String => String}] givers and getters. e.g. `{ 'A' => 'D' }`
  # @param [String] number to contact. e.g. `"555-867-5309"`
  def send_backup_message assignments, phone_number
    message = "here are the secret santa assignments:\n"
    assignments.each do |giver, getter|
      message += "#{giver} has #{getter}\n"
    end

    send_message message, phone_number
    puts "a backup of all assignments has been sent to #{phone_number}"
  end

  private

  def assign giver, information, participants, assignments
    remaining = participants.keys - assignments.values
    remaining -= information[:exclude]
    remaining.delete giver
    remaining.delete assignments.invert[giver]
    raise NoValidAssignment if remaining.empty?

    remaining.sample
  end

  def send_assignment giver, getter, phone_number
    message = "Hey #{giver}, you are #{getter}'s secret santa"
    send_message message, phone_number
    puts "#{giver} has received a text message at #{phone_number}"
  end

  def send_message message, phone_number
    Dotenv.load
    client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']

    client.account.messages.create(
      :from => ENV['TWILIO_NUMBER'],
      :to => phone_number,
      :body => message
    )
  end

end


