var setAllOwnValues = require("../../utils.js").setAllOwnValues;
var objectAssign = require("object-assign");

module.exports = function(state={city:{}}, action) {
  switch(action.type) {
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.filters
  case "FILTER_UPDATED":
    var newFilter = objectAssign(
      {},
      state[action.filterType],
      action.update
    );

    return objectAssign(
      {},
      state,
      { [action.filterType]: newFilter }
    );
  default:
    return state;
  }
}
