class CalendarsController < ApplicationController
  include VocalendarCore::HistoryUtils::Controller
  load_and_authorize_resource

  # GET /calendars
  # GET /calendars.json
  def index
    respond_with @calendars
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
    respond_with @calendar
  end

  # GET /calendars/new
  # GET /calendars/new.json
  def new
    respond_with @calendar
  end

  # GET /calendars/1/edit
  def edit
  end

  # POST /calendars
  # POST /calendars.json
  def create
    @calendar = Calendar.new(params[:calendar], :as => current_user.role)
    @calendar.save
    @calendar.errors.empty? and add_history
    respond_with @calendar, :location => calendars_path
  end

  # PUT /calendars/1
  # PUT /calendars/1.json
  def update
    @calendar.update_attributes(params[:calendar], :as => current_user.role)
    @calendar.errors.empty? and add_history
    respond_with @calendar, :location => calendars_path
  end

  # DELETE /calendars/1
  # DELETE /calendars/1.json
  def destroy
    @calendar.destroy
    add_history
    respond_with @calendar
  end
end
