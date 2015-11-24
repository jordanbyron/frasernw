export default function(state, action) {
  switch(action.type){
  case "TOGGLE_REDUCED_VIEW":
    return action.newView;
  default:
    return state;
  }
};
