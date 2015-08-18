var objectAssign = require("object-assign");

module.exports = function(state={city: true}, action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.filterVisibility;
  case "TOGGLE_FILTER_VISIBILITY":
    var newSetting = {};
    newSetting[action.filterKey] = !state[action.filterKey];

    return objectAssign(
      {},
      state,
      newSetting
    );
  default:
    return state;
  }
}
