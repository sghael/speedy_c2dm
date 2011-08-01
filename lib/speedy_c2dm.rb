require "speedy_c2dm/version"
require 'typhoeus'

module SpeedyC2DM
      
  class API
    AUTH_URL = 'https://www.google.com/accounts/ClientLogin'
    PUSH_URL = 'https://android.apis.google.com/c2dm/send'
    
    # Initialize with an API key and config options
    def initialize(email, password)
      @email = email
      @password = password

      @auth_token = get_auth_token(@email, @password)
    end

    def get_auth_token(email, password)
      post_body = "accountType=HOSTED_OR_GOOGLE&Email=#{email}&Passwd=#{password}&service=ac2dm"
      params = {
        :body => post_body,
        :headers => {
          'Content-type' => 'application/x-www-form-urlencoded',
          'Content-length' => "#{post_body.length}"
        }
      }
      response = Typhoeus::Request.post(AUTH_URL, params)
      return response.body.split("\n")[2].gsub("Auth=", "")      
    end

    # Send a notification
    #
    # :registration_id is required.
    # :collapse_key is optional.
    #
    # Other +options+ will be sent as "data.<key>=<value>"
    #
    # +options+ = {
    #   :registration_id => "...",
    #   :message => "Hi!",
    #   :extra_data => 42,
    #   :collapse_key => "some-collapse-key"
    # }
    def send_notification(options)
      request = requestObject(options)

      hydra = Typhoeus::Hydra.new
      hydra.queue request
      hydra.run # this is a blocking call that returns once all requests are complete
      
      # the response object will be set after the request is run
      response = request.response
      
      # the response can be one of three codes:  
      #   200 (success)
      #   401 (auth failed)
      #   503 (retry later with exponential backoff)
      #   see more documentation here:  http://code.google.com/android/c2dm/#testing
      if response.code.eql? 200

        # look for the header 'Update-Client-Auth' 
        # in the response you get after sending a message. It indicates that 
        # this is the token to be used for the next message to send.
        if response.headers_hash['Update-Client-Auth']
          @auth_token = get_auth_token(@email, @password)
        end
        return "success: 200"

      elsif response.code.eql? 401

        # auth failed.  Refresh auth key and requeue
        @auth_token = get_auth_token(@email, @password)
        hydra.queue request(options)
        hydra.run # this is a blocking call that returns once all requests are complete

        response_inner = request.response
        if response_inner.code.eql? 200
          return "success"
        elsif response_inner.code.eql? 401
          return "failed: 401 - auth failed"
        elsif response_inner.code.eql? 503
          return "failed: 503 - service unavailable"        
        end

      elsif response.code.eql? 503

        # service un-available.
        return "failed: 503 - service unavailable"

      end
    end
  
    def requestObject(options)
      payload = {}
      payload[:registration_id] = options.delete(:registration_id)
      payload[:collapse_key] = options.delete(:collapse_key)
      options.each {|key, value| payload["data.#{key}"] = value}

      Typhoeus::Request.new(PUSH_URL, {
        :method => :post,
        :params   => payload,
        :headers  => {
          'Authorization' => "GoogleLogin auth=#{@auth_token}"
        }
      })
    end
    
  end

end
