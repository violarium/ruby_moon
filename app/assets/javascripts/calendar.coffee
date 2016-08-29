$(document).on('change', '#calendar_day_form_is_critical', ->
  if this.checked
    $('#delete-period-block').slideUp()
  else
    $('#delete-period-block').slideDown()
)

$(document).on('click', '#delete-period-cancel', ->
  $('#calendar_day_form_critical_day').click()
)