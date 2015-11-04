var app = require("./app");
var _ = require("lodash");

// app - what is true 'objectively' about Pathways
// ui - what is true about this view in particular
module.exports = function(uiReducerKey) {
  var uiReducer = require(`./${_.snakeCase(uiReducerKey)}/ui`);

  return function(state = {}, action) {
    switch(action.type){
    case "@@redux/INIT":
      return {
        app: {},
        ui: { hasBeenInitialized: false }
      };
    default:
      return {
        app: app(state.app, action),
        ui: uiReducer(state.ui, action)
      };
    }
  }
}
