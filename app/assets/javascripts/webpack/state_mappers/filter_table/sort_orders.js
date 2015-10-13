var reverse = function(sortConfig) {
  switch(sortConfig.order){
  case "UP":
    return ["desc"];
  case "DOWN":
    return ["asc"];
  };
}

var doubleReverse = function(sortConfig) {
  switch(sortConfig.order){
  case "UP":
    return ["desc", "desc"];
  case "DOWN":
    return ["asc", "asc"]
  };
}

module.exports = {
  clinics: function(sortConfig) {
    switch(sortConfig.column) {
    case "NAME":
      return reverse(sortConfig);
    case "SPECIALTIES":
      return reverse(sortConfig);
    case "REFERRALS":
      return doubleReverse(sortConfig);
    case "WAITTIME":
      return reverse(sortConfig);
    case "CITY":
      return doubleReverse(sortConfig);
    default:
      return reverse(sortConfig);
    }
  },
  specialists: function(sortConfig) {
    switch(sortConfig.column) {
    case "NAME":
      return reverse(sortConfig);
    case "SPECIALTIES":
      return reverse(sortConfig);
    case "REFERRALS":
      return doubleReverse(sortConfig);
    case "WAITTIME":
      return reverse(sortConfig);
    case "CITY":
      return doubleReverse(sortConfig);
    default:
      return reverse(sortConfig);
    }
  },
  contentCategories: function(sortConfig) {
    switch(sortConfig.column) {
    case "TITLE":
      return reverse(sortConfig);
    case "SUBCATEGORY":
      return reverse(sortConfig);
    default:
      return reverse(sortConfig);
    }
  }
}
