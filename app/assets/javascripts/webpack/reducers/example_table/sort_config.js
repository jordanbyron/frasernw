var oppositeOrder = function(order) {
  if (order == "ASC"){
    return "DESC";
  } else if (order == "DESC") {
    return "ASC";
  } else {
    throw "Invalid order";
  }
}

module.exports = function(state = {}, action) {
  switch(action.type){
  case "INITIALIZE_FROM_SERVER":
    return action.initialState.sortConfig;
  case "HEADER_CLICK":
    if (action.headerKey == state.column) {
      return {
        column: action.headerKey,
        order: oppositeOrder(state.order)
      };
    } else {
      return {
        column: action.headerKey,
        order: "ASC"
      };
    }
  default:
    return state;
  }
}
