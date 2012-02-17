/*
 * search_data needs to be an array of search data entries, where each entry is an array of info. e.g. [["name 1", "url 1"], ["name 2", "url 2"]].
 * scores_matches_fnc(search_data_entry, term) needs to be a function which takes in a search data entry and search term, and returns an array of two arrays, [[scores],[matches]] for each element in the search_data_entry which you want to search against. For scores, higher is a better match, with zero indicating no match. Note that the String.score_matches function is useful here.
 * format_search_result(total_score, scores, matches, search_data_entry) needs to be a function which takes in a total score, array of scores and matches (as returned by your scores_matches_fnc), and the original search_data_entry, and returns a formatted list element (e.g. <li>something</li>).
*/

jQuery.fn.livesearch = function(options)
{
  container = jQuery(options.container)
  list = container.children('ul')
  data = jQuery(options.data)
  scorer_fnc = options.scorer || scorer
  grouper_fnc = options.grouper || grouper
  data_formatter_fnc = options.data_formatter || data_formatter
  group_formatter_fnc = options.group_formatter || group_formatter
  empty_fnc = options.empty || empty
  searcher_fnc = options.searcher || searcher
  fuzziness = options.fuzziness || 0.5
  max_results = options.max_results || 10
  min_score = options.min_score || 0.5
  results = []
  selected = -1
  that = this
  
  container.mouseover( function() { set_selected(-1) });
  
  this
    .keyup(filter).keyup()
    .focus(filter)
    .blur(function() 
          { 
            container.animate({height: "hide"}, 200) 
          })
    .parents('form').submit( function() { if (results.length > 0) { that.blur(); return searcher_fnc(results[selected].data_entry) } else { return false; } });
  
	return this;
    
	function filter(event)
  {
    if (event.keyCode == 38)
    {
      //up key
      if ( --selected < 0 )
      {
        selected = 0
      }
      set_selected(selected)
      return;
    }
    else if (event.keyCode == 40)
    {
      //down key
      if ( ++selected >= results.length )
      {
        selected = (results.length - 1)
      }
      set_selected(selected)
      return;
    }
    
		var term = jQuery.trim( jQuery(this).val().toLowerCase() )
		
		if ( !term ) 
    {
      container.animate({height: "hide"}, 200) 
      return
		} 
    
    list.empty()
    
    results = [];
    
    data.each(function()
    {
      var total_score = 0
      var scores_matches = scorer_fnc(this, term, fuzziness)
    
      $.each(scores_matches, function(k, v) { total_score += v.score } );
    
      if (total_score >= min_score) 
        results.push({total_score: total_score, scores_matches: scores_matches, data_entry: this})
    });
    
    if (results.length == 0)
    {
      list.append( empty_fnc() )
      container.animate({height: "show"}, 200) 
      return
    }
    
    results = results.sort(function(a, b){return b.total_score - a.total_score}).slice(0,max_results);
    
    var last_group = -999;
    $.each(results.sort(grouper_fnc), function()
    {
      if ( this.data_entry.group_name && (last_group != this.data_entry.group_order) )
      {
        last_group = this.data_entry.group_order
        list.append(group_formatter_fnc(this.data_entry.group_name))
      }
      list.append(data_formatter_fnc(this.total_score, this.scores_matches, this.data_entry))
    });
    
    selected = 0
    set_selected(selected)
    
    container.animate({height: "show"}, 200) 
	}
  
  function scorer(data_entry, term, fuzziness) 
  {
    return { value: data_entry.value.score_matches(term, fuzziness) };
  }
  
  function grouper(a, b)
  {
    if (a.data_entry.group_order && b.data_entry.group_order)
      return (a.group_order - b.group_order)
    else
      return (b.total_score - a.total_score)
  }
  
  function data_formatter(total_score, scores_matches, data_entry)
  {
    return "<li class='result'><a href=\'" + data_entry.url + "'>" + livesearch_highlighter( data_entry.value, scores_matches.value.matches ) + '</a></li>';
  }
  
  function group_formatter(group_name)
  {
    var result = "<li class='group'>" + group_name + "</li>";
    
    return result;
  }
  
  function empty()
  {
    return "<li class='empty'>No results</li>";
  }
  
  function searcher(data_entry)
  {
    return false;
  }
  
  function set_selected(index)
  {
    container.find('li.result').each( function(i) {
                                       if (i == index)
                                       {
                                         $(this).addClass('selected');
                                       }
                                       else
                                       {
                                         $(this).removeClass('selected');
                                       }
                                     });
  }
};

