var oppositeOrder = function(order) {
  if (order == "UP"){
    return "DOWN";
  } else if (order == "DOWN") {
    return "UP";
  } else {
    throw "Invalid order";
  }
}

module.exports = function(state = {}, action) {
  switch(action.type){
  case "TOGGLE_ORDER_BY_COLUMN":
    if (action.headerKey == action.currentColumn) {
      return {
        column: action.headerKey,
        order: oppositeOrder(action.currentOrder)
      };
    } else {
      return {
        column: action.headerKey,
        order: "DOWN"
      };
    }
  default:
    return state;
  }
}
