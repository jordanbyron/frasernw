var setAllOwnValues = require("../../utils.js").setAllOwnValues;
var objectAssign = require("object-assign");
var isPlainObject = require("lodash/lang/isPlainObject");

module.exports = function(state={city:{}}, action) {
  switch(action.type) {
  case "FILTER_UPDATED":
    if (action.update.isPlainObject) {
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
  default:
    return state;
  }
}
