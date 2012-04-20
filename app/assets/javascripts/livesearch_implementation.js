
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
  var result = "<li class='result'><a id='" + data_entry.go + '_' + data_entry.id + "'  href='/" + pathways_url_data[data_entry.go] + '/' + data_entry.id + "' class='ajax'>"
  
  result += "<div class='search_name status_" + data_entry.st + "'>" + livesearch_highlighter( data_entry.n, scores_matches.n.matches ) + "</div>"
  
  var specialties = new Array();
  
  if ( data_entry.sp )
  {
    for (var i = 0; i < data_entry.sp.length; ++i)
    {
      specialties.push( pathways_specialization_data[data_entry.sp[i]] )
    }
  }
  
  result += "<div class='search_specialties'>" + specialties.to_sentence() + "</div>";
  
  if(data_entry.wt && (data_entry.wt != "") && data_entry.c && (data_entry.c != ""))
  {
    result += "<div class='search_wait_time'>"
    result += "Wait time: " + data_entry.wt
    result += "</div>"
    result += "<div class='search_city'>" + pathways_city_data[data_entry.c] + "</div>"
  }
  else if (data_entry.wt && (data_entry.wt != ""))
  {
    result += "<div class='search_wait_time'>"
    result += "Wait time: " + data_entry.wt
    result += "</div>"
  }
  else if (data_entry.c && (data_entry.c != ""))
  {
    result += "<div class='search_wait_time'></div>"
    result += "<div class='search_city'>" + pathways_city_data[data_entry.c] + "</div>"
  }
  
  result += "</a></li>";
  
  return $(result).ajaxify();
}

function pathways_group_formatter(group_id)
{
  var icon = "";
  switch(group_id)
  {
    case 0: //specialists
      icon = "user"
      break;
    case 1: //clinics
      icon = "home"
      break;
    case 3: //hospitals
      icon = "plus"
      break;
    case 4: //areas of practice
      icon = "list"
      break;
    case 5: //specialties
      icon = "book"
      break;
    case 6: //languages
      icon = "comment"
      break;
  }
  
  var result = "<li class='group'>"
  result += "<div class='group'><i class='icon-" + icon + " icon-text'></i> " + pathways_group_data[group_id] + "</div>"
  result += "</li>";
  
  return result;
}

function pathways_searcher(data_entry)
{
  $('#' + data_entry.go + '_' + data_entry.id).click();
  return false;
}