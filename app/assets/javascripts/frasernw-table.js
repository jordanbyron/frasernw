function build_tables()
{
  for(var city_id in current_cities)
  {
    if (!current_cities[city_id])
    {
      //'unloaded' city
      console.log("unloaded city: " + city_id);
      continue
    }
    add_specialists_from_city(city_id);
    add_clinics_from_city(city_id);
  }
  
  update_specialist_procedures();
  update_specialist_table();
  $('#specialist_table').trigger('update', [true]);
  
  update_clinic_procedures();
  update_clinic_table();
  $('#clinic_table').trigger('update', [true]);
}

function add_specialists_from_city(city_id)
{
  for(var specialist_id in specialist_data[city_id])
  {
    var specialist = specialist_data[city_id][specialist_id];
    var name = specialist.name;
    var attributes = specialist.attributes;
    var specialties = specialist.specialties.map(function(specialty_id) { return global_specialties[specialty_id] }).to_sentence();
    var status_class = global_status_classes[specialist.status_class];
    var status_sort = specialist.status_class;
    var wait_time = global_wait_times[specialist.wait_time];
    var status_class = global_status_classes[specialist.status_class];
    var cities = specialist.cities.map(function(city_id) { return global_cities[city_id] }).to_sentence();
    var other = ($.inArray(current_specialty, specialist.specialties) == -1);
    add_row('specialist', specialist_id, '/specialists/' + specialist_id, name, status_class, status_sort, wait_time, cities, specialties, attributes, other);
  }
}

function add_clinics_from_city(city_id)
{
  for(var clinic_id in clinic_data[city_id])
  {
    var clinic = clinic_data[city_id][clinic_id];
    var name = clinic.name;
    var attributes = clinic.attributes;
    var specialties = clinic.specialties.map(function(specialty_id) { return global_specialties[specialty_id] }).to_sentence();
    var status_class = global_status_classes[clinic.status_class];
    var status_sort = clinic.status_class;
    var wait_time = global_wait_times[clinic.wait_time];
    var status_class = global_status_classes[clinic.status_class];
    var cities = clinic.cities.map(function(city_id) { return global_cities[city_id] }).to_sentence();
    add_row('clinic', clinic_id, '/clinics/' + clinic_id, name, status_class, status_sort, wait_time, cities, specialties, attributes, false);
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

function update_specialist_procedures()
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
    
    current_procedures = current_procedures.concat(specialist_procedures[city_id]);
  }
  
  current_procedures = current_procedures.unique();
    
  $('input.sp').each( function() {
    $this = $(this)
    if (current_procedures.indexOf($this.attr('id')) == -1)
    {
      $this.parent().hide();
    }
  });
}

function update_clinic_procedures()
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
    
    current_procedures = current_procedures.concat(clinic_procedures[city_id]);
  }
  
  current_procedures = current_procedures.unique();
    
  $('input.cp').each( function() {
    $this = $(this)
    if (current_procedures.indexOf($this.attr('id')) == -1)
    {
      $this.parent().hide();
    }
  });
}