Array.prototype.hasValue = function(value)
{
  for (var i=0; i<this.length; i++) { if (this[i] === value) return true; }
  return false;
}

 /*!
 * score_matches, built off of string_score
 * 
 * string_score.js: String Scoring Algorithm 0.1.10 
 *
 * http://joshaven.com/string_score
 * https://github.com/joshaven/string_score
 *
 * Copyright (C) 2009-2011 Joshaven Potter <yourtech@gmail.com>
 * Special thanks to all of the contributors listed here https://github.com/joshaven/string_score
 * MIT license: http://www.opensource.org/licenses/mit-license.php
 *
 * Date: Tue Mar 1 2011
 *
 * Modified by Pathways to also return array of matching characters for highlighting purposes.
 *  'Hello World'.score('he');     //=> [0.5931818181818181, [0,1]]
 *  'Hello World'.score('Hello');  //=> [0.7318181818181818, [0,1,2,3,4]]
 *
 * Many further modifications to greedy match as much of the string as possible, and to weight results in a more pleasing way
 */


String.prototype.score_matches = function(abbreviation, fuzziness) 
{
  var matches = new Array();
  abbreviation = abbreviation.toLowerCase();
  
  // If the string is equal to the abbreviation, perfect match.
  if (this.toLowerCase() == abbreviation) 
  {
    for ( var i = 0; i < this.length; ++i )
    {
      matches[i] = i;
    }
    return { score: 1.0, matches: matches };
  }
  
  //if it's not a perfect match and is empty return 0
  if(abbreviation == "") 
  { 
    return { score: 0.0, matches: [] }; 
  }
  
  var total_character_score = 0,
  string = this.toLowerCase(),
  string_length = string.length,
  abbreviation_length = abbreviation.length,
  start_of_word_matches = 0,
  abbreviation_score,
  cur_start = 0,
  num_matches = 0,
  fuzzies = 1,
  final_score;
  
  var i = 0;
  // Walk through abbreviation and add up scores.
  while (i < abbreviation_length) 
  {
    // Find the longest match remaining.
    for (var match_length = abbreviation_length - i; match_length > 0; --match_length)
    {
      var index_in_string = string.indexOf( abbreviation.substr(i, match_length) );
      
      if (index_in_string != -1)
      {
        break;
      }
    }
    
    var character_score = 0.0;
    
    if (index_in_string === -1) 
    { 
      if (fuzziness) 
      {
        fuzzies += 1-fuzziness;
        ++i;
        continue;
      } 
      else 
      {
        return [0,[]];
      }
    }
    
    ++num_matches;
    
    // Set base score for matching 'c'.
    var match_score = match_length / abbreviation_length;
    
    for (var k = 0; k < match_length; ++k)
    {
      matches.push(cur_start + index_in_string + k);
    }
    
    var start_of_abbrev_word = ((i == 0) || (abbreviation.charAt(i-1) == ' '))
    var start_of_string_word = ((cur_start == 0) || (string.charAt(index_in_string-1) == ' '))
    
    // Consecutive letter & start-of-string or word bonus
    if (start_of_abbrev_word && start_of_abbrev_word) 
    {
      // Increase the score when matching first character of the remainder of the string, or starting a new word
      start_of_word_matches += 1;
    }
    
    // Left trim the already matched part of the string (forces sequential matching).
    string = string.substring(index_in_string + match_length + 1, string_length);
    i += match_length + 1;
    cur_start += index_in_string + match_length + 1;
    
    total_character_score += match_score;
  } 
  
  if (matches.length == 0)
  {
    return 0;
  }
  
  //take into account errors
  final_score = final_score / fuzzies;
  
  //penalize each match that isn't a start of string
  var final_score = total_character_score - ((num_matches-start_of_word_matches) * 0.2);
  
  //penalize longer words slightly
  final_score *= 1.0 - (Math.abs(string_length - abbreviation_length) * 0.01);
  
  return { score: final_score, matches: matches };
};

function livesearch_highlighter(string, matches)
{
  var output = "";
  var string_length = string.length;
  var currently_highlighted = false;
  
  for ( var i = 0; i < string_length; ++i )
  {
    var should_highlight = matches.hasValue(i);
    
    if ( should_highlight && !currently_highlighted )
    {
      output += "<em>";
      currently_highlighted = true;
    }
    else if ( !should_highlight && currently_highlighted )
    {
      output += "</em>";
      currently_highlighted = false;
    }
    
    output += string.charAt(i);
  }
  
  if ( currently_highlighted )
  {
    output += "</em>";
  }
  
  return output;
}