$ ->
  $('form').bind 'nested:fieldAdded', (e) ->
    if e.field.parent().hasClass('address')
      $('#add_address').remove()