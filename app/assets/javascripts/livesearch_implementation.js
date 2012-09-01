
function pathways_scorer(data_entry, term, fuzziness) 
{
  return { 
   n: score_matches( term, data_entry.n, fuzziness)
  };
}

function pathways_grouper(a, b)
{
  return (a.data_entry.go - b.data_entry.go);
}

function pathways_data_formatter(total_score, scores_matches, data_entry)
{
  var result = "<li class='search-result'><a class='ajax' id='search_result_" + data_entry.go + '_' + data_entry.id + "'  href='/" + pathways_url_data[data_entry.go] + '/' + data_entry.id + "'>";
  
  result += "<div class='search_name'><i class='" + pathways_status_data[data_entry.st] + "'></i> " + data_entry.n + "</div>";
  
  var specialties = new Array();
  
  if ( data_entry.sp )
  {
    for (var i = 0; i < data_entry.sp.length; ++i)
    {
      specialties.push( pathways_specialization_data[data_entry.sp[i]] );
    }
  }
  
  if (data_entry.c)
  {
    var cities = [];
    for( x = 0; x < data_entry.c.length; ++ x )
    {
      cities[x] = pathways_city_data[data_entry.c[x]];
    }
    
    result += "<div class='search_specialties'>" + specialties.to_sentence() + "</div>";
    result += "<div class='search_city'>" + cities.join(" / ") + "</div>";
  }
  else
  {
    result += "<div class='search_specialties no_city'>" + specialties.to_sentence() + "</div>";
  }
  
  result += "</a></li>";
  
  return (typeof $.fn.ajaxify !== 'function') ? result : $(result).ajaxify();
}

function pathways_group_formatter(group_id)
{
  return "<li class='group'><div class='group'>" + pathways_group_data[group_id] + "</div></li>";
}

function pathways_searcher(data_entry)
{
  $.each( $('#search_result_' + data_entry.go + '_' + data_entry.id), function(){ $(this).click() });
  return false;
}