# 6. specs 
# 7. cache helper -----------

class WikiService
  require 'icalendar'
	require 'nickel'

  def initialize(params)
    @cal = Calendar.find_by_url(params[:url]) || Calendar.new({url: params[:url]})
  end

  def create_calendar_of_episodes(force = false)
    query = Query.new(query: @cal.url)
    begin
      if force || !@cal.ical
        ical = create_icalendar
        body = curl_wikipedia
        episodes = parse_episodes(body)
        @cal.title = title(body)
        add_events_to_calendar(ical, @cal.title, episodes)
        @cal.ical = ical.to_ical.gsub('icalendar-ruby', '-//Google Inc//Google Calendar 70.9054//EN')
      end
      @cal.queried_at = query.created_at
      @cal.save!
      query.status = "success"
      return @cal.ical
    rescue => error
      query.status = "failure"
      info = @cal.url + " failed: "
      Rails.logger.info(info + error.to_s)
      raise info + error.to_s
    ensure
      query.save!
    end
  end

  def create_icalendar
    return Icalendar::Calendar.new
  end

  def title(body)
    return body.css('#firstHeading i').first.try(:content)
  end

  def curl_wikipedia
    require 'curb'
    #curl the wiki
    curl = Curl::Easy.perform(@cal.url)
    #parse the body
    return Nokogiri::HTML(curl.body_str)
  end

  def add_events_to_calendar(cal, title, episodes)
    episodes.each do |episode|
      date = episode_date(episode)
      summary = event_title(episode, title)
      create_calendar_event(cal, date, summary)
    end
  end

  def parse_episodes(body)
    #we don't need season information, so we'll just track episodes
    episodes = []

    tables = body.css('.wikiepisodetable').length > 1 ? body.css('.wikiepisodetable') : body.css('.wikitable')

    #for each table of episodes
    tables.each do |season|
    	#grab the headers of the table
      headers = season.css('tr:nth-child(1) th').map(&:content)
      #grab each row of the table
      episode_data = season.css('.vevent th, .vevent td').map(&:content)
      
      #reconstruct the episode object from the table
      while episode_data.length > 0
        episode = {}
        headers.each {|h| episode[h] = episode_data.shift} 
        episodes.push(episode)
      end
    end

    return episodes
  end

  #TODO: test by locale.
  def episode_date(episode)
    date_string = episode["Original air date"] || episode["Original release date"] || episode["Airdate"] || episode["Original airdate"]
    begin
      return Nickel.parse(date_string).occurrences[0].start_date.to_date
    rescue ArgumentError, NoMethodError
    	puts "invalid episode date " + date_string.to_s
    end
    return nil

  end

  def event_title(episode, title)
    return "#{title}#{" " + episode["No.\noverall"] if episode["No.\noverall"]}: #{episode["Title"]}"
  end

  def create_calendar_event(cal, date, summary, allow_past = true)
      #create a calendar event for each episode
      if date && (allow_past || date >= Date.today)
        event = Icalendar::Event.new
        event.dtstart = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
        event.dtend = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
        event.summary = summary
        cal.add_event(event)
      end
  end

end