module Api::V1
  class WikiController < ApplicationController

    def index
      require 'curb'
      require 'icalendar'
      cal = Icalendar::Calendar.new

      #curl the wiki
      c = Curl::Easy.perform(params[:url])
      #parse the body
      body = Nokogiri::HTML(c.body_str)

      num = 0

      body.css('.wikiepisodetable th').each do |episode| 
        data = episode
        summary = ""
        date = nil
        #grab metadata for each episode
        while (data) do
          content = data.content
          data = data.next_sibling
          summary += content

          begin
            potential_date = Date.strptime(content, '%B %d, %Y')
            date = potential_date
          rescue ArgumentError
            next
          end

        end

        #create a calendar event for each episode
        if date
          event = Icalendar::Event.new
          event.dtstart = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
          event.dtend = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
          event.summary = summary
          cal.add_event(event)
          puts "ELEMENT #{num += 1} + #{date}" if date
          puts summary
        end

      end

      cal.publish

      render json: cal.to_ical.to_json
    end

  end
end