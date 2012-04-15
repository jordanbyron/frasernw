var update_specialist_table = function() {
  
  var current_filters = new Array();
  var procedures = new Array();
  var referrals = new Array();
  var languages = new Array();
  var associations = new Array();
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
  
  // collect referral filters
  if ( $('#srph').prop('checked'))
  {
    current_filters.push('srph');
    referrals.push('accept referrals via phone');
  }
  $('.sc option:selected').each( function() {
    var $this = $(this);
    if ($this.val() != 0)
    {
      var text = $this.text().trim();
      text = text.charAt(0).toLowerCase() + text.slice(1);
                                console.log($this.val())
                                
      if ($this.val() == "sc1_")
      {
        referrals.push('respond to referrals by phone when office calls for appointment');
      }
      else if ($this.val() == "sc2_")
      {
        referrals.push('respond to referrals ' + text);
      }
      else
      {
        referrals.push('respond to referrals within ' + text);
      }
      current_filters.push($this.val());
    }
  });
  if ( $('#srpb').prop('checked'))
  {
    current_filters.push('srpb');
    referrals.push('patients can call to book after referral');
  }
  
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
  
  // collect language filters
  $('.sl').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      languages.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  // collect association filters
  $('.sa option:selected').each( function() {
    var $this = $(this);
    if ($this.val() != 0)
    {
      associations.push($this.text().trim());
      current_filters.push($this.val());
    }
  });
  
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
  
  var fragments = new Array()
  if ( procedures.length >= 1 )
  {
    fragments.push('practice in ' + procedures.to_sentence());
  }
  if ( referrals.length >= 1 )
  {
    fragments.push(referrals.to_sentence());
  }
  if ( languages.length >= 1 )
  {
    fragments.push('have staff that speak ' + languages.to_sentence());
  }
  if ( associations.length >= 1 )
  {
    fragments.push('are open on ' + days.to_sentence());
  }
  
  if ( fragments.length >= 1 )
  {
    description += ' which ' + fragments.to_sentence()
  }
  
  description += ". <a href='javascript:clear_specialist_filters()'>Clear all filters</a>."
  
  var specialist_phrase = $('#specialist_phrase');
  specialist_phrase.html(description);
  found ? specialist_phrase.removeClass('none') : specialist_phrase.addClass('none');
  current_filters.length == 0 ? specialist_phrase.hide() : specialist_phrase.show();
}

var update_clinic_table = function() {
  var current_filters = new Array();
  var procedures = new Array();
  var referrals = new Array();
  var details = new Array();
  var languages = new Array();
  var days = new Array();
  
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
  
  // collect referral filters
  if ( $('#crph').prop('checked'))
  {
    current_filters.push('crph');
    referrals.push('accept referrals via phone');
  }
  $('.cc option:selected').each( function() {
    var $this = $(this);
    if ($this.val() != 0)
    {
      var text = $this.text().trim();
      text = text.charAt(0).toLowerCase() + text.slice(1);
                                console.log($this.val())
                                
      if ($this.val() == "cc1_")
      {
        referrals.push('respond to referrals by phone when office calls for appointment');
      }
      else if ($this.val() == "cc2_")
      {
        referrals.push('respond to ' + text);
      }
      else
      {
        referrals.push('respond to referrals within ' + text);
      }
      current_filters.push($this.val());
    }
  });
  if ( $('#crpb').prop('checked'))
  {
    current_filters.push('crpb');
    referrals.push('patients can call to book after referral');
  }
  
  // collect details filters
  if ( $('#cdpb').prop('checked') && !$('#cdpv').prop('checked') )
  {
    current_filters.push('cdpb');
    details.push('public')
  }
  else if ( !$('#cdpb').prop('checked') && $('#cdpv').prop('checked') )
  {
    current_filters.push('cdpv');
    details.push('private')
  }
  
  if ( $('#cdwa').prop('checked') )
  {
    current_filters.push('cdwa');
    details.push('wheelchair accessible')
  }
  
  // collect schedule filters
  $('.cs').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      days.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
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
  
  var fragments = new Array()
  if ( procedures.length >= 1 )
  {
    fragments.push('practice in ' + procedures.to_sentence());
  }
  if ( referrals.length >= 1 )
  {
    fragments.push(referrals.to_sentence());
  }
  if ( details.length >= 1 )
  {
    fragments.push('are ' + details.to_sentence());
  }
  if ( days.length >= 1 )
  {
    fragments.push('are open on ' + days.to_sentence());
  }
  if ( languages.length >= 1 )
  {
    fragments.push('have staff that speak ' + languages.to_sentence());
  }
  
  if ( fragments.length >= 1 )
  {
    description += ' which ' + fragments.to_sentence()
  }
    
  description += ". <a href='javascript:clear_clinic_filters()'>Clear all filters</a>."
  
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
  
  // clear lagtime filters
  $('.sc').each( function() {
    $(this).val(0)
  });
  
  // clear referral filters
  $('.sr').each( function() {
    $(this).prop('checked',false)
  });
  
  // collect sex filters
  $('#ssm').prop('checked', false);
  $('#ssf').prop('checked', false);
  
  // clear language filters
  $('.sl').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear association filters
  $('.sa').each( function() {
    $(this).val(0)
  });
  
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
  
  // clear lagtime filters
  $('.cc').each( function() {
    $(this).val(0)
  });
  
  // clear referral filters
  $('.cr').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear details filters
  $('.cd').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear schedule filters
  $('.cs').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear language filters
  $('.cl').each( function() {
    $(this).prop('checked',false)
  });
  
  update_clinic_table();
}
