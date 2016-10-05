module Api::V1
  class CalendarController < ApplicationController

    def show
      cal = Calendar.find_by_title(params[:title])
      if cal
        render plain: cal.ical
      else
        render json: "no future episodes found"
      end
    end

  end
end
