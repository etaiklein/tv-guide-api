module Api::V1
  class WikiController < ApplicationController

    def index
      cal = WikiService.new(params).create_calendar_of_episodes
      render plain: cal
    end

  end
end
