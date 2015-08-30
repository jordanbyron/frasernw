var mapValues = require("lodash/object/mapValues");
var objectAssign = require("object-assign");
var reducers = {
  SpecializationClinicsPanel: require("./data_table"),
  SpecializationSpecialistsPanel: require("./data_table")
}

module.exports = function(state = {}, action) {
  switch(action.type){
  case "@@redux/INIT":
    return state;
  case "SELECT_PANEL":
    return state;
  default:
    var contentClass = state[action.panelKey].contentClass
    var reducer = reducers[contentClass];
    var updatedPanel = {
      contentClass: contentClass,
      props: reducer(state[action.panelKey].props, action)
    }

    return objectAssign(
      {},
      state,
      { [action.panelKey]: updatedPanel }
    );
  }
}
