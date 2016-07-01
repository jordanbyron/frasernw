const stringScore = (string1, string2, fuzziness) => {
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

  var overall_score = 0;
  for ( var x = 0; x < best_match.length; ++x )
  {
    overall_score += best_match[x];
  }
  overall_score /= best_match.length;

  return overall_score;
};

export default stringScore;
