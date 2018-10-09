class ReleaseEventsController < EventsController
  load_and_authorize_resource :instance_name => 'event'
  def set_type_variable
    @type = 'ReleaseEvent'
  end
end
