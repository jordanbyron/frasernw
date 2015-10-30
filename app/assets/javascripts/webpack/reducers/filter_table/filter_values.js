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
  case "ASYNC_FILTER_UPDATE":
    return updateFilter(state, action);
  case "UPDATE_FILTER":
    return updateFilter(state, action);
  case "CLEAR_FILTERS":
    return {};
  default:
    return state;
  }
}

var updateFilter = function(state, action) {
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
}
