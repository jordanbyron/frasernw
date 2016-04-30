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
    filterValues: filterValues(model.filterValues, action)
  };
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
