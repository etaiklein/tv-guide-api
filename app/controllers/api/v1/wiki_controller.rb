module Api::V1
  class WikiController < ApplicationController

    def index
      cal = create_calendar_of_episodes(params[:url]).to_ical

      if cal.length > 88
        render json: cal.to_json
      else 
        render json: "no future episodes found"
      end
    end

    def create_calendar_of_episodes(url)
      cal = create_calendar()
      body = curl_wikipedia(url)
      create_events(cal, body)
      return cal
    end

    def create_calendar()
      require 'icalendar'
      cal = Icalendar::Calendar.new
      return cal
    end

    def curl_wikipedia(url)
      require 'curb'
      #curl the wiki
      c = Curl::Easy.perform(url)
      #parse the body
      return Nokogiri::HTML(c.body_str)
    end

    def create_events(cal, body)
      episodes = parse_episodes(body)

      episodes.each do |episode|
        
        date = episode_date(episode)
        title = body.css('#firstHeading i').first.content
        summary = event_title(episode, title)
        create_calendar_event(cal, date, summary)
      end
    end

    def parse_episodes(body)
      #we don't need season information, so we'll just track episodes
      episodes = []

      body.css('.wikiepisodetable').each do |season|
        headers = season.css('tr:nth-child(1) th').map(&:content)
        episode_data = season.css('.vevent th, .vevent td').map(&:content)
        
        while episode_data.length > 0
          episode = {}
          headers.map {|h| episode[h] = episode_data.shift()} 
          episodes.push(episode)
        end
      end

      return episodes
    end

    def episode_date(episode)
      begin
        date_string = episode["Original air date"]
        #remove all numbers after the year
        match = date_string.match(/(?<!\d)(?!0000)\d{4}(?!\d)/)
        stripped_string = date_string[0, match.end(0)]

        date = Date.parse(stripped_string)
        return date
      rescue ArgumentError, NoMethodError
      end
      return nil

    end

    def event_title(episode, title)
      return "#{title}#{" " + episode["No.\noverall"] if episode["No.\noverall"]}: #{episode["Title"]}"
    end

    def create_calendar_event(cal, date, summary)
        require 'icalendar'
        #create a calendar event for each episode
        if date && date >= Date.today
          event = Icalendar::Event.new
          event.dtstart = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
          event.dtend = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
          event.summary = summary
          cal.add_event(event)
        end
    end

  end
end
