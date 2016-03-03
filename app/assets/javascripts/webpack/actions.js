export function tabClicked(key, dispatch, event) {
  dispatch({
    type: "SELECT_PANEL",
    panel: key
  })
};
