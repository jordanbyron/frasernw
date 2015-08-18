var objectAssign = require("object-assign");

var initialState = {
  headings: ["one"],
  records: []
};

module.exports = function(state = initialState, action) {
  console.log(action);
  switch (action.type) {
  case "INITIALIZE_FROM_SERVER":
    return objectAssign({}, action.initialState);
  default:
    return state;
  }
}
