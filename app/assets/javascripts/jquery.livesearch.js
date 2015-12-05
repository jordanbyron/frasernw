$.fn.livesearch = function(options)
{
  var container = $(options.container);
  var search_all = $(options.search_all);
  var search_all_url = options.search_all_url;
  var list = container.children('ul.search_results');
  var global_data = options.global_data;
  var division_entry_data = options.division_entry_data;
  var division_content_data = options.division_content_data;
  var scorer_fnc = options.scorer || scorer;
  var grouper_fnc = options.grouper || grouper;
  var data_formatter_fnc = options.data_formatter || data_formatter;
  var group_formatter_fnc = options.group_formatter || group_formatter;
  var empty_fnc = options.empty || empty;
  var searcher_fnc = options.searcher || searcher;
  var fuzziness = options.fuzziness || 0.5;
  var max_results = options.max_results || 10;
  var min_score = options.min_score || 0.5;
  var always_match_something = options.always_match_something;
  var results = [];
  var selected = -1;
  var that = this;
  var data;
  use_division_data();

  container.mouseover( function() { set_selected(-1) });

  var on_blur = function(e) {
    if($("#search_results").is(":hover")){
      return false;
    } else {
      setTimeout(hide_search_if_unfocused,100);
    }
  }

  this
    .keyup(filter_search)
    .focus(filter_search)
    .blur(on_blur)
    .parents('form').submit( function() { if (results.length > 0) { that.blur(); return searcher_fnc(results[selected].data_entry) } else { return false; } });

  $(".livesearch__search-category").click(function(e) {

    $(this).addClass("livesearch__search-category--selected")
    $(".livesearch__search-category").not(this).removeClass("livesearch__search-category--selected")
    if($(this).attr("data-category") == 4){
      $(".livesearch__filter-group--scopes").hide();
    } else {
      $(".livesearch__filter-group--scopes").show();
    }
    that.trigger('focus'); // refresh results
  });

  $(".livesearch__search-scope").click(function(e) {
    if($(e.target).hasClass(".livesearch__search-scope--selected")) {
      return;
    }

    $(".livesearch__search-scope").toggleClass("livesearch__search-scope--selected");
    if ($(this).attr("data-scope") === "global")
    {
      if (typeof pathways_all_search_data == 'undefined')
      {
        //load all data
        that.trigger('focus'); //maintain focus
        container.addClass('loading');
        $.ajax({
          url: search_all_url,
          dataType: 'script'
        }).success(function() {
          use_all_data();
          container.removeClass('loading');
        }).fail(function(){
          container.removeClass('loading');
        });
      }
      else
      {
        //already loaded all data, flip to it
        use_all_data();
        that.trigger('focus'); //maintain focus
      }
    }
    else
    {
      //go back to divisional data
      use_division_data();
      that.trigger('focus'); //maintain focus
    }
  }).blur(function(){ setTimeout(hide_search_if_unfocused,100) });

  return this;

  function disable_page_scroll()
  {
    $("html").css("height", "100%");
    $("body").css("height", "100%");
    $("body").css("padding-bottom", "0px");
    $("body").css("overflow", "hidden");
  }
  function enable_page_scroll()
  {
    $("html").css("height", "");
    $("body").css("height", "");
    $("body").css("padding-bottom", "");
    $("body").css("overflow", "");
  }

  function hide_search()
  {
    container.animate({height: "hide"}, 200)
    enable_page_scroll();
  }


  function hide_search_if_unfocused()
  {
    if (!(that.is(':focus')))
    {
      hide_search();
    }
  }

  function use_all_data()
  {
    data = global_data.concat(pathways_all_search_data);
    for (var division_id in division_content_data)
    {
      data = data.concat(division_content_data[division_id]);
    }
    data = $(data);
    that.trigger('focus'); //refresh results
  }

  function use_division_data()
  {
    data = global_data;
    for (var division_id in division_entry_data)
    {
      data = data.concat(division_entry_data[division_id]);
    }
    for (var division_id in division_content_data)
    {
      data = data.concat(division_content_data[division_id]);
    }
    data = $(data);
    that.trigger('focus'); //refresh results
  }

  function effective_max_results(max_results, selected_category) {
    if(selected_category === "0") {
      return max_results;
    }
    else {
      return 999;
    }
  }

  function filter_search(event)
  {
    disable_page_scroll();
    if (event && event.keyCode == 38)
    {
      //up key
      if ( --selected < 0 )
      {
        selected = 0
      }
      set_selected(selected)
      return;
    }
    else if (event && event.keyCode == 40)
    {
      //down key
      if ( ++selected >= results.length )
      {
        selected = (results.length - 1)
      }
      set_selected(selected)
      return;
    }

    var term = $.trim( $(this).val().toLowerCase() )

    if ( !term )
    {
      hide_search();
      return
    }

    list.empty()

    results = [];

    var best_match = null;

    selected_button = $(".livesearch__search-category--selected")
    selected_category = selected_button.attr("data-category");
    // only relevant if we've selected a content category
    selected_root_content_category = selected_button.attr("data-root-id");

    data.each(function()
    {
      // filter by cateogry
      if(selected_category === "0") {
        // Searching All
        // noop
      }
      else if (selected_category === "4" && this.rc !== parseInt(selected_root_content_category)) {
        // Searching for ScItem
        return;
      }
      else if (selected_category !== "4" && selected_category !== this.go) {
        // Searching for anything else
        return;
      }

      // proceed to scoring

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

    results = results
      .sort(function(a, b){return b.total_score - a.total_score})
      .slice(0, effective_max_results(max_results, selected_category));

    var last_group = -999;
    $.each(results.sort(grouper_fnc), function(index, entry)
    {
      if (last_group != entry.data_entry.go )
      {
        last_group = entry.data_entry.go
        list.append(group_formatter_fnc(entry.data_entry.go))
      }
      list.append(data_formatter_fnc(entry.total_score, entry.scores_matches, entry.data_entry, term))
    });

    selected = 0
    set_selected(selected)

    set_results_max_height();
    container.animate({height: "show"}, 200)
  }

  function set_results_max_height()
  {
    var top_y = $("#main-nav").offset().top + $("#main-nav").height();
    var max_height = $(window).height() - top_y;

    $("#search_results").css("max-height", max_height);
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

  function data_formatter(total_score, scores_matches, data_entry, term)
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

  var arr1 = string1.trim().toLowerCase().split(' ');
  var arr2 = string2.trim().toLowerCase().split(' ');

  var best_match = new Array(arr1.length);

  for(var x = 0; x < arr1.length; ++x)
  {
    best_match[x] = 0;
    var piece1 = arr1[x];
    var piece1_length = piece1.length;

    for (var y = 0; y < arr2.length; ++y )
    {
      var piece2 = arr2[y]

      // perfect match?
      if (piece1 == piece2)
      {
        best_match[x] = 1.0;
        break;
      }

      var total_character_score = 0;
      var piece2_length = piece2.length;
      var max_length = Math.max(piece1_length, piece2_length);
      var start_of_word_matches = 0;
      var num_matches = 0;
      var fuzzies = 1;
      var piece_score;

      var piece1_index = 0;
      var bonuses = 0;

      while (piece1_index < piece1_length)
      {
        // Find the longest match remaining.
        var found = false;
        var piece2_index = -1;

        for (var match_length = 1; match_length <= piece1_length - piece1_index; ++match_length)
        {
          var cur_index = piece2.indexOf( piece1.substr(piece1_index, match_length) );

          if (cur_index != -1)
          {
            found = true;
            piece2_index = cur_index;
          }
          else
          {
            match_length -= 1;
            break;
          }
        }

        if (!found)
        {
          fuzzies += 1-fuzziness;
          ++piece1_index;
          continue;
        }

        ++num_matches;

        var match_score = match_length / max_length;

        if (piece2_index == 0)
        {
          //matching the start of a search term
          ++start_of_word_matches;
        }

        //bonuses!
        if ((match_length >= 2) && (piece1_index == 0) && (piece2_index == 0))
        {
          //matching the start of a search term to the start of a term
          bonuses += 0.1;

          if ((x == 0) && (y == 0))
          {
            //matched the start of our search to the start of the result
            bonuses += 0.2;
          }
        }

        // Left trim the already matched part of the string (forces sequential matching).
        piece1_index += match_length;
        piece2 = piece2.substring(piece2_index + match_length, piece2_length);

        total_character_score += match_score;
      }

      if (num_matches == 0)
      {
        continue;
      }

      //penalize each match that isn't a start of string
      piece_score = total_character_score - ((num_matches-start_of_word_matches) * 0.1);

      //take into account errors and bonuses
      piece_score = (piece_score / fuzzies) + bonuses;

      best_match[x] = Math.max(piece_score, best_match[x]);
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
