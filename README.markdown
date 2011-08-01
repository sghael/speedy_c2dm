# c2dm

c2dm sends push notifications to Android devices via google [c2dm](http://code.google.com/android/c2dm/index.html).

# How is this GEM different than other C2DM gems?

To use C2DM the server needs to fetch and store authenticaion tokens from Google.  This token will periodically expire, and the recommendation from Google is that "the server should store the token and have a policy to refresh it periodically."   Other C2DM gems take a brute force method around this issue, by requesting a new authenticaion token from Google for *each* notification request they send.  This effectively doubles the number of HTTP calls being made for each notification.  

This GEM will request the token when the SpeedyC2DM::API class is first initialized.  From then on, it will use the auth token stored as an instance variable.  On subsequent notification calls, it will check for 'Update-Client-Auth' or check for status 401 (auth failed).  When it detects either of these, it will then request new tokens from Google servers.  In the case of status 503 (service unavailable), a return message indicating 503 is returned.  It is suggested that you retry after exponential back-off in the case of 503 (using something like resque-retry).

##Installation

    $ gem install speedy_c2dm
    
##Requirements

An Android device running 2.2 or newer, its registration token, and a google account registered for c2dm.

##Usage

c2dm = SpeedyC2DM::API.new(TEST_EMAIL, TEST_PASSWORD)

options = {
  :registration_id => TEST_REGISTRATION_ID,
  :message => "Hi!",
  :extra_data => 42,
  :collapse_key => "some-collapse-key"
}

response = c2dm.send_notification(options)

##Copyrights

* See LICENSE.txt for details.
