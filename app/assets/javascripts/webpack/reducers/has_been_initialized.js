module.exports = function(state = false, action) {
  switch(action.type) {
  case "INTEGRATE_LOCALSTORAGE_DATA":
    return true;
  default:
    return state;
  }
}
