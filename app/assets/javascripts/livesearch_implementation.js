
function pathways_scorer(data_entry, term, fuzziness) 
{
  return { 
    name: data_entry.name.score_matches(term, fuzziness)
  };
}

function pathways_formatter(total_score, scores_matches, data_entry)
{
  var result = "<li><a href=\"#\" onclick=\"ajaxto('" + data_entry.url + "'); $('#search_results').removeClass('show');\">"
  
  result += "<div class='icon spanhalf'><i class='icon-" + data_entry.icon + "'></i></div>"
  result += "<div class='name span2'>" + livesearch_highlighter( data_entry.name, scores_matches.name.matches ) + "</div>"
  result += "<div class='specialties span2 offsethalf status_" + data_entry.status + "'>" + data_entry.specialty + "</div>"
  result += "<div class='city span2'>" + data_entry.city + "</div>"
  
  result += "</a></li>";
  
  return result;
}