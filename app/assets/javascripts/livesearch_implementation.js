function data_scores_matches(search_data_entry, term) 
{
    var name_score_matches = search_data_entry[0].score_matches(term,0); //name only for now
    return [[name_score_matches[0]], [name_score_matches[1]]];
}

Array.prototype.hasValue = function(value)
{
    for (var i=0; i<this.length; i++) { if (this[i] === value) return true; }
    return false;
}

function highlight(string, matches)
{
    var output = "";
    var string_length = string.length;
    var currently_highlighted = false;
    
    for ( var i = 0; i < string_length; ++i )
    {
        var should_highlight = matches.hasValue(i);
        
        if ( should_highlight && !currently_highlighted )
        {
            output += "<b>";
            currently_highlighted = true;
        }
        else if ( !should_highlight && currently_highlighted )
        {
            output += "</b>";
            currently_highlighted = false;
        }
        
        output += string.charAt(i);
    }
    
    if ( currently_highlighted )
    {
        output += "</b>";
    }
    
    return output;
}

function format_search_result(total_score, scores, matches, search_data_entry)
{
    return '<li>' + highlight( search_data_entry[0], matches[0] ) + '</li>';
}