function matches_filters( input, filters )
{
  if (filters.length == 0)
  {
    return true;
  }
  
  for (var i = 0; i < filters.length; ++i)
  {
    if (input.indexOf(filters[i]) == -1)
    {
      return false;
    }
  }
  
  return true
}

function show_others( entity_id, ids )
{
  var data_table = $('#' + entity_id + '_table');
  $(ids).each( function() {
    name = data_table.data('s' + this + '_name');
    specialties = data_table.data('s' + this + '_specialties');
    status = data_table.data('s' + this + '_status');
    wait_time = data_table.data('s' + this + '_wait_time');
    city = data_table.data('s' + this + '_city');
    add_row( entity_id, this, '/' + entity_id + 's/' + this, name, status, wait_time, city );
  });
  data_table.trigger('update', [true]);
  
  var others = $('#' + entity_id + '_others').hide();
  var others = $('#' + entity_id + '_hide_others').show();
}

function hide_others( entity_id )
{
  $('#' + entity_id + '_table tbody tr.other').each(function () { $(this).remove() });
  $('#' + entity_id + '_table').trigger('update', [true]);
  $('#' + entity_id + '_others').show();
  $('#' + entity_id + '_hide_others').hide();
}

function add_row( entity_id, row_id, url, name, status, wait_time, city )
{
  if (typeof $.fn.ajaxify !== 'function')
  {
    $('#' + entity_id + '_table tr:last').after($("<tr id='" + row_id + "' class='other'><td><a href=\"" + url + "\" class=\"ajax\">" + name + "</a> (" + specialties + ")</td><td><span class=\"status_" + status + "\">" + status + "</span></td><td>" + wait_time + "</td><td>" + city + "</td></tr>"));
  }
  else
  {
    $('#' + entity_id + '_table tr:last').after($("<tr id='" + row_id + "' class='other'><td><a href=\"" + url + "\" class=\"ajax\">" + name + "</a> (" + specialties + ")</td><td><span class=\"status_" + status + "\">" + status + "</span></td><td>" + wait_time + "</td><td>" + city + "</td></tr>").ajaxify());
  }
}

