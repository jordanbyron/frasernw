var objectAssign = require("object-assign");
var mapValues = require("lodash/object/mapValues");

module.exports = function(state={city: true}, action) {
  switch(action.type){
  case "TOGGLE_FILTER_GROUP_VISIBILITY":
    return objectAssign(
      {},
      state,
      { [action.filterKey] : !action.isOpen }
    );
  default:
    return state;
  }
}
