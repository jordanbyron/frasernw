var ui = require("./specialization_page/ui");
var app = require("./app");
var _ = require("lodash");

// app - what is true 'objectively' about Pathways
// ui - what is true about this view in particular

module.exports = function(state = {}, action) {
  // console.log("ACTION:");
  // console.log(action);

  switch(action.type){
  case "@@redux/INIT":
    return {
      app: {},
      ui: { hasBeenInitialized: false }
    };
  default:
    return {
      app: app(state.app, action),
      ui: ui(state.ui, action)
    };
  }
}
