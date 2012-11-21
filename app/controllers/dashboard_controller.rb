class DashboardController < ApplicationController
  authorize_resource :class => false
end
