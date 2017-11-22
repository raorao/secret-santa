require 'twilio-ruby'
require 'dotenv'

module SecretSanta
  class Participant
    attr_reader :name, :phone_number
    attr_accessor :assignment

    def initialize(name:, phone_number:, exclusions:)
      @name = name
      @phone_number = phone_number
      @exclusions = exclusions
      @assignment = nil
    end

    def ==(other)
      other.name == self.name
    end

    def valid?
      !invalid?
    end

    def invalid?
      assignment_is_excluded? || assignment_is_self? || assignment_is_circular?
    end

    def to_participant_message
      "Hey #{name}, you are #{assignment.name}'s secret santa"
    end

    def to_backup_message
      "#{name} has #{assignment.name}"
    end

    private

    attr_reader :exclusions

    def assignment_is_excluded?
      exclusions.include? assignment.name
    end

    def assignment_is_self?
      assignment == self
    end

    def assignment_is_circular?
      assignment.assignment == self
    end
  end

  extend self

  # produces assignments for secret santa. each entry in participant info must
  # look like this:
  #
  #  `{ name: 'A', exclusions: ['B','C'], phone_number: "555-555-5555" }`
  #
  # where exclusions denotes the participants that `A` cannot give presents to.
  #
  # @param [Array<Hash>] participant info.
  #   * :name [String] name of participant. must be unique.
  #   * :phone_number [String] phone number to contact, used by Twillio.
  #   * :exclusions [Array<String>] names of participants to which the individual cannot give presents.
  # @return [Array<Particpant>]
  def assign_all participants_hash
    participants = participants_hash.map { |info| Participant.new(info) }

    do_assign_all participants
  end

  # Send text messages to all participants with their assignment.
  #
  # @param [Array<Particpant>]
  def notify_participants participants
    participants.each do |participant|
      send_message participant.to_participant_message, participant.phone_number
      puts "#{participant.name} has received a text message at #{participant.phone_number}"
    end
  end

  # sends a backup message to a specified phone number with all assignments.

  # @param [Array<Particpant>]
  # @param [String] number to contact. e.g. `"555-867-5309"`
  def send_backup_message participants, phone_number
    intro = "here are the secret santa assignments:\n"
    message = intro + participants.map(&:to_backup_message).join("\n")

    send_message message, phone_number
    puts "a backup of all assignments has been sent to #{phone_number}"
  end

  private

  def do_assign_all(participants)
    new_participants = participants.
      shuffle.
      zip(participants).
      map { |giver, getter| giver.assignment = getter }

    new_participants.all?(&:valid?) ? new_participants : do_assign_all(participants)
  end

  def send_message message, phone_number
    # Dotenv.load
    # client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH']

    # client.account.messages.create(
    #   :from => ENV['TWILIO_NUMBER'],
    #   :to => phone_number,
    #   :body => message
    # )
  end

end


