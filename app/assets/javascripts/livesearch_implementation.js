
function pathways_scorer(data_entry, term, fuzziness) 
{
  return { 
    name: data_entry.name.score_matches(term, fuzziness)
  };
}

function pathways_grouper(a, b)
{
  return (a.data_entry.group_order - b.data_entry.group_order)
}

function pathways_data_formatter(total_score, scores_matches, data_entry)
{
  var result = "<li class='result'><a href=\"#\" onclick=\"ajaxto('" + data_entry.url + "'); $('#search_results').removeClass('show');\">"
  
  result += "<div class='name status_" + data_entry.status + "'>" + livesearch_highlighter( data_entry.name, scores_matches.name.matches ) + "</div>"
  result += "<div class='specialties'>" + data_entry.specialty + "</div>"
  
  if ( data_entry.wait_time != "" && data_entry.city != "" )
  {
    result += "<div class='wait_time'>Wait time: " + data_entry.wait_time + "</div>"
    result += "<div class='city'>" + data_entry.city + "</div>"
  }
  
  result += "</a></li>";
  
  return result;
}

function pathways_group_formatter(group_name)
{
  var icon = "";
  switch(group_name)
  {
    case "Specialists":
      icon = "user"
      break;
    case "Clinics":
      icon = "home"
      break;
    case "Hospitals":
      icon = "plus"
      break;
    case "Specialties":
      icon = "book"
      break;
    case "Areas of Practice":
      icon = "list"
      break;
  }
  
  var result = "<li class='group'>"
  result += "<div class='group'><i class='icon-" + icon + " icon-text'></i> " + group_name + "</div>"
  result += "</li>";
  
  return result;
}