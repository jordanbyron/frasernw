import app from "dry_reducers/app";

const rootReducer = (model = {}, action) => {
  return {
    ui: ui(model.ui, action),
    app: app(model.app, action)
  }
}

const ui = (model = {}, action) => {
  switch(action.type){
  case "PARSE_RENDERED_DATA":
    if(action.data.ui){
      return _.assign(
        {},
        model,
        action.data.ui
      );
    }
    else {
      return model;
    }
  default:
    return {
      recordsToDisplay: recordsToDisplay(model.recordsToDisplay, action),
      selectedTableHeading: selectedTableHeading(model.selectedTableHeading, action),
      location: location(model.location, action),
      isBreadcrumbDropdownOpen: isBreadcrumbDropdownOpen(
        model.isBreadcrumbDropdownOpen,
        action
      ),
      reducedView: reducedView(model.reducedView, action),
      tabs: tabs(model.tabs, action),
      latestUpdates: latestUpdates(model.latestUpdates, action),
      persistentConfig: model.persistentConfig,
      feedbackModal: feedbackModal(model.feedbackModal, action)
    };
  }
}

const feedbackModal = (model = {}, action) => {
  return {
    state: feedbackModalState(model.state, action),
    item: feedbackModalItem(model.item, action)
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

const feedbackModalItem = (model, action) => {
  switch(action.type){
  case "SET_FEEDBACK_MODAL_STATE":
    if(action.proposed === "CLOSED") {
      return {};
    }
    else {
      return model;
    }
  case "OPEN_FEEDBACK_MODAL":
    return action.item;
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
    specializationFilterActivated: specializationFilterActivated(
      model.specializationFilterActivated,
      action
    ),
    currentPage: currentPage(model.currentPage, action)
  };
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

const isBreadcrumbDropdownOpen = (model, action) => {
  switch(action.type){
  case "TOGGLE_BREADCRUMB_DROPDOWN":
    return action.newState;
  default:
    return false;
  }
}

const location = (model, action) => {
  switch(action.type){
  case "PARSE_LOCATION":
    return action.location;
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
