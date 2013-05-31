require "icalendar"

# This example shows how streaming can be used to push large amounts of data
# to the client without taking up a lot of memory.
#
# With both examples the server starts at about 32Mb of memory.
# The streaming example caps at about 55Mb.
# The built example caps at about 230Mb.
#
# The trade off in this case is one of time. The difference is likely due to
# garbage collection. Number below are for MRI, using jruby we see both drop
# to about 22s once the JVM has had a chance to start optimizing.
# Streaming fully renders in about 36s.
# The traditional version takes 27s.
class CalendarsController < ApplicationController
  include ActionController::Live

  ENTRIES = 50000

  def show
    # lulz... don't ever do this
    send(params[:id])
  end

  private

  def streamed
    # response.headers['Content-Type'] = "text/calendar"
    response.headers['Content-Type'] = "text/plain"

    # Write a custom header since we're rendering individual calendar entries
    # instead of using the full DSL.
    response.stream.write("BEGIN:VCALENDAR\r\n")
    response.stream.write("VERSION:2.0\r\n")
    response.stream.write("CALSCALE:GREGORIAN\r\n")
    response.stream.write("PRODID:iCalendar-Ruby\r\n")

    ENTRIES.times do
      event = ::Icalendar::Event.new
      event.start   = DateTime.now
      event.summary = "SO AWESOME"

      response.stream.write(event.to_ical)
    end

    # Close out the calendar
    response.stream.write("END:VCALENDAR\r\n")

  ensure
    response.stream.close
  end

  def built
    # response.headers['Content-Type'] = "text/calendar"
    response.headers['Content-Type'] = "text/plain"

    calendar = ::Icalendar::Calendar.new

    ENTRIES.times do
      calendar.event do |event|
        event.start   = DateTime.now
        event.summary = "SO AWESOME"
      end
    end

    render :text => calendar.to_ical
  end
end