var update_table = function(prefix, entity_id, entity_name)
{  
  var current_filters = new Array();
  var specializations = new Array();
  var procedures = new Array();
  var referrals = new Array();
  var details = new Array();
  var days = new Array();
  var healthcare_providers = new Array();
  var languages = new Array();
  var associations = new Array();
  var sex = '';
  var interpreter = false;
  
  // collect specialization filters
  $('.' + prefix + 'sp').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      specializations.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  // collect procedure filters
  $('.filter-group-content > label > .' + prefix + 'p, .filter-group-content > .more > label > .' + prefix + 'p').each( function() {
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
  if ( $('#' + prefix + 'rph').prop('checked'))
  {
    current_filters.push('srph');
    referrals.push('accept referrals via phone');
  }
  $('.' + prefix + 'c option:selected').each( function() {
    var $this = $(this);
    if ($this.val() != 0)
    {
      var text = $this.text().trim();
      text = text.charAt(0).toLowerCase() + text.slice(1);
                                console.log($this.val())
                                
      if ($this.val() == prefix + "c1_")
      {
        referrals.push('respond to referrals by phone when office calls for appointment');
      }
      else if ($this.val() == prefix + "c2_")
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
  if ( $('#' + prefix + 'rpb').prop('checked'))
  {
    current_filters.push(prefix + 'rpb');
    referrals.push('patients can call to book after referral');
  }
  
  // collect sex filters
  if ( $('#' + prefix + 'sm').prop('checked') && !$('#' + prefix + 'sf').prop('checked') )
  {
    current_filters.push(prefix + 'sm');
    sex = 'male'
  }
  else if ( !$('#' + prefix + 'sm').prop('checked') && $('#' + prefix + 'sf').prop('checked') )
  {
    current_filters.push(prefix + 'sf');
    sex = 'female'
  }
  
  // collect details filters
  if ( $('#' + prefix + 'dpb').prop('checked') && !$('#' + prefix + 'dpv').prop('checked') )
  {
    current_filters.push(prefix + 'dpb');
    details.push('public')
  }
  else if ( !$('#' + prefix + 'dpb').prop('checked') && $('#' + prefix + 'dpv').prop('checked') )
  {
    current_filters.push(prefix + 'dpv');
    details.push('private')
  }
  
  if ( $('#' + prefix + 'dwa').prop('checked') )
  {
    current_filters.push(prefix + 'dwa');
    details.push('wheelchair accessible')
  }
  
  // collect schedule filters
  $('.' + prefix + 'sh').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      days.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  // collect healthcare provider filters
  $('.' + prefix + 'h').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      healthcare_providers.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  // collect interpreter filters
  if ( $('#' + prefix + 'i').prop('checked') )
  {
    current_filters.push(prefix + 'i');
    interpreter = true;
  }
  
  // collect language filters
  $('.' + prefix + 'l').each( function() {
    var $this = $(this);
    if ($this.prop('checked'))
    {
      languages.push($this.parent().text().trim());
      current_filters.push($this.attr('id'));
    }
  });
  
  // collect association filters
  $('.' + prefix + 'a option:selected').each( function() {
    var $this = $(this);
    if ($this.val() != 0)
    {
      associations.push($this.text().trim());
      current_filters.push($this.val());
    }
  });
  
  var found = false;
             
  //loop over each row of the table, hiding those which don't match our filters
  $('#' + entity_id + '_table tbody tr').each(function () {
    var row = $(this)
      , row_filter = row.data('filter');
    
    if ( row.hasClass('other') )
    {
      row.remove();
    }
    else if ( current_filters.length == 0 )
    {
      row.show();
    }
    else if ( !row_filter )
    {
      //a very blank specialist entry                                        
      row.hide();
    }
    else if ( matches_filters( row_filter, current_filters ) )
    {
      row.show();
      found = true;
    }
    else
    {
      //doesn't match
      row.hide();
    }
  });
  
  var description = found ? 'Showing all ' + sex + ' ' + entity_name : 'There are no ' + sex + ' ' + entity_name;
  
  var fragments = new Array()
  if ( specializations.length >= 1 )
  {
    fragments.push('specialize in ' + specializations.to_sentence());
  }
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
  if ( healthcare_providers.length >= 1 )
  {
    fragments.push('have a ' + healthcare_providers.to_sentence());
  }
  if ( languages.length >= 1 )
  {
    fragments.push('have staff that speak ' + languages.to_sentence());
  }
  if ( associations.length >= 1 )
  {
    fragments.push('are associated with ' + associations.to_sentence());
  }
  
  if ( fragments.length >= 1)
  {
    description += ' who ' + fragments.to_sentence()
    if ( interpreter )
    {
      description += ' and have an interpreter available upon request'
    }
  }
  else if ( interpreter )
  {
    description += ' who have an interpreter available upon request'
  }
  
  description += ". <a href=\"javascript:clear_filters('" + prefix + "','" + entity_id + "','" + entity_name + "')\">Clear all filters</a>."
  
  var phrase = $('#' + entity_id + '_phrase');
  phrase.html(description);
  found ? phrase.removeClass('none') : phrase.addClass('none');
  current_filters.length == 0 ? phrase.hide() : phrase.show();
  var assumed = $('#' + entity_id + '_assumed');
  current_filters.length != 0 ? assumed.hide() : assumed.show();
  
  // handle 'other specialists
  
  var others = $('#' + entity_id + '_others');
   
  if ( procedures.length >= 1 )
  {
    //filter out our entities from other specialities
    var data_table = $('#' + entity_id + '_table')
    var other_specialists = data_table.data('filter')
    if (other_specialists)
    {
      var results = []
      $(other_specialists.split(' ')).each( function() {
        var specialist_filters = data_table.data('s' + this);
        if ( specialist_filters && matches_filters( specialist_filters, current_filters ) )
        {
          results.push( this );
        }
      });
      
      if (results.length > 0)
      {
        others.show();
        var description = (results.length > 1) ? 'There are ' + results.length + ' specialists from other specialties who match your search.' : 'There is 1 specialist from another specialty who matches your search.';
        description += " <a href=\"javascript:void(0)\" onclick=\"show_others('" + entity_id + "', [" + results.join(', ') + "])\">Show</a> these specialists.";
        others.html(description);
      }
      else
      {
        others.hide();
      }
    }
  }
  else if ( others )
  {
    others.hide();
  }
  
  var hide_others = $('#' + entity_id + '_hide_others');
  if ( hide_others )
  {
    //this always starts hidden
    hide_others.hide();
  }
}

var clear_filters = function(prefix, entity_id, entity_name) {
  
  // clear specialization filters
  $('.' + prefix + 'sp').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear procedure filters
  $('.' + prefix + 'p').each( function() {
    if ($(this).prop('checked'))
    {
      $(this).trigger('click');
    }
  });
  
  // clear lagtime filters
  $('.' + prefix + 'c').each( function() {
    $(this).val(0)
  });
  
  // clear referral filters
  $('.' + prefix + 'r').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear sex filters
  $('#' + prefix + 'sm').prop('checked', false);
  $('#' + prefix + 'sf').prop('checked', false);
  
  // clear details filters
  $('.' + prefix + 'd').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear schedule filters
  $('.' + prefix + 's').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear healthcare filters
  $('.' + prefix + 'h').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear interpreter filters
  $('#' + prefix + 'i').prop('checked', false);
  
  // clear language filters
  $('.' + prefix + 'l').each( function() {
    $(this).prop('checked',false)
  });
  
  // clear association filters
  $('.' + prefix + 'a').each( function() {
    $(this).val(0)
  });
  
  update_table(prefix, entity_id, entity_name);
}

var update_specialist_table = function()
{
  update_table('s', 'specialist', 'specialists');
}

var update_clinic_table = function()
{
  update_table('c', 'clinic', 'clinics');
}

var update_office_table = function()
{
  update_table('o', 'office', 'specialists');
}

var clear_specialist_filters = function()
{
  clear_filters('s', 'specialist', 'specialists');
}

var clear_clinic_filters = function() 
{
  clear_filters('c', 'clinic', 'clinics');
}

var clear_office_filters = function() 
{
  clear_filters('o', 'office', 'specialists');
}
