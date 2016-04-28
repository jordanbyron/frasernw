const rootReducer = (model = {}, action) => {
  return {
    ui: ui(model.ui, action)
  }
}

const ui = (model = {}, action) => {
  switch(action.type){
  case "DATA_RECEIVED":
    return {
      recordsToDisplay: action.recordsToDisplay
    };
  default:
    return model;
  }
}

export default rootReducer;
