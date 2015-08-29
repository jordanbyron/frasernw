var setAllOwnValues = require("../../utils.js").setAllOwnValues;
var objectAssign = require("object-assign");
var isPlainObject = require("lodash/lang/isPlainObject");
var mapValues = require("lodash/object/mapValues");

var customClearFunctions = {
  respondsWithin: function() {
    return 0;
  },
  city: function(state) {
    return state.city;
  },
  specializationId: function(state) {
    return state.specializationId;
  }
}


module.exports = function(state={}, action) {
  switch(action.type) {
  case "FILTER_UPDATED":
    if (isPlainObject(action.update)) {
      var newFilter = objectAssign(
        {},
        state[action.filterType],
        action.update
      );
    } else {
      var newFilter = action.update;
    }

    return objectAssign(
      {},
      state,
      { [action.filterType]: newFilter }
    );
  case "CLEAR_FILTERS":
    return mapValues(state, (value, key) => {
      if (customClearFunctions[key]){
        return customClearFunctions[key](state);
      } else if (isPlainObject(value)) {
        return mapValues(value, () => false);
      } else {
        return false;
      }
    });
  default:
    return state;
  }
}
