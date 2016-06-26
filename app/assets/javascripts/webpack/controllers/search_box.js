import React from "react";
import { searchFocused, termSearched } from "action_creators";

const SearchBox = ({model, dispatch}) => {
  return(
    <input className="span3 search-query icon" id="search navbar_search--query"
      onFocus={_.partial(searchFocused, dispatch, true)}
      onBlur={_.partial(searchFocused, dispatch, false)}
      onChange={(e) => termSearched(dispatch, e.target.value)}
      value={model.ui.searchTerm}
      autoComplete="off"
      placeholder="&#xf002; Search"
    />
  );
}

export default SearchBox;
