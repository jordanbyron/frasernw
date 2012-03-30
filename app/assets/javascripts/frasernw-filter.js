var update_specialist_table = function() {
  
  var current_filters = new Array();
  var procedures = new Array();
  var languages = new Array();
  var sex = '';
  
  // collect procedure filters
  $('.sp').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      procedures.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  // collect language filters
  $('.sl').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      languages.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  // collect sex filters
  if ( $('#ssm').prop('checked') && !$('#ssf').prop('checked') )
  {
    current_filters.push('ssm');
    sex = 'male'
  }
  else if ( !$('#ssm').prop('checked') && $('#ssf').prop('checked') )
  {
    current_filters.push('ssf');
    sex = 'female'
  }
  
  var found = false;
             
  //loop over each row of the table, hiding those which don't match our filters
  $('#specialist_table tbody tr').each(function () {
    var row = $(this)
      , row_filter = row.data('filter');
    if (current_filters.length == 0)
    {
      found = true;                   
      row.show();
      return true;
    }
    else if (!row_filter)
    {
      row.hide();
      return true;
    }
                                       
    var show = true;
    for (var i = 0; i < current_filters.length; ++i)
    {
      if (row_filter.indexOf(current_filters[i]) == -1)
      {
        show = false;
        break;
      }
    }
    
    if (show)
    {
      found = true; 
      row.show();
    }
    else
    {
      row.hide();
    }  
  });
  
  //generate string
  var description = found ? 'Showing all ' + sex + ' specialists' : 'There are no ' + sex + ' specialists';
  
  if ( procedures.length >= 1 && languages.length >= 1 ) 
  {
    description += ' who practice in ' + procedures.to_sentence() + ' and work in an office that speaks ' + languages.to_sentence();
  }
  else if ( procedures.length >= 1 ) 
  {
    description += ' who practice in ' + procedures.to_sentence();
  }
  else if ( languages.length >= 1 ) 
  {
    description += ' who work in an office that speaks ' + languages.to_sentence();
  }
  
  $('#specialist_phrase').html(description);
  found ? $('#specialist_phrase').removeClass('none') : $('#specialist_phrase').addClass('none');
}