module.exports = {
  referents: function(sortConfig) {
    switch(sortConfig.column) {
    case "NAME":
      return function(row){ return row.record.name; };
    case "REFERRALS":
      return function(row){ return row.record.statusIconClasses; };
    case "WAITTIME":
      return function(row){ return row.record.waittime; };
    case "CITY":
      return function(row){ return row.cells[3]; };
    default:
      return function(row){ return row.record.name; };
    }
  },
  resources: function(sortConfig) {
    switch(sortConfig.column) {
    case "TITLE":
      return function(row){ return row.record.title; };
    case "SUBCATEGORY":
      return function(row){ return row.cells[2]; };
    default:
      return function(row){ return row.record.title; };
    }
  }
}
