var selectedPanel = require("./selected_panel");
var panels = require("./panels");

module.exports = function(state = {}, action) {
  console.log(action);
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState;
  default:
    return {
      selectedPanel: selectedPanel(state.selectedPanel, action),
      panelNav: (state.panelNav || []),
      panels: panels(state.panels, action),
      globalData: state.globalData
    };
  }
}
