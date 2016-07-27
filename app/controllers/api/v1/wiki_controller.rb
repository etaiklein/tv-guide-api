module Api::V1
  class WikiController < ApplicationController
    MIN_CAL_LENGTH = 88

    def index
      cal = WikiService.new(params).create_calendar_of_episodes

      if cal.length > MIN_CAL_LENGTH
        render json: cal.to_json
      else 
        render json: "no future episodes found"
      end
    end

  end
end
