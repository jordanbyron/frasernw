$ ->
  $('form').bind 'nested:fieldAdded', (e) ->
    if e.field.parent().hasClass('office')
      e.field.children().last('hr').remove()
      $('#add_office').remove()