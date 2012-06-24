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
  always_match_something = options.always_match_something || true
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
    
    var best_match = null;
    
    data.each(function()
    {
      var total_score = 0
      var total_items = 0
      var scores_matches = scorer_fnc(this, term, fuzziness)
    
      $.each(scores_matches, function(k, v) { total_items += 1; total_score += v } );
      total_score /= total_items
              
      if ( !best_match || total_score > best_match.total_score )
        best_match = {total_score: total_score, scores_matches: scores_matches, data_entry: this}
    
      if (total_score >= min_score) 
        results.push({total_score: total_score, scores_matches: scores_matches, data_entry: this})
    });
  
    if (results.length == 0)
    {
      if (always_match_something)
      {
        results.push(best_match)
      }
      else
      {
        list.append( empty_fnc() )
        container.animate({height: "show"}, 200) 
        return
      }
    }
    
    results = results.sort(function(a, b){return b.total_score - a.total_score}).slice(0,max_results);
    
    var last_group = -999;
    $.each(results.sort(grouper_fnc), function()
    {
      if ( last_group != this.data_entry.go )
      {
        last_group = this.data_entry.go
        list.append(group_formatter_fnc(this.data_entry.go))
      }
      list.append(data_formatter_fnc(this.total_score, this.scores_matches, this.data_entry))
    });
    
    selected = 0
    set_selected(selected)
    
    container.animate({height: "show"}, 200) 
	}
  
  function scorer(data_entry, term, fuzziness) 
  {
    return { value: score_matches( term, data_entry.value, fuzziness) };
  }
  
  function grouper(a, b)
  {
    if (a.data_entry.go && b.data_entry.go)
      return (a.go - b.go)
    else
      return (b.total_score - a.total_score)
  }
  
  function data_formatter(total_score, scores_matches, data_entry)
  {
    return "<li class='search-result'><a href=\'" + data_entry.url + "'>" + data_entry.value + '</a></li>';
  }
  
  function group_formatter(group_id)
  {
    var result = "<li class='group'>" + group_id + "</li>";
    
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
    container.find('.search-result').each( function(i) {
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
 * score_matches, very loosely built off of string_score
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


var score_matches = function(string1, string2, fuzziness) 
{
  if (string1.trim() == "" || string2.trim() == "")
  {
    return 0.0;
  }
  
  arr1 = string1.trim().toLowerCase().split(' ');
  arr2 = string2.trim().toLowerCase().split(' ');
  
  best_match = new Array(arr1.length);
  
loop1:
  for(var x = 0; x < arr1.length; ++x)
  {
    best_match[x] = 0;
    piece1 = arr1[x];
    
  loop2:
    for (var y = 0; y < arr2.length; ++y )
    {
      piece2 = arr2[y]
      
      // perfect match?
      if (piece1 == piece2) 
      {
        best_match[x] = 1.0;
        break;
      }
      
      var total_character_score = 0,
      piece1_length = piece1.length,
      piece2_length = piece2.length,
      start_of_word_matches = 0,
      cur_start = 0,
      num_matches = 0,
      fuzzies = 1,
      piece_score;
      
      var i = 0;
      
      while (i < piece1_length) 
      {
        // Find the longest match remaining.
        for (var match_length = piece1_length - i; match_length > 0; --match_length)
        {
          var index_in_string = piece2.indexOf( piece1.substr(i, match_length) );
          
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
            continue loop2;
          }
        }
        
        ++num_matches;
        
        // Set base score for matching 'c'.
        var match_score = match_length / piece1_length;
        
        var start_of_abbrev_word = ((i == 0) || (piece1.charAt(i-1) == ' '))
        var start_of_string_word = ((cur_start == 0) || (piece2.charAt(index_in_string-1) == ' '))
        
        // Consecutive letter & start-of-string or word bonus
        if (start_of_abbrev_word && start_of_abbrev_word) 
        {
          // Increase the score when matching first character of the remainder of the string, or starting a new word
          start_of_word_matches += 1;
        }
        
        // Left trim the already matched part of the string (forces sequential matching).
        piece2 = piece2.substring(index_in_string + match_length + 1, piece2_length);
        i += match_length + 1;
        cur_start += index_in_string + match_length + 1;
        
        total_character_score += match_score;
      } 
      
      if (num_matches == 0)
      {
        continue;
      }
      
      //take into account errors
      piece_score = piece_score / fuzzies;
      
      //penalize each match that isn't a start of string
      var piece_score = total_character_score - ((num_matches-start_of_word_matches) * 0.2);
      
      //penalize longer words slightly
      piece_score *= 1.0 - (Math.abs(piece2_length - piece1_length) * 0.01);
      
      if ( piece_score > best_match[x] )
      {
        best_match[x] = piece_score;
      }
    }
  }
  
  overall_score = 0;
  for ( var x = 0; x < best_match.length; ++x )
  {
    overall_score += best_match[x];
  }
  overall_score /= best_match.length;
  
  return overall_score;
};

var levenshtein_distance = function(string1, string2) 
{
  length1 = string1.length
  length2 = string2.length

  var D = new Array(length1 + 1);
  for (var i = 0; i <= length1; i++) 
  {
    D[i] = new Array(length2 + 1);
    D[i][0] = i;
  }
  for (var j = 0; j <= length2; j++) 
  {
    D[0][j] = j;
  }
  
  for (var j = 1; j <= length2; ++j)
  {
    for (var i = 1; i <= length1; ++i)
    {
      var cost = string1.charAt(i) == string2.charAt(j) ? 0 : 1;
      var cI = D[i-1][j] + 1; //insertion
      var cD = D[i][j-1] + 1; //deletion
      var cS = D[i-1][j-1] + cost; //substitution
      if ( cI < cD )
      {
        D[i][j] = cI < cS ? cI : cS;
      }
      else
      {
        D[i][j] = cD < cS ? cD : cS;
      }
    }
  }
  return { score: D[length1][length2], matches: [] };
}