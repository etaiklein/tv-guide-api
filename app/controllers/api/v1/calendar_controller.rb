module Api::V1
  class CalendarController < ApplicationController

    def show
      cal = Calendar.find_by_title(params[:title])
      if cal
        render json: cal.ical.to_json
      else
        render json: "no future episodes found"
      end
    end

  end
end
