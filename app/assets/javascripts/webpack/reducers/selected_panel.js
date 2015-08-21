module.exports = function(state = "", action) {
  switch(action.type){
  case "SELECT_PANEL":
    return action.panel;
  default:
    return state;
  }
}
