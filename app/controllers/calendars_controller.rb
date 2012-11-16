class CalendarsController < ApplicationController
  # GET /calendars
  # GET /calendars.json
  def index
    @calendars = Calendar.all
    respond_with @calendars
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
    @calendar = Calendar.find(params[:id])
    respond_with @calendar
  end

  # GET /calendars/new
  # GET /calendars/new.json
  def new
    @calendar = Calendar.new
    respond_with @calendar
  end

  # GET /calendars/1/edit
  def edit
    @calendar = Calendar.find(params[:id])
  end

  # POST /calendars
  # POST /calendars.json
  def create
    @calendar = Calendar.new(params[:calendar], :as => current_user.role)
    @calendar.save
    respond_with @calendar, :location => calendars_path
  end

  # PUT /calendars/1
  # PUT /calendars/1.json
  def update
    @calendar = Calendar.find(params[:id])
    @calendar.update_attributes(params[:calendar], :as => current_user.role)
    respond_with @calendar, :location => calendars_path
  end

  # DELETE /calendars/1
  # DELETE /calendars/1.json
  def destroy
    @calendar = Calendar.find(params[:id])
    @calendar.destroy
    respond_with @calendar
  end
end
