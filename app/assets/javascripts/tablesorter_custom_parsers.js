$.tablesorter.addParser({ 
    id: 'waittime', 
    is: function(s) { 
      return false; 
    }, 
		format: function(s) {
			switch(s)
      {
        case("Within one week"):
          return 0;
        case("1-2 weeks"):
          return 1;
        case("2-4 weeks"):
          return 2;
        case("1-2 months"):
          return 3;
        case("2-4 months"):
          return 4;
        case("4-6 months"):
          return 5;
        case("6-9 months"):
          return 6;
        case("9-12 months"):
          return 7;
        case("12-18 months"):
          return 8;
        case("18-24 months"):
          return 9;
        case("2-2.5 years"):
          return 10;
        case("2.5-3 years"):
          return 11;
        case(">3 years"):
          return 12;
        default:
          return 13;
      }
		}, 
    // set type, either numeric or text 
    type: 'numeric' 
});

$.tablesorter.addParser({ 
    id: 'status', 
    is: function(s) { 
      return false; 
    }, 
		format: function(s) {
			switch($.trim(s))
      {
        case("1"): //available
        case("11"): //conditional (sort with available)
          return 0;
        case("3"): //warning
          return 1;
        case("5"): //external
          return 2;
        case("2"): //unavailable
          return 3;
        case("4"): //unknown
          return 4;
        default:
          return 5;
      }
		}, 
    // set type, either numeric or text 
    type: 'numeric' 
});


// added by krh to push blanks to bottom
$.tablesorter.addParser({ 
    // set a unique id 
    id: 'blanks_to_bottom', 
    is: function(s) { 
      return false; 
    }, 
		format: function(s) {
      if ($.trim(s) === '') {
  			return "zzzzzz";
			} else {
			  return s;
			}
		}, 
    // set type, either numeric or text 
    type: 'text'
});
// added by rpw to sort by last name
$.tablesorter.addParser({ 
    // set a unique id 
    id: 'bylastname', 
    is: function(s) { 
      return false; 
    },
		format: function(s, table, cell, cellIndex) {
      return $(cell).children('a').text().trim().split(" ").reverse().toString().toLowerCase();
    },
    // set type, either numeric or text 
    type: 'text'
});
// added by rpw to sort by link
$.tablesorter.addParser({ 
    // set a unique id 
    id: 'link_only', 
    is: function(s) { 
      return false; 
    },
		format: function(s, table, cell, cellIndex) {
      return $(cell).children('a').text().toLowerCase();
    },
    // set type, either numeric or text 
    type: 'text'
});