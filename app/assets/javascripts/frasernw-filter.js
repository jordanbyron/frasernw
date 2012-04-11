var update_specialist_table = function() {
  
  var current_filters = new Array();
  var procedures = new Array();
  var languages = new Array();
  var sex = '';
  
  // collect procedure filters
  $('.filter-group-content > label > .sp, .filter-group-content > .more > label > .sp').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {  
      var parent_text = $this.parent().text().trim();
      var checked_children = false;
      $('.child_' + $this.attr('id')).each( function() {
        var $this = $(this);
        if ($this.prop('checked'))
        {
          checked_children = true;
          procedures.push(parent_text + " " + $this.parent().text().trim());
          current_filters.push($this.attr('id'));
        }
      });
      if (!checked_children)
      {
        procedures.push($this.parent().text().trim());
        current_filters.push($this.attr('id'));
      }
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
  description += '.';
  
  if ( !found )
  {
    description += " <a href='javascript:clear_specialist_filters()'>Clear all filters</a>";
  }
  
  var specialist_phrase = $('#specialist_phrase');
  specialist_phrase.html(description);
  found ? specialist_phrase.removeClass('none') : specialist_phrase.addClass('none');
  current_filters.length == 0 ? specialist_phrase.hide() : specialist_phrase.show();
}

var update_clinic_table = function() {
  var current_filters = new Array();
  var procedures = new Array();
  var languages = new Array();
  
  // collect procedure filters
  $('.filter-group-content > label > .cp, .filter-group-content > .more > label > .cp').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {  
      var parent_text = $this.parent().text().trim();
      var checked_children = false;
      $('.child_' + $this.attr('id')).each( function() {
        var $this = $(this);
        if ($this.prop('checked'))
        {
          checked_children = true;
          procedures.push(parent_text + " " + $this.parent().text().trim());
          current_filters.push($this.attr('id'));
        }
      });
      if (!checked_children)
      {
        procedures.push($this.parent().text().trim());
        current_filters.push($this.attr('id'));
      }
    }
  });
  
  // collect language filters
  $('.cl').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      languages.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  var found = false;
             
  //loop over each row of the table, hiding those which don't match our filters
  $('#clinic_table tbody tr').each(function () {
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
  
  var description = found ? 'Showing all clinics' : 'There are no clinics';
  
  if ( procedures.length >= 1 && languages.length >= 1 ) 
  {
    description += ' which practice in ' + procedures.to_sentence() + ' and have staff that speak ' + languages.to_sentence();
  }
  else if ( procedures.length >= 1 ) 
  {
    description += ' which practice in ' + procedures.to_sentence();
  }
  else if ( languages.length >= 1 ) 
  {
    description += ' which have staff that speak ' + languages.to_sentence();
  }
  description += '.';
  
  if ( !found )
  {
    description += " <a href='javascript:clear_clinic_filters()'>Clear all filters</a>";
  }
  
  var clinic_phrase = $('#clinic_phrase');
  clinic_phrase.html(description);
  found ? clinic_phrase.removeClass('none') : clinic_phrase.addClass('none');
  current_filters.length == 0 ? clinic_phrase.hide() : clinic_phrase.show();
}

var clear_specialist_filters = function() {
  // clear procedure filters
  $('.sp').each( function() {
    if ($(this).prop('checked'))
    {
      $(this).trigger('click');
    }
  });
  
  // clear language filters
  $('.sl').each( function() {
    $(this).prop('checked',false)
  });
  
  // collect sex filters
  $('#ssm').prop('checked', false);
  $('#ssf').prop('checked', false);
  
  update_specialist_table();
}

var clear_clinic_filters = function() {
  // clear procedure filters
  $('.cp').each( function() {
    if ($(this).prop('checked'))
    {
      $(this).trigger('click');
    }
  });
  
  // clear language filters
  $('.cl').each( function() {
    $(this).prop('checked',false)
  });
  
  update_clinic_table();
}
