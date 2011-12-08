$ ->
  $('form').bind 'nested:fieldAdded', (e) ->
    if e.field.parent().hasClass('address')
      e.field.children().last('hr').remove()
      $('#add_address').remove()