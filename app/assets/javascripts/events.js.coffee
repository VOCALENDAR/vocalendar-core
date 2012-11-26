# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ($) ->
  bind_datetime_picker = ->
    opts = { dateFormat: "yy-mm-dd", stepMinute: 5 }
    $("#release_event_start_date, #event_start_date").datetimepicker $.extend({}, opts, {
        altField: "#release_event_start_time, #event_start_time"
    })
    $("#release_event_end_date, #event_end_date").datetimepicker $.extend({}, opts, {
        altField: "#release_event_end_time,  #event_end_time"
    })
    $(".time-input").show()

  bind_date_picker = ->
    $(".date-input").datepicker()
    $(".time-input").hide().val('')

  bind_picker_by_allday = ->
    $(".date-input").datepicker "destroy"
    $(".date-input").datetimepicker "destroy"
    if $("#release_event_allday, #event_allday").attr('checked')
      bind_date_picker()
    else
      bind_datetime_picker()

  $("#release_event_allday, #event_allday").on 'change', bind_picker_by_allday
  bind_picker_by_allday()
