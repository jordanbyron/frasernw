var ui = require("./specialization_page/ui");
var app = require("./app");
var _ = require("lodash");
var UIReducers = {
  SpecializationPage: require("./specialization_page/ui"),
  ReferentsBySpecialty: require("./referents_by_specialty/ui")
}

// app - what is true 'objectively' about Pathways
// ui - what is true about this view in particular
module.exports = function(uiReducerKey) {
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
        ui: UIReducers[uiReducerKey](state.ui, action)
      };
    }
  }
}
