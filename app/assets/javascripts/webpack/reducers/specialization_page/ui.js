var PANEL_REDUCERS = {
  FilterTable: require("../filter_table"),
  InlineArticles: function(state, action) { return state }
}
var hasBeenInitialized = require("../has_been_initialized");

module.exports = function(state = {}, action) {
  switch(action.type) {
  default:
    return {
      hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
      selectedPanel: selectedPanel(state.selectedPanel, action),
      specializationId: specializationId(state.specializationId, action),
      panels: panels(state.panels, action),
      feedbackModal: feedbackModal(state.feedbackModal, action)
    }
  }
}

var feedbackModal = function(state, action) {
  switch(action.type){
  case "OPEN_FEEDBACK_MODAL":
    return _.assign(
      {},
      {
        state: "PRE_SUBMIT"
      },
      action.data
    );
  case "CLOSE_FEEDBACK_MODAL":
    return {
      state: "HIDDEN"
    };
  case "SUBMITTING_FEEDBACK":
    return _.assign(
      {},
      state,
      { state: "SUBMITTING" }
    );
  case "SUBMITTED_FEEDBACK":
    return _.assign(
      {},
      state,
      { state: "POST_SUBMIT" }
    );
  default:
    return state;
  }
};

var specializationId = function(state, action) {
  switch(action.type) {
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.ui.specializationId;
  default:
    return state;
  }
}

// (tabs e.g. 'specialists', 'clinics', 'physician resources')
var panels = function(state = {}, action) {
  if (action.panelKey) {
    var reducer = PANEL_REDUCERS[action.reducer];

    return _.assign(
      {},
      state,
      { [action.panelKey]: reducer(state[action.panelKey], action) }
    );
  } else {
    return state;
  };
}

var selectedPanel = function(state, action) {
  switch(action.type) {
  case "SELECT_PANEL":
    return action.panel;
  default:
    return state;
  }
}
