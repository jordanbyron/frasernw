const rootReducer = (model = {}, action) => {
  return {
    ui: ui(model.ui, action),
    app: app(model.app, action)
  }
}

const app = (model = {}, action) => {
  if(action.type === "PARSE_RENDERED_DATA") {
    return action.data;
  }
  else {
    return model;
  }
}

const ui = (model = {}, action) => {
  return {
    recordsToDisplay: recordsToDisplay(model.recordsToDisplay, action),
    filterValues: filterValues(model.filterValues, action),
    selectedTableHeading: selectedTableHeading(model.selectedTableHeading, action),
    location: location(model.location, action),
    isBreadcrumbDropdownOpen: isBreadcrumbDropdownOpen(model.isBreadcrumbDropdownOpen, action),
    reducedView: reducedView(model.reducedView, action),
    panels: panels(model.panels, action)
  };
}

const panels = (model = {}, action) => {
  return _.assign(
    {},
    model,
    { [action.panelKey]: panel(model[action.panelKey], action) }
  );
};

const panel = (model = {}, action) => {
  return {
    isFilterGroupExpanded: isFilterGroupExpanded(model, action)
  };
}

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
  case "LOCATION_CHANGED":
    return false;
  default:
    return model;
  }
}

const location = (model, action) => {
  switch(action.type){
  case "LOCATION_CHANGED":
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

const filterValues = (model, action) => {
  switch(action.type){
  case "CHANGE_FILTER_VALUE":
    return _.assign(
      {},
      model,
      { [action.filterKey]: action.newValue }
    );
  default:
    return model;
  }
};

export default rootReducer;
