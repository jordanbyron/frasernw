const rootReducer = (model = {}, action) => {
  return {
    ui: ui(model.ui, action)
  }
}

const ui = (model = {}, action) => {
  return {
    recordsToDisplay: recordsToDisplay(model.recordsToDisplay, action),
    filterValues: filterValues(model.filterValues, action)
  };
}

const recordsToDisplay = (model, action) => {
  switch(action.type){
  case "DATA_RECEIVED":
    return action.recordsToDisplay;
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
