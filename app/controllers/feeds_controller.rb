require "redis"

class FeedsController < ApplicationController
  include ActionController::Live

  def index
    response.headers['Content-Type'] = "application/json"

    # Using redis pub/sub for an easy example. See bin/publisher for the
    # publishing code.
    redis = Redis.new

    # Subscribe is a blocking call and won't return. 
    redis.subscribe("message.bus") do |on|
      on.message do |channel, message|
        # We can just write the message as given from the publisher since we
        # know it's a JSON string.
        begin
          response.stream.write(message)
          response.stream.write("\n")

        # IOError is raised when trying to write to the stream after the client
        # has closed their end of the connection. It may not be reached
        # immediately after the client closes. Here it may take up to 5 seconds
        # due to how often the publisher writes data.
        rescue IOError
          redis.unsubscribe
        end
      end
    end

    response.stream.close
  end
end
