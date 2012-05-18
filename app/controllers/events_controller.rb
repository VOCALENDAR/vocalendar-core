# coding: utf-8

class EventsController < ApplicationController
  def show

    @events = Event.all

  end
end
