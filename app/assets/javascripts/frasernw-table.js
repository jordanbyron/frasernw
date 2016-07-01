function init_tables(procedure_filter, assumed_specialist_specialties, assumed_clinic_specialties)
{
  table_data = {};
  table_data['specialist'] = {};
  table_data['clinic'] = {};

  for(var city_id in filtering.current_cities)
  {
    if (!filtering.current_cities[city_id])
    {
      //'unloaded' city
      continue
    }
    add_entities_from_city('s', 'specialist', filtering.specialist_data, city_id, procedure_filter, assumed_specialist_specialties);
    add_entities_from_city('c', 'clinic', filtering.clinic_data, city_id, procedure_filter, assumed_clinic_specialties);
  }

  update_ui();
}

function clear_tables()
{
  $('#specialist_table tbody').find('tr').not('.placeholder').remove();
  $('#specialist_table').trigger('update');

  $('#clinic_table tbody').find('tr').not('.placeholder').remove();
  $('#clinic_table').trigger('update');
}

function update_ui()
{
  update_procedures('s', filtering.specialist_procedures);
  update_associations('s', filtering.specialist_associations);
  update_languages('s', filtering.specialist_languages);
  update_specialist_table();
  $('#specialist_table').trigger('sorton', [[[2,0],[3,0],[4,0]]]);

  update_procedures('c', filtering.clinic_procedures);
  update_languages('c', filtering.clinic_languages);
  update_healthcare_providers('c', filtering.clinic_healthcare_providers);
  update_clinic_table();
  $('#clinic_table').trigger('sorton', [[[0,0],[2,0],[3,0],[4,0]]]);
}

function add_entities_from_city(prefix, entity_name, entity_data, city_id, procedure_filter, assumed_specialties)
{
  for(var entity_id in entity_data[city_id])
  {
    var entity = entity_data[city_id][entity_id];
    if (procedure_filter != -1)
    {
      if ((assumed_specialties.intersect(entity.specialties).length == 0) && (entity.attributes.indexOf(prefix + 'p' + procedure_filter + '_') == -1))
      {
        //the entity doesn't perform the procedure we are filtering on, nor any of the assume specialties, skip it
        continue;
      }
    }
    var name = entity.name;
    var attributes = entity.attributes;
    var specialties_id = entity.specialties;
    var specialties = specialties_id.map(function(specialty_id) { return filtering.global_specialties[specialty_id] }).to_sentence();
    var status_class = filtering.global_status_classes[entity.status_class];
    var status_sort = entity.status_class;
    var wait_time = filtering.global_wait_times[entity.wait_time];
    var status_class = filtering.global_status_classes[entity.status_class];
    var cities = entity.cities.map(function(city_id) { return filtering.global_cities[city_id] }).to_sentence();
    var other = filtering.current_specialties.intersect(entity.specialties).length == 0;
    var in_progress = entity.in_progress === true
    var suffix = entity.suffix
    var is_gp = entity.is_gp === true
    var is_new = entity.is_new === true
    var is_private = entity.is_private === true
    add_row(entity_name, entity_id, '/' + entity_name + 's/' + entity_id, name, status_class, status_sort, wait_time, cities, specialties_id, specialties, attributes, other, in_progress, suffix, is_gp, is_new, is_private);
  }
}

function add_row( entity_type, entity_id, url, name, status_class, status_sort, wait_time, city, specialties_id, specialties, attributes, other, in_progress, suffix, is_gp, is_new, is_private )
{
  if (in_progress && !current_user_is_admin())
  {
    return;
  }

  var row_id = entity_type + "_" + entity_id;

  if (table_data[entity_type][row_id])
  {
    //duplicate
    return;
  }

  var row_class = other ? (in_progress ? "class='other hidden-from-users'" : "class='other'") : (in_progress ? "class='hidden-from-users'" : "");
  var row_specialties = "<td class='s'>" + specialties + "</td>";
  var gp_tag = is_gp ? "<span class='gp'>GP</span> " : ""
  var new_tag = is_new ? "<span class='new'>new</span> " : ""
  var private_tag = is_private ? "<span class='private'>private</span> " : ""

  var row_html = $("<tr id='" + row_id + "' " + row_class + "><td class=\"sp\"><a href=\"" + url + "\" class=\"ajax\">" + name + "</a> " + gp_tag + "" + new_tag + "" + private_tag + "</td>" + row_specialties + "<td class=\"st\"><i class=\"" + status_class + "\"></i><div class=\"status\">" + status_sort + "</div></td><td class=\"wt\">" + wait_time + "</td><td class=\"ct\">" + city + "</td></tr>");

  table_data[entity_type][row_id] = { html:row_html, attributes:attributes, specialties:specialties_id, other:other };
}

