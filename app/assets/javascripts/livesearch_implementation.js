
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
  var result = "<li class='result'><a id='" + data_entry.url.replace('/','_') + "'  href='" + data_entry.url + "' class='ajax'>"
  
  result += "<div class='name status_" + data_entry.status + "'>" + livesearch_highlighter( data_entry.name, scores_matches.name.matches ) + "</div>"
  result += "<div class='specialties'>" + data_entry.specialty + "</div>"
  
  if ( data_entry.wait_time != "" && data_entry.city != "" )
  {
    result += "<div class='wait_time'>Wait time: " + data_entry.wait_time + "</div>"
    result += "<div class='city'>" + data_entry.city + "</div>"
  }
  
  result += "</a></li>";
  
  return $(result).ajaxify();
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

function pathways_searcher(data_entry)
{
  $('#' + data_entry.url.replace('/','_')).click();
  return false;
}