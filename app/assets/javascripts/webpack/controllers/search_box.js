import React from "react";
import { searchFocused, termSearched, searchResultSelected } from "action_creators";
import { selectedSearchResult } from "controller_helpers/search_results"

const SearchBox = ({model, dispatch}) => {
  return(
    <input className="span3 search-query icon" id="search navbar_search--query"
      onFocus={_.partial(searchFocused, dispatch, true)}
      onBlur={_.partial(searchFocused, dispatch, false)}
      onChange={(e) => termSearched(dispatch, e.target.value)}
      onKeyUp={handleKeyUp}
      value={model.ui.searchTerm}
      autoComplete="off"
      placeholder="&#xf002; Search"
    />
  );
};

const UP_KEY_CODE = 38;
const DOWN_KEY_CODE = 40;

const handleKeyUp = (model, event) => {
  if(event.keyCode === UP_KEY_CODE){
    searchResultSelected(
      dispatch,
      (selectedSearchResult(model) - 1)
    )
  }
  else if (event.keyCode === DOWN_KEY_CODE) {
    searchResultSelected(
      dispatch,
      (selectedSearchResult(model) - 1)
    )
  }
}

export default SearchBox;
