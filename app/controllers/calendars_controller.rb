class CalendarsController < ApplicationController
  include VocalendarCore::HistoryUtils::Controller

  # skipしてOK？
  load_and_authorize_resource except: [:create]

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
    pp create_params
    @calendar = Calendar.new(create_params)
    @calendar.save
    @calendar.errors.empty? and add_history
    respond_with @calendar, :location => calendars_path
  end

  # PUT /calendars/1
  # PUT /calendars/1.json
  def update
    @calendar.update(update_params)
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

  private
    def update_params
      if current_user.admin?
        return params.require(:calendar).permit(:name, :user_id, :io_type, :tag_names_append_str, :tag_names_remove_str)
      end
      params.require(:calendar).permit(:name, :io_type, :tag_names_append_str, :tag_names_remove_str)

    end

  def create_params
    if current_user.admin?
      return params.require(:calendar).permit(:name, :user_id, :external_id, :io_type, :tag_names_append_str, :tag_names_remove_str, tag_ids:[])
    end
    params.require(:calendar).permit(:name, :external_id, :io_type, :tag_names_append_str, :tag_names_remove_str, tag_ids:[])

  end

end
