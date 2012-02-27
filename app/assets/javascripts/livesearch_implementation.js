
function pathways_scorer(data_entry, term, fuzziness) 
{
  return { 
    n: data_entry.n.score_matches(term, fuzziness)
  };
}

function pathways_grouper(a, b)
{
  return (a.data_entry.go - b.data_entry.go)
}

function pathways_data_formatter(total_score, scores_matches, data_entry)
{
  var result = "<li class='result'><a id='" + data_entry.url.replace(/\//g,'_') + "'  href='" + data_entry.url + "' class='ajax'>"
  
  result += "<div class='search_name status_" + data_entry.st + "'>" + livesearch_highlighter( data_entry.n, scores_matches.n.matches ) + "</div>"
  result += "<div class='search_specialties'>" + data_entry.sp + "</div>"
  
  if ( data_entry.wt != "" && data_entry.c != "" )
  {
    result += "<div class='search_wait_time'>Wait time: " + data_entry.wt + "</div>"
    result += "<div class='search_city'>" + data_entry.c + "</div>"
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
    case "Languages":
      icon = "comment"
      break;
  }
  
  var result = "<li class='group'>"
  result += "<div class='group'><i class='icon-" + icon + " icon-text'></i> " + group_name + "</div>"
  result += "</li>";
  
  return result;
}

function pathways_searcher(data_entry)
{
  $('#' + data_entry.url.replace(/\//g,'_')).click();
  return false;
}