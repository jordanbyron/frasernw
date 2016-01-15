var reverse = function(sortConfig, numCriteria) {
  var numCriteria = numCriteria || 1;
  var order = {
    UP: "desc",
    DOWN: "asc"
  }[sortConfig.order]

  return _.times(numCriteria, () => order);
}

module.exports = {
  clinics: function(sortConfig) {
    switch(sortConfig.column) {
    case "NAME":
      return reverse(sortConfig);
    case "SPECIALTIES":
      return reverse(sortConfig);
    case "REFERRALS":
      return reverse(sortConfig, 3);
    case "WAITTIME":
      return reverse(sortConfig, 2);
    case "CITY":
      return reverse(sortConfig, 3);
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
      return reverse(sortConfig, 3);
    case "WAITTIME":
      return reverse(sortConfig, 2);
    case "CITY":
      return reverse(sortConfig, 3);
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
