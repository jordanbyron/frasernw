const ui = (state = {}, action) => {
  return {
    selectedPanel: selectedPanel(state.selectedPanel, action),
    location: location(state.location, action)
  };
};


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
