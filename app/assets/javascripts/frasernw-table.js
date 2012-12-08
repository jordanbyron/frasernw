function build_table()
{
  for(var city_id in current_cities)
  {
    if (!current_cities[city_id])
    {
      //'unloaded' city
      console.log("unloaded city: " + city_id);
      continue
    }
    
    for(var specialist_id in specialist_data[city_id])
    {
      var specialist = specialist_data[city_id][specialist_id];
      var name = specialist.name;
      var attributes = specialist.attributes;
      var specialties = specialist.specialties.map(function(specialty_id) { return global_specialties[specialty_id] }).to_sentence();
      var status_class = global_status_classes[specialist.status_class];
      var status_sort = specialist.status_sort;
      var wait_time = global_wait_times[specialist.wait_time];
      var status_class = global_status_classes[specialist.status_class];
      var cities = specialist.cities.map(function(city_id) { return global_cities[city_id] }).to_sentence();
      add_row( 'specialist', specialist_id, '/specialists/' + specialist_id, name, status_class, status_sort, wait_time, cities, specialist.specialties, specialties, attributes );
    }
  }
  update_specialist_table();
}

function add_row( entity_id, row_id, url, name, status_class, status_sort, wait_time, city, specialty_ids, specialties, attributes )
{
  var other = ($.inArray(current_specialty, specialty_ids) == -1)
  var row_class = other ? "other" : ""
  var row_specialties = other ? ("(" + specialties + ")") : ""
  
  var row_html = $("<tr id='" + entity_id + "_" + row_id + "' class='" + row_class + "'><td class=\"sp\"><a href=\"" + url + "\" class=\"ajax\">" + name + "</a> " + row_specialties + "</td><td class=\"st\"><i class=\"" + status_class + "\"></i><div class=\"status\">" + status_sort + "</div></td><td class=\"wt\">" + wait_time + "</td><td class=\"ct\">" + city + "</td></tr>");
  
  if (typeof $.fn.ajaxify !== 'function')
  {
    $('#' + entity_id + '_table tr:last').after(row_html);
  }
  else
  {
    $('#' + entity_id + '_table tr:last').after(row_html.ajaxify());
  }
  $('#' + entity_id + "_" + row_id).data('attributes', attributes);
}