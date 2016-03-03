const ui = (state = {}, action) => {
  return {
    selectedPanel: selectedPanel(state.selectedPanel, action),
    location: location(state.location, action),
    reducedView: reducedView(state.reducedView, action)
  };
};

const reducedView = (state, action) => {
  switch(action.type){
  case "TOGGLE_REDUCED_VIEW":
    return action.newView;
  default:
    return state;
  }
}


const location = (state, action) => {
  switch(action.type){
  case "LOCATION_CHANGED":
    // match the route
    // if authenticated route and user unauthenticated, redirect to /login

    return action.newLocation;
  default:
    return state;
  };
};

const selectedPanel = (state, action) => {
  switch(action.type) {
    case "SELECT_PANEL":
    return action.panel;
    default:
    return state;
  }
};

export default ui;
