export default function(key, stateAtKey, action) {
  switch(action.type) {
  case "INTEGRATE_PAGE_RENDERED_DATA":
    return action.initialState.ui[key];
  default:
    return stateAtKey;
  }
};
