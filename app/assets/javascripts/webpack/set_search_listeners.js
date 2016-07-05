import { searchFocused, termSearched } from "action_creators";

const setSearchListeners = (dispatch) => {
  $("#navbar_search--query").focusin(_.partial(searchFocused, dispatch, true));
  $("#navbar_search--query").focusout(_.partial(searchFocused, dispatch, false));

  $("#navbar_search--query").keyup((e) => {
    termSearched(dispatch, e.target.value);
  });
};

export default setSearchListeners;
