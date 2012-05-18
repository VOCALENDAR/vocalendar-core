# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#  calendar = Calendar.create(:calendar => "vocalendar-editor@gmail.com", :name => "ボカレンダー", )

#  calendar.events.create( :kind => "Calendar#event",
#                          :event => "testeventid.vocalendar-editor@gmail.com",
#                          :htmlLink => "http://google.com/",
#                          :summary => "テストデーーータ",
#                 )

  calendar = Calendar.find(1)
  calendar.events.create( :kind => "Calendar#event",
                          :event => "testeventid.vocalendar-editor@gmail.com",
                          :htmlLink => "http://google.com/",
                          :summary => "テストデーーータ２
                          ",
                 )
