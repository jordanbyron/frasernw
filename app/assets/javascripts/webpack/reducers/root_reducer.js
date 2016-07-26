import app from "reducers/app";
import urlHash from "reducers/url_hash";
import _ from "lodash";

const rootReducer = (model = {}, action) => {
  return {
    ui: ui(model.ui, action),
    app: app(model.app, action)
  }
}

const ui = (model = {}, action) => {
  switch(action.type){
  case "PARSE_RENDERED_DATA":
    var uiData = action.data.map(_.property("ui")).filter(_.identity)

    return _.assign(...[{}, model].concat(uiData));
  default:
    let fromStore = {
      recordsToDisplay: recordsToDisplay(model.recordsToDisplay, action),
      isBreadcrumbDropdownOpen: isBreadcrumbDropdownOpen(
        model.isBreadcrumbDropdownOpen,
        action
      ),
      latestUpdates: latestUpdates(model.latestUpdates, action),
      persistentConfig: model.persistentConfig,
      feedbackModal: feedbackModal(model.feedbackModal, action),
      searchIsFocused: searchIsFocused(model.searchIsFocused, action),
      searchTerm: searchTerm(model.searchTerm, action),
      searchCollectionFilter: searchCollectionFilter(model.searchCollectionFilter, action),
      searchGeographicFilter: searchGeographicFilter(model.searchGeographicFilter, action),
      selectedSearchResult: selectedSearchResult(model.selectedSearchResult, action),
      highlightSelectedSearchResult: highlightSelectedSearchResult(
        model.highlightSelectedSearchResult,
        action
      ),
      dropdownSpecializationId: model.dropdownSpecializationId
    };

    return _.assign(
      {},
      fromStore,
      fromUrlHash(model, action),
      { pathname: window.location.pathname }
    );
  }
};

const fromUrlHash = (model, action) => {
  if (window.location.hash.length === 0){
    return {};
  }
  else {
    window.pathways.urlHashFlushed = true;
    return JSON.parse(window.location.hash.replace("#", ""));
  }
}


const highlightSelectedSearchResult = (model, action) => {
  switch(action.type){
  case "HOVER_LEAVE_SEARCH_RESULT":
    return false;
  default:
    return true;
  }
}


const selectedSearchResult = (model, action) => {
  switch(action.type){
  case "SEARCH_RESULT_SELECTED":
    return action.proposed;
  case "CLOSE_SEARCH":
    return 0;
  default:
    return model;
  }
}

const searchGeographicFilter = (model, action) => {
  switch(action.type){
  case "SEARCH_GEOGRAPHIC_FILTER":
    return action.proposed;
  default:
    return model;
  }
}

const searchCollectionFilter = (model, action) => {
  switch(action.type){
  case "SEARCH_COLLECTION_FILTER":
    return action.proposed;
  default:
    return model;
  }
}

const searchTerm = (model, action) => {
  switch(action.type){
  case "TERM_SEARCHED":
    return action.proposed;
  case "CLOSE_SEARCH":
    return "";
  case "SEARCH_FOCUS_CHANGED":
    if(action.proposed){
      return model;
    }
    else {
      return "";
    }
  default:
    return model;
  }
}

const searchIsFocused = (model, action) => {
  switch(action.type){
  case "SEARCH_FOCUS_CHANGED":
    return action.proposed;
  default:
    return model;
  }
}

const feedbackModal = (model = {}, action) => {
  return {
    state: feedbackModalState(model.state, action),
    target: feedbackModalTarget(model.target, action)
  }
}

const feedbackModalState = (model, action) => {
  switch(action.type){
  case "SET_FEEDBACK_MODAL_STATE":
    return action.proposed;
  case "OPEN_FEEDBACK_MODAL":
    return "PRE_SUBMIT";
  default:
    return model;
  }
}

const feedbackModalTarget = (model, action) => {
  switch(action.type){
  case "SET_FEEDBACK_MODAL_STATE":
    if(action.proposed === "CLOSED") {
      return {};
    }
    else {
      return model;
    }
  case "OPEN_FEEDBACK_MODAL":
    return action.target;
  default:
    return model;
  }
}

const latestUpdates = (model, action) => {
  switch(action.type){
  case "TOGGLE_UPDATE_VISIBILITY":
    const toUpdate = _.find(model, _.matches(action.update))
    const toUpdateIndex = _.findIndex(model, _.matches(action.update))
    const updated = _.assign(
      {},
      toUpdate,
      { hidden: action.hide }
    );

    const newUpdates = _.clone(model);

    newUpdates[toUpdateIndex] = updated;

    return newUpdates;
  default:
    return model;
  }
}

const isBreadcrumbDropdownOpen = (model, action) => {
  switch(action.type){
  case "TOGGLE_BREADCRUMB_DROPDOWN":
    return action.proposed;
  default:
    return false;
  }
}


const recordsToDisplay = (model, action) => {
  switch(action.type){
  case "DATA_RECEIVED":
    return action.recordsToDisplay;
  case "CHANGE_FILTER_VALUE":
    return undefined;
  default:
    return model;
  }
};


export default rootReducer;
