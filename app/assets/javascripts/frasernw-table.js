function init_tables()
{
  for(var city_id in current_cities)
  {
    if (!current_cities[city_id])
    {
      //'unloaded' city
      console.log("unloaded city: " + city_id);
      continue
    }
    add_entities_from_city('specialist', specialist_data, city_id);
    add_entities_from_city('clinic', clinic_data, city_id);
  }
  
  update_procedures('s', specialist_procedures);
  update_associations('s', specialist_associations);
  update_languages('s', specialist_languages);
  update_specialist_table();
  $('#specialist_table').trigger('update', [true]);
  
  update_procedures('c', clinic_procedures);
  update_languages('c', clinic_languages);
  update_healthcare_provders('c', clinic_healthcare_providers);
  update_clinic_table();
  $('#clinic_table').trigger('update', [true]);
}

function add_entities_from_city(entity_name, entity_data, city_id)
{
  for(var entity_id in entity_data[city_id])
  {
    var entity = entity_data[city_id][entity_id];
    var name = entity.name;
    var attributes = entity.attributes;
    var specialties = entity.specialties.map(function(specialty_id) { return global_specialties[specialty_id] }).to_sentence();
    var status_class = global_status_classes[entity.status_class];
    var status_sort = entity.status_class;
    var wait_time = global_wait_times[entity.wait_time];
    var status_class = global_status_classes[entity.status_class];
    var cities = entity.cities.map(function(city_id) { return global_cities[city_id] }).to_sentence();
    var other = (entity_name == 'specialist') && ($.inArray(current_specialty, entity.specialties) == -1);
    add_row(entity_name, entity_id, '/' + entity_name + 's/' + entity_id, name, status_class, status_sort, wait_time, cities, specialties, attributes, other);
  }
}

function add_row( entity_type, entity_id, url, name, status_class, status_sort, wait_time, city, specialties, attributes, other )
{
  var row_id = entity_type + "_" + entity_id;
  if ($("#" + row_id).length > 0)
  {
    //row already exists
    return;
  }
  
  var row_class = other ? "class='other'" : ""
  var row_specialties = other ? ("(" + specialties + ")") : ""
  
  var row_html = $("<tr id='" + row_id + "' " + row_class + "><td class=\"sp\"><a href=\"" + url + "\" class=\"ajax\">" + name + "</a> " + row_specialties + "</td><td class=\"st\"><i class=\"" + status_class + "\"></i><div class=\"status\">" + status_sort + "</div></td><td class=\"wt\">" + wait_time + "</td><td class=\"ct\">" + city + "</td></tr>");
  
  if (typeof $.fn.ajaxify !== 'function')
  {
    $('#' + entity_type + '_table tr:last').after(row_html);
  }
  else
  {
    $('#' + entity_type + '_table tr:last').after(row_html.ajaxify());
  }
  $('#' + entity_type + "_" + entity_id).data('attributes', attributes);
}

function update_procedures(prefix, city_procedures)
{
  var current_procedures = [];
  
  for(var city_id in current_cities)
  {
    if (!current_cities[city_id])
    {
      //'unloaded' city
      console.log("unloaded city: " + city_id);
      continue
    }
    
    current_procedures = current_procedures.concat(city_procedures[city_id]);
  }
  
  current_procedures = current_procedures.unique();
  
  //hide procedures that no entity performs
  $('input.' + prefix + 'p').each( function() {
    $this = $(this)
    if (current_procedures.indexOf($this.attr('id')) == -1)
    {
      $this.parent().hide();
    }
    else
    {
      $this.parent().show();
    }
  });
}

function update_associations(prefix, city_associations)
{
  var current_associations = [];
  
  for(var city_id in current_cities)
  {
    if (!current_cities[city_id])
    {
      //'unloaded' city
      console.log("unloaded city: " + city_id);
      continue
    }
    
    current_associations = current_associations.concat(city_associations[city_id]);
  }
  
  current_associations = current_associations.unique();
  
  //only add hopsitals that someone works in
  var hospital_select = $('.' + prefix + 'a#hospital_associations');
  hospital_select.find('option').remove();
  hospital_select.append($('<option>').text('Any').val(0));
  $.each(global_hospitals, function(hospital_id, hospital_name) {
    var attribute = 'sah' + hospital_id + '_';
    if (current_associations.indexOf(attribute) != -1)
    {
      hospital_select.append($('<option>').text(hospital_name).val(attribute));
    }
  });
  
  //only add clinics that someone works in
  var clinic_select = $('.' + prefix + 'a#clinic_associations');
  clinic_select.find('option').remove();
  clinic_select.append($('<option>').text('Any').val(0));
  $.each(global_clinics, function(clinic_id, clinic_name) {
    var attribute = 'sac' + clinic_id + '_';
    if (current_associations.indexOf(attribute) != -1)
    {
      clinic_select.append($('<option>').text(clinic_name).val(attribute));
    }
  });
}

function update_languages(prefix, city_languages)
{
  var current_languages = [];
  
  for(var city_id in current_cities)
  {
    if (!current_cities[city_id])
    {
      //'unloaded' city
      console.log("unloaded city: " + city_id);
      continue
    }
    
    current_languages = current_languages.concat(city_languages[city_id]);
  }
  
  //hide langauges that no entity performs
  $('input.' + prefix + 'l, input.' + prefix + 'i').each( function() {
    $this = $(this)
    if (current_languages.indexOf($this.attr('id')) == -1)
    {
      $this.parent().hide();
    }
    else
    {
      $this.parent().show();
    }
  });
}

function update_healthcare_provders(prefix, city_healthcare_providers)
{
  var current_healthcare_providers = [];
  
  for(var city_id in current_cities)
  {
    if (!current_cities[city_id])
    {
      //'unloaded' city
      console.log("unloaded city: " + city_id);
      continue
    }
    
    current_healthcare_providers = current_healthcare_providers.concat(city_healthcare_providers[city_id]);
  }
  
  //hide langauges that no entity performs
  $('input.' + prefix + 'h').each( function() {
    $this = $(this)
    if (current_healthcare_providers.indexOf($this.attr('id')) == -1)
    {
      $this.parent().hide();
    }
    else
    {
      $this.parent().show();
    }
  });
}