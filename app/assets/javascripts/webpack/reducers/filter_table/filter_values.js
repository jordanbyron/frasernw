var setAllOwnValues = require("../../utils.js").setAllOwnValues;
var objectAssign = require("object-assign");
var isPlainObject = require("lodash/lang/isPlainObject");
var isNumber = require("lodash/lang/isNumber");
var isBoolean = require("lodash/lang/isBoolean");
var mapValues = require("lodash/object/mapValues");
var _ = require("lodash");

module.exports = function(state={}, action) {
  switch(action.type) {
  // values for checkboxes or selectors in filter section on right hand side
  // of filter table
  case "UPDATE_FILTER":
    if (isPlainObject(action.update)) {
      // filter has many keys and values
      var newFilter = objectAssign(
        {},
        state[action.filterType],
        action.update
      );
    } else {
      // filter has a single value
      var newFilter = action.update;
    }

    return objectAssign(
      {},
      state,
      { [action.filterType]: newFilter }
    );
  case "RESET_SEARCH_ALL_CITIES":
    // back to default

    return _.assign(
      {},
      state,
      {
        searchAllCities: false,
        cities: undefined
      }
    );
  case "CLEAR_FILTERS":
    return {};
  default:
    return state;
  }
}
