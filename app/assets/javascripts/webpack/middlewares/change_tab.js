const changeTab = store => next => action => {
  if (action.type === "TAB_CLICKED") {
    window.location.hash = action.tabKey;
  }

  return next(action);
};

export default changeTab;
