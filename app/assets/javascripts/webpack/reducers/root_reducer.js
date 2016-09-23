import app from "reducers/app";
import _ from "lodash";
import { uiKeysMirroredToUrlHash } from "url_hash_mirroring";
import { decode } from "utils/url_hash_encoding";
import { route } from "controller_helpers/routing";


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
  case "PARSE_URL_HASH":
    return _.assign(
      {},
      model,
      _.zipObject(uiKeysMirroredToUrlHash, []),
      fromUrlHash(model)
    )
  default:
    return {
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
      searchTimerId: searchTimerId(model.searchTimerId, action),
      selectedSearchResult: selectedSearchResult(model.selectedSearchResult, action),
      highlightSelectedSearchResult: highlightSelectedSearchResult(
        model.highlightSelectedSearchResult,
        action
      ),
      dropdownSpecializationId: model.dropdownSpecializationId,
      reducedView: reducedView(model.reducedView, action),
      tabs: tabs(model.tabs, action),
      selectedTabKey: selectedTabKey(model.selectedTabKey, action)
    };
  }
};

const searchTimerId = (model, action) => {
  switch(action.type){
  case "TERM_SEARCHED":
    return action.timerId;
  case "SEARCH_TIMEOUT_ENDED":
    return undefined;
  default:
    return model;
  }
}

const fromUrlHash = (model) => {
  if (window.location.hash.length === 0 || _.isUndefined(route)){
    return {};
  }
  else {
    return decode(
      window.location.hash.slice(1, window.location.hash.length)
    );
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
    return action.proposedTerm;
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
  case "REQUESTING_DATA":
    return undefined;
  default:
    return model;
  }
};

const selectedTabKey = (model, action) => {
  switch(action.type){
  case "TAB_CLICKED":
    return action.proposed;
  default:
    return model;
  }
}

const tabs = (model = {}, action) => {
  if (action.tabKey) {
    return _.assign(
      {},
      model,
      { [action.tabKey]: tab(model[action.tabKey], action) }
    );
  }
  else {
    return model;
  }
};

const tab = (model = {}, action) => {
  return {
    isFilterGroupExpanded: isFilterGroupExpanded(model.isFilterGroupExpanded, action),
    filterValues: filterValues(model.filterValues, action),
    showUnfocusedProcedures: showUnfocusedProcedures(
      model.showUnfocusedProcedures,
      action
    ),
    selectedTableHeading: selectedTableHeading(model.selectedTableHeading, action),
    specializationFilterActivated: specializationFilterActivated(
      model.specializationFilterActivated,
      action
    ),
    currentPage: currentPage(model.currentPage, action),
    areRowsExpanded: areRowsExpanded(model.areRowsExpanded, action)
  };
}



const areRowsExpanded = (model, action) => {
  switch(action.type){
  case "TOGGLE_ROW_EXPANSIONS":
    return action.proposed;
  default:
    return model;
  }
}

const currentPage = (model, action) => {
  switch(action.type){
  case "SET_PAGE":
    return action.proposed;
  default:
    return model;
  }
}

const specializationFilterActivated = (model, action) => {
  switch(action.type){
  case "TOGGLE_SPECIALIZATION_FILTER":
    return action.proposed;
  default:
    return model;
  }
}

const showUnfocusedProcedures = (model, action) => {
  switch(action.type){
  case "TOGGLE_UNFOCUSED_PROCEDURE_VISIBILITY":
    return action.proposed;
  default:
    return model;
  }
};

const isFilterGroupExpanded = (model = {}, action) => {
  switch(action.type){
  case "TOGGLE_FILTER_GROUP_EXPANSION":
    return _.assign(
      {},
      model,
      { [action.filterGroupKey] : action.proposed }
    );
  default:
    return model;
  }
};

const reducedView = (model, action) => {
  switch(action.type){
  case "SELECT_REDUCED_VIEW":
    return action.newView;
  default:
    return model;
  }
}

const selectedTableHeading = (model = {}, action) => {
  switch(action.type){
  case "SORT_BY_HEADING":
    if(action.currentKey === action.key) {
      if (model.direction === "UP") {
        return {
          key: action.key,
          direction: "DOWN"
        };
      }
      else {
        return {
          key: action.key,
          direction: "UP"
        };
      }
    }
    else {
      return {
        key: action.key,
        direction: "DOWN"
      }
    }
  default:
    return model;
  }

}

const filterValues = (model = {}, action) => {
  switch(action.type){
  case "CHANGE_FILTER_VALUE":
    if(action.filterSubKey) {
      var newValue = _.assign(
        {},
        model[action.filterKey],
        { [action.filterSubKey] : action.proposed }
      );
    }
    else {
      var newValue = action.proposed;
    }

    return _.assign(
      {},
      model,
      { [action.filterKey]: newValue }
    );
  case "UPDATE_CITY_FILTERS":
    return _.assign(
      {},
      model,
      { cities: action.proposed }
    );
  case "CLEAR_FILTERS":
    return {};
  default:
    return model;
  }
};


export default rootReducer;
