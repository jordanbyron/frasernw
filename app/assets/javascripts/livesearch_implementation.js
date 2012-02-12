
function pathways_scorer(data_entry, term, fuzziness) 
{
  return { 
    name: data_entry.name.score_matches(term, fuzziness), 
    specialty: data_entry.specialty.score_matches(term, fuzziness) 
  };
}

function pathways_formatter(total_score, scores_matches, data_entry)
{
  var result = "<li><a href=\"#\" onclick=\"ajaxto('" + data_entry.url + "'); $('#search_results').removeClass('show');\">"
  
  result += "<span class='name'>" + livesearch_highlighter( data_entry.name, scores_matches.name.matches ) + "</span>"
  result += "<span class='specialties'>" + livesearch_highlighter( data_entry.specialty, scores_matches.specialty.matches ) + "</span>"
  
  result += "</a></li>";
  
  return result;
}