const createChangeRoute = (history) => {
  return store => next => action => {
    if (action.type === "CHANGE_ROUTE") {
      history.push(action.route);
    }

    return next(action);
  };
}

export default createChangeRoute;
