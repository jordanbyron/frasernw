var PANEL_REDUCERS = {
  FilterTable: require("../filter_table"),
  InlineArticles: function(state, action) { return state }
}
var hasBeenInitialized = require("../has_been_initialized");

var pageRenderedKey = function(key, stateAtKey, action) {
  switch(action.type) {
  case "INTEGRATE_PAGE_RENDERED_DATA":
    return action.initialState.ui[key];
  default:
    return stateAtKey;
  }
};
var procedureId = _.partial(pageRenderedKey, "procedureId");
var specializationId = _.partial(pageRenderedKey, "specializationId");
var pageType = _.partial(pageRenderedKey, "pageType");


module.exports = function(state = {}, action) {
  switch(action.type) {
  default:
    return {
      hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action),
      selectedPanel: selectedPanel(state.selectedPanel, action),
      specializationId: specializationId(state.specializationId, action),
      procedureId: procedureId(state.procedureId, action),
      pageType: pageType(state.pageType, action),
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
