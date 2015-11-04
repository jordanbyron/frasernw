export default function(state, dispatch) {
  if(state.ui.hasBeenInitialized) {
    return {};
  }
  else {
    return { isLoading: false };
  }
};
