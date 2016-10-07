# 6. specs 
# 7. cache helper -----------

class WikiService
  require 'icalendar'
	require 'nickel'

  def initialize(params)
    @cal = Calendar.find_by_url(params[:url]) || Calendar.new({url: params[:url]})
  end

	def create_calendar_of_episodes(force = false)
    if force || !@cal.ical
      ical = create_icalendar
      body = curl_wikipedia
      episodes = parse_episodes(body)
      @cal.title = title(body)
      add_events_to_calendar(ical, @cal.title, episodes)
      @cal.ical = ical.to_ical.gsub('icalendar-ruby', '-//Google Inc//Google Calendar 70.9054//EN')
    end
    @cal.queried_at = DateTime.now
    @cal.save!
    return @cal.ical
  end

  def create_icalendar
  	return Icalendar::Calendar.new
  end

  def title(body)
    return body.css('#firstHeading i').first.content
  end

  def curl_wikipedia
    require 'curb'
    #curl the wiki
    c = Curl::Easy.perform(@cal.url)
    #parse the body
    return Nokogiri::HTML(c.body_str)
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

    #for each table of episodes
    body.css('.wikiepisodetable').each do |season|
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
    date_string = episode["Original air date"] || episode["Original release date"] || episode["Airdate"]
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

  def create_calendar_event(cal, date, summary, past = true)
      #create a calendar event for each episode
      if date && (past || date >= Date.today)
        event = Icalendar::Event.new
        event.dtstart = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
        event.dtend = Icalendar::Values::DateOrDateTime.new(date.strftime("%Y%m%d")).call
        event.summary = summary
        cal.add_event(event)
      end
  end

end