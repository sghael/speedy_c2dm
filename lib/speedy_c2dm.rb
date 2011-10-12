require "speedy_c2dm/version"
require "net/http"

module SpeedyC2DM

  class API
    AUTH_URL = 'https://www.google.com/accounts/ClientLogin'
    PUSH_URL = 'https://android.apis.google.com/c2dm/send'

    class << self

      def set_account(email, password)
        @email = email
        @password = password
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
        get_auth_token(@email, @password) unless @auth_token

        response = notificationRequest(options)

        # the response can be one of three codes:
        #   200 (success)
        #   401 (auth failed)
        #   503 (retry later with exponential backoff)
        #   see more documentation here:  http://code.google.com/android/c2dm/#testing
        if response.code.eql? "200"

          # look for the header 'Update-Client-Auth' in the response you get after sending
          # a message. It indicates that this is the token to be used for the next message to send.
          response.each_header do |key, value|
            if key == "Update-Client-Auth"
              @auth_token = value
            end
          end

          return response.body

        elsif response.code.eql? "401"

          # auth failed.  Refresh auth key and requeue
          @auth_token = get_auth_token(@email, @password)

          response = notificationRequest(options)

          return response.inspect

        elsif response.code.eql? "503"

          # service un-available.
          return response.inspect

        end
      end

      def get_auth_token(email, password)
        data = "accountType=HOSTED_OR_GOOGLE&Email=#{email}&Passwd=#{password}&service=ac2dm"
        headers = { "Content-type" => "application/x-www-form-urlencoded",
                    "Content-length" => "#{data.length}"}

        uri = URI.parse(AUTH_URL)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        response, body = http.post(uri.path, data, headers)
        return body.split("\n")[2].gsub("Auth=", "")
      end

      def notificationRequest(options)
        data = {}
        options.each do |key, value|
          if [:registration_id, :collapse_key].include? key
            data[key] = value
          else
            data["data.#{key}"] = value
          end
        end

        data = data.map{|k, v| "&#{k}=#{URI.escape(v.to_s)}"}.reduce{|k, v| k + v}
        headers = { "Authorization" => "GoogleLogin auth=#{@auth_token}",
                    "Content-length" => "#{data.length}" }
        uri = URI.parse(PUSH_URL)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        http.post(uri.path, data, headers)
      end

    end
  end
end
