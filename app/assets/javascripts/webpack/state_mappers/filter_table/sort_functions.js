var min = require("lodash/math/min");

var STATUS_CLASS_KEY_RANKINGS = {
  1: 1,
  2: 5,
  3: 3,
  4: 6,
  5: 4,
  6: 99,
  7: 2
};

var WAITTIME_RANKINGS = {
  ["Within one week"]: 1,
  ["1-2 weeks"]: 2,
  ["2-4 weeks"]: 3,
  ["1-2 months"]: 4,
  ["2-4 months"]: 5,
  ["4-6 months"]: 6,
  ["6-9 months"]: 7,
  ["9-12 months"]: 8,
  ["12-18 months"]: 9,
  ["18-24 months"]: 10,
  ["2-2.5 years"]: 11,
  ["2.5-3 years"]: 12,
  [">3 years"]: 13
}

var commonFunctions = {
  referrals: function(row){
    return (STATUS_CLASS_KEY_RANKINGS[row.record.statusClassKey] || 99);
  },
  waittimes: function(row){
    return (WAITTIME_RANKINGS[row.record.waittime] || 99);
  },
  cityPriority: function(sortConfig, cityRankings) {
    return (row) => {
      return min(row.record.cityIds.map((cityId) => cityRankings[cityId]));
    }
  },
  cityName: function(row) {
    if (row.cells.length === 4) {
      return row.cells[3];
    } else {
      return row.cells[4];
    }
  }
}

module.exports = {
  clinics: function(sortConfig, cityRankings) {
    switch(sortConfig.column) {
    case "NAME":
      return [ function(row){ return row.record.name; } ];
    case "SPECIALTIES":
      return [ function(row){ return row.cells[1] } ];
    case "REFERRALS":
      return [ commonFunctions.referrals, commonFunctions.waittimes ];
    case "WAITTIME":
      return [ commonFunctions.waittimes ];
    case "CITY":
      return [ commonFunctions.cityPriority(sortConfig, cityRankings), commonFunctions.cityName ];
    default:
      return [ function(row){ return row.record.name; } ];
    }
  },
  specialists: function(sortConfig, cityRankings) {
    switch(sortConfig.column) {
    case "NAME":
      return [ function(row){ return row.record.lastName.toLowerCase(); } ];
    case "SPECIALTIES":
      return [ function(row){ return row.cells[1] } ];
    case "REFERRALS":
      return [ commonFunctions.referrals, commonFunctions.waittimes ];
    case "WAITTIME":
      return [ commonFunctions.waittimes ];
    case "CITY":
      return [ commonFunctions.cityPriority(sortConfig, cityRankings), commonFunctions.cityName ];
    default:
      return [ function(row){ return row.record.lastName; } ];
    }
  },
  contentCategories: function(sortConfig) {
    switch(sortConfig.column) {
    case "TITLE":
      return [ function(row){ return row.record.title.toLowerCase(); } ];
    case "SUBCATEGORY":
      return [ function(row){ return row.cells[1]; } ];
    default:
      return [ function(row){ return row.record.title; } ];
    }
  }
}