function update_procedures(prefix, city_procedures)
{
  var current_procedures = [];

  for(var city_id in filtering.current_cities)
  {
    if (!filtering.current_cities[city_id])
    {
      //'unloaded' city
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

  //hide 'more' if there are no more
  has_more = false
  $('#more_' + prefix + '_procedures').children('label').each( function() {
    if ($(this).css('display') != 'none')
    {
      has_more = true;
      return false;
    }
  });

  if (has_more)
  {
    $('#more_' + prefix + '_procedures').show()
    $('#' + prefix + '_procedures_more').show();
  }
  else
  {
    $('#more_' + prefix + '_procedures').hide()
    $('#' + prefix + '_procedures_more').hide();
  }
}

function update_associations(prefix, city_associations)
{
  var current_associations = [];

  for(var city_id in filtering.current_cities)
  {
    if (!filtering.current_cities[city_id])
    {
      //'unloaded' city
      continue
    }

    current_associations = current_associations.concat(city_associations[city_id]);
  }

  current_associations = current_associations.unique();

  var showing_something = false;

  //only add hopsitals that someone works in
  var hospital_select = $('.' + prefix + 'a#hospital_associations');
  hospital_select.find('option').remove();
  hospital_select.append($('<option>').text('Any').val(0));
  $.each(filtering.global_hospitals, function(hospital_id, hospital_name) {
    var attribute = 'sah' + hospital_id + '_';
    if (current_associations.indexOf(attribute) != -1)
    {
      hospital_select.append($('<option>').text(hospital_name).val(attribute));
      showing_something = true;
    }
  });

  //only add clinics that someone works in
  var clinic_select = $('.' + prefix + 'a#clinic_associations');
  clinic_select.find('option').remove();
  clinic_select.append($('<option>').text('Any').val(0));
  $.each(filtering.global_clinics, function(clinic_id, clinic_name) {
    var attribute = 'sac' + clinic_id + '_';
    if (current_associations.indexOf(attribute) != -1)
    {
      clinic_select.append($('<option>').text(clinic_name).val(attribute));
      showing_something = true;
    }
  });

  //hide the whole filtering group if we hid everything above
  if (showing_something)
  {
    $('#' + prefix + 'a-filter-group').show();
  }
  else
  {
    $('#' + prefix + 'a-filter-group').hide();
  }
}

function update_languages(prefix, city_languages)
{
  var current_languages = [];

  for(var city_id in filtering.current_cities)
  {
    if (!filtering.current_cities[city_id])
    {
      //'unloaded' city
      continue
    }

    current_languages = current_languages.concat(city_languages[city_id]);
  }

  var showing_something = false;

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
      showing_something = true;
    }
  });

  //hide the whole filtering group if we hid everything above
  if (showing_something)
  {
    $('#' + prefix + 'l-filter-group').show();
  }
  else
  {
    $('#' + prefix + 'l-filter-group').hide();
  }
}

function update_healthcare_providers(prefix, city_healthcare_providers)
{
  var current_healthcare_providers = [];

  for(var city_id in filtering.current_cities)
  {
    if (!filtering.current_cities[city_id])
    {
      //'unloaded' city
      continue
    }

    current_healthcare_providers = current_healthcare_providers.concat(city_healthcare_providers[city_id]);
  }

  var showing_something = false;

  //hide healthcare providers that no entity has
  $('input.' + prefix + 'h').each( function() {
    $this = $(this)
    if (current_healthcare_providers.indexOf($this.attr('id')) == -1)
    {
      $this.parent().hide();
    }
    else
    {
      $this.parent().show();
      showing_something = true;
    }
  });

  //hide the whole filtering group if we hid everything above
  if (showing_something)
  {
    $('#' + prefix + 'h-filter-group').show();
  }
  else
  {
    $('#' + prefix + 'h-filter-group').hide();
  }
}

function expand_city(is_checked, specialization_ids, city_id, procedure_filter, assumed_specialist_specialties, assumed_clinic_specialties)
{
  var $body = $(document.body);

  if (filtering.current_cities[city_id.toString()] === undefined)
  {
    if (specialization_ids.length == 0)
    {
      return;
    }
    //we need to load it
    filtering.current_cities[city_id.toString()] = true;
    $body.addClass('loading');

    for(var i = 0; i < specialization_ids.length - 1; ++i)
    {
      $.getScript("/specialties/" + specialization_ids[i] + "/cities/" + city_id + ".js").done( function(script, textStatus) {
        //this all needs to happen in this callback function
        add_entities_from_city('s', 'specialist', filtering.specialist_data, city_id, procedure_filter, assumed_specialist_specialties);
        add_entities_from_city('c', 'clinic', filtering.clinic_data, city_id, procedure_filter, assumed_clinic_specialties);
      })
    }
    $.getScript("/specialties/" + specialization_ids[specialization_ids.length - 1] + "/cities/" + city_id + ".js").done( function(script, textStatus) {
      //this all needs to happen in this callback function
      add_entities_from_city('s', 'specialist', filtering.specialist_data, city_id, procedure_filter, assumed_specialist_specialties);
      add_entities_from_city('c', 'clinic', filtering.clinic_data, city_id, procedure_filter, assumed_clinic_specialties);
      //update UI in the final load
      update_ui(procedure_filter);
      $body.removeClass('loading');
    }).fail(function(jqxhr, settings, exception){
      update_ui(procedure_filter);
      $body.removeClass('loading');
    });
  }
  else if (filtering.current_cities[city_id.toString()] === false)
  {
    //we have it loaded, just show it
    filtering.current_cities[city_id.toString()] = true;
    add_entities_from_city('s', 'specialist', filtering.specialist_data, city_id, procedure_filter, assumed_specialist_specialties);
    add_entities_from_city('c', 'clinic', filtering.clinic_data, city_id, procedure_filter, assumed_clinic_specialties);
    update_ui(procedure_filter);
  }
  else
  {
    //we want to hide this data, which requires a table reset
    filtering.current_cities[city_id.toString()] = false;
    clear_tables();
    init_tables(procedure_filter, assumed_specialist_specialties, assumed_clinic_specialties);
  }
}
