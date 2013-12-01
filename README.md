Rao Secret Santa is an application for organizing a secret santa. 

Implementation in Ruby 1.9.3 using the Twilio REST API. 

Development Setup
---

install the dependencies:

```
gem install twilio-ruby
gem install dotenv
```

load .env file with a TWILIO_AUTH, TWILIO_SID, and TWILIO_NUMBER
(a phone number from which you want to send texts)

make sure your Twilio account is adequately funded to send SMS messages 
to unverified numbers or that all numbers are verified. 

SecretSanta module is now ready to use in a secondary ruby file. 

run tests using the following command:

```
ruby tests.rb
```
alter TEST_ITERATIONS value if you would like tests to complete faster. 



