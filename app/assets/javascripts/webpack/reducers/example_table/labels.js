var objectAssign = require("object-assign");

module.exports = function(state={city: {}}, action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.labels;
  default:
    return state;
  }
}
