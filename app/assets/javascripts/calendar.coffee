# Show and hide delete period way

$(document).on('change', '#calendar_day_form_is_critical', ->
  if this.checked
    $('#delete_period_block').slideUp()
  else
    $('#delete_period_block').slideDown()
)

# Cancel deleting period

$(document).on('click', '#delete_period_cancel', ->
  $('#calendar_day_form_is_critical').click()
)


# Calendar day value
$(document).on('change', '#calendar_day_form_is_critical', ->
  if this.checked
    $('#critical_day_value_block').slideDown()
  else
    $('#critical_day_value_block').slideUp()
)