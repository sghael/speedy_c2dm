current_dir = File.expand_path(File.dirname(__FILE__))
require File.join(current_dir, 'helper')

class TestSpeedyC2DM < Test::Unit::TestCase
    
  TEST_EMAIL = "TODO - Fill me"
  TEST_PASSWORD = "TODO - Fill me"
  INVALID_TEST_EMAIL = "foo-bar.com"
  TEST_REGISTRATION_ID = "TODO - Fill me"

  should "not raise an error if the API key is valid" do
    assert_nothing_raised do
      SpeedyC2DM::API.new(TEST_EMAIL, TEST_PASSWORD)
    end
  end
  
  should "raise an error if the email/password is not provided" do
    assert_raise(ArgumentError) do
      SpeedyC2DM::API.new()
    end
  end

  should "not raise an error if a send notification call succeeds" do
    assert_nothing_raised do
      speedyC2DM = SpeedyC2DM::API.new(TEST_EMAIL, TEST_PASSWORD)

      options = {
        :registration_id => TEST_REGISTRATION_ID,
        :message => "Hi!",
        :extra_data => 42,
        :collapse_key => "some-collapse-key"
      }

      response = speedyC2DM.send_notification(options)
    end
  end
      
end