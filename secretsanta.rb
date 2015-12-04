require 'twilio-ruby'
require 'dotenv'

#input of assign_all expected as hash. Each key in hash is a unique name,
#each value is another hash. the interior can optionally include an array
#with the key 'exclude', specifying those participants tho which the given
# individual will not be assigned.

#output of assign_all is a hash of participant names, with the key being
#the gift giver and the value being the assigned gift giver.

#input of send_all_assignments is two hashes, both with giver names as keys.
#the assignments hash points to getter names, the phone_numbers hash points
#to valid phone numbers that can receive text messages.

#input of send_backup_message is the assignment hash of giver key values
#and getter values, as well as a phone number to receive the message.

module SecretSanta
  class NoValidAssignment < StandardError; end;

  extend self

  def assign_all participants
    assignments = {}
    participants.each do |participant,information|
      getter = assign participant, information, participants, assignments
      assignments[participant] = getter
    end

    return assignments

  rescue NoValidAssignment
    assign_all participants
  end

  def send_all_assignments assignments, phone_numbers
    assignments.each do |giver, getter|
      send_assignment giver, getter, phone_numbers[giver]
    end
  end

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


