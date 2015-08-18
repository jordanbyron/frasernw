var objectAssign = require("object-assign");

module.exports = function(state = [], action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.records;
  default:
    return state;
  }
}
