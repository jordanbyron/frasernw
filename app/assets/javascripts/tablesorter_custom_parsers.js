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
        case(">18 months"):
          return 9;
        default:
          return 10;
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
        case("available"):
          return 0;
        case("warning"):
          return 1;
        case("unavailable"):
          return 2;
        case("unknown"):
          return 3;
        default:
          return 4;
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
      if (s === '') {
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
		format: function(s) {
                        return s.split(" ").reverse().toString().toLowerCase();
		}, 
    // set type, either numeric or text 
    type: 'text'
});