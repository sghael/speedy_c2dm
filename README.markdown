# Speedy C2DM

Speedy C2DM sends push notifications to Android devices via Google's [c2dm](http://code.google.com/android/c2dm/index.html) (Cloud To Device Messaging).

Pull requests are welcome!

# How is this GEM different than other C2DM gems?

To use C2DM, your application server needs to fetch and store an authentication token from Google.  This token will periodically expire and the recommendation from Google is that "the server should store the token and have a policy to refresh it periodically."   Other C2DM gems take a brute force approach around this issue by requesting a new authenticaion token from Google for *each* notification request they send.  This effectively doubles the number of HTTP calls being made for each C2DM notification sent.

This GEM will request the token when the SpeedyC2DM::API.send_notification() class method is first called.  From then on, calls to SpeedyC2DM::API.send_notification() will use the auth token stored in the class instance variable.  On subsequent notification calls, the object will check for 'Update-Client-Auth' or check for status 401 (auth failed).  If it detects either the 401 or an 'Update-Client-Auth' header, speedy_c2dm will immediately request new tokens from Google.  In the case of status 503 (service unavailable), a return message indicating 503 is returned from the send_notification() call.  It is suggested (by Google) that you retry after exponential back-off in the case of 503.  Using something like [resque-retry](https://github.com/lantins/resque-retry) would work well in this case.

##Installation

    $ gem install speedy_c2dm
    
##Requirements

An Android device running 2.2 or newer, its registration token, and a Google account registered for c2dm.

##Compatibility

Speedy_C2DM will work with Rails 3.x & Ruby 1.9x.  It has not been tested on previous versions or Rails or Ruby, and may or may not work with those versions.

##Backwards Compatibility

v1.0.0 is not backwards compatible with previous version.  If you are migrating from a version prior to v1.0.0 please see the new usage instructions below.

##Usage

For a Rails app, a good place to put the following would be in config/initializers/speedy_c2dm.rb :

    C2DM_API_EMAIL = "myemail@gmail.com"
    C2DM_API_PASSWORD = "mypassword"

    SpeedyC2DM::API.set_account(C2DM_API_EMAIL, C2DM_API_PASSWORD)

Then, where you want to make a C2DM call in your code, create an options hash and pass it to send_notification():

    options = {
      :registration_id => SOME_REGISTRATION_ID,
      :message => "Hi!",
      :extra_data => 42,
      :collapse_key => "some-collapse-key"
    }

    response = SpeedyC2DM::API.send_notification(options)

Note:  there are blocking calls in both .new() and .send_notification().  You should use an async queue like [Resque](https://github.com/defunkt/resque) to ensure a non-blocking code path in your application code, particularly for the .send_notification() call.


##Testing

To test, first fill out these variables in test/test_speedy_c2dm.rb:

    API_ACCOUNT_EMAIL = "TODO - Your C2DM account email"
    API_ACCOUNT_PASSWORD = "TODO - Your C2DM account password"
    TEST_PHONE_C2DM_REGISTRATION_ID = "TODO - Some C2DM registration id you want to test push notification to"

then run:

  	$ ruby test/test_speedy_c2dm.rb

##Copyrights

* See LICENSE.txt for details.
