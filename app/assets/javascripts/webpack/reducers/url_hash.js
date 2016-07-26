import _ from "lodash"

const urlHash = (model = {}, action) => {
  return {
    reducedView: reducedView(model.reducedView, action),
    tabs: tabs(model.tabs, action),
    selectedTabKey: selectedTabKey(model.selectedTabKey, action)
  }
}

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

export default urlHash;
