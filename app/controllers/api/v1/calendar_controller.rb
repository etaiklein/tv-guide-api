module Api::V1
  class CalendarController < ApplicationController

    def show
      cal = Calendar.find_by_title(params[:title])
      query = Query.new(query: params[:title])
      if cal
        query.status = "success"
        cal.queried_at = query.created_at
        cal.save()
        render plain: cal.ical
      else
        query.status = "failure"
        render json: "You found a new show! Enter in a wiki url for it like 'https://en.wikipedia.org/wiki/List_of_Steven_Universe_episodes'!"
      end
      query.save!
    end

    def recent
      render json: Calendar.where("length(ical) > 120").order(queried_at: :desc).pluck(:title).take(10)
    end
  end
end
