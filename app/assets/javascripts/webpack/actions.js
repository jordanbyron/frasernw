export function tabClicked(key, dispatch, event) {
  dispatch({
    type: "SELECT_PANEL",
    panel: key
  })
};

export function reducedViewSelectorClicked(dispatch, currentView) {
  const newView = {
    main: "sidebar",
    sidebar: "main"
  }[currentView];

  dispatch({
    type: "TOGGLE_REDUCED_VIEW",
    newView: newView
  })
}